#!/bin/bash

# サブディレクトリのGitリポジトリを更新するスクリプト
#
# 使用方法:
#   repo-update.sh [オプション]
#
# オプション:
#   -e, --exclude <pattern>   除外するディレクトリ名を指定
#                             複数指定可能: -e pattern1 -e pattern2 ...
#   -h, --help                このヘルプメッセージを表示
#
# 例:
#   repo-update.sh
#   repo-update.sh -e project-1 -e project-2
#   repo-update.sh --exclude=project-1 --exclude=project-2

# 除外パターン配列
EXCLUDE_PATTERNS=()

# ヘルプメッセージを表示
show_help() {
  cat << EOF
使用方法: $(basename "$0") [オプション]

サブディレクトリのGitリポジトリを最新化します。
作業中のリポジトリ(ステージ/アンステージファイルあり)はスキップします。

オプション:
  -e, --exclude <pattern>   除外するディレクトリ名を指定
                            複数指定可能: -e pattern1 -e pattern2 ...
  -h, --help                このヘルプメッセージを表示

例:
  $(basename "$0")
  $(basename "$0") -e project-1 -e project-2
  $(basename "$0") --exclude=project-1 --exclude=project-2
EOF
}

# パターンが有効かどうかを検証
validate_pattern() {
  local pattern="$1"
  
  # 空文字列チェック
  if [[ -z "$pattern" ]]; then
    echo "Error: Exclude pattern is empty" >&2
    return 1
  fi
  
  # 改行を含むパターンを拒否
  if [[ "$pattern" =~ $'\n' ]]; then
    echo "Error: Exclude pattern cannot contain newline: '$pattern'" >&2
    return 1
  fi
  
  return 0
}

# パターンを正規化（ワイルドカードがない場合は */pattern/* 形式に変換）
normalize_pattern() {
  local pattern="$1"
  
  # ワイルドカード(*, ?, [)を含むかチェック
  if [[ "$pattern" =~ [*?\[] ]]; then
    # 既にパターンが指定されているのでそのまま返す
    echo "$pattern"
  else
    # ディレクトリ名のみなので */name/* 形式に変換
    echo "*/${pattern}/*"
  fi
}

# オプション解析
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--exclude)
      # 次の引数が存在するかチェック
      if [[ -z "${2:-}" ]] || [[ "${2:-}" == -* ]]; then
        echo "Error: -e/--exclude option requires an argument" >&2
        exit 1
      fi
      
      # パターンを検証
      if ! validate_pattern "$2"; then
        exit 1
      fi
      
      # パターンを正規化して配列に追加
      normalized=$(normalize_pattern "$2")
      EXCLUDE_PATTERNS+=("$normalized")
      shift 2
      ;;
    --exclude=*)
      # = 以降を抽出
      pattern="${1#*=}"
      
      # パターンを検証
      if ! validate_pattern "$pattern"; then
        exit 1
      fi
      
      # パターンを正規化して配列に追加
      normalized=$(normalize_pattern "$pattern")
      EXCLUDE_PATTERNS+=("$normalized")
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Error: Unknown option: $1" >&2
      echo "Use -h or --help to display help" >&2
      exit 1
      ;;
  esac
done

# 一時ディレクトリを作成
tmpdir=$(mktemp -d) || {
  echo "Error: Failed to create temporary directory" >&2
  exit 1
}

# 安全な削除を行うクリーンアップ関数
cleanup() {
  # tmpdirが空でなく、/tmpまたは/var/folders配下であることを確認
  if [[ -n "$tmpdir" && "$tmpdir" =~ ^(/tmp|/var/folders)/ && -d "$tmpdir" ]]; then
    rm -rf "$tmpdir"
  fi
}
trap cleanup EXIT

# カウント用一時ファイル
success_count_file="$tmpdir/success_count"
skip_count_file="$tmpdir/skip_count"
error_count_file="$tmpdir/error_count"
echo "0" > "$success_count_file"
echo "0" > "$skip_count_file"
echo "0" > "$error_count_file"

# デフォルトブランチを取得する関数
get_default_branch() {
  local default_branch=""
  
  # 方法1: ローカルキャッシュから取得（最速）
  default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  
  if [[ -z "$default_branch" ]]; then
    # 方法2: 一般的なブランチ名を試す（フォールバック）
    for branch in main master; do
      if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        default_branch="$branch"
        break
      fi
    done
  fi
  
  echo "$default_branch"
}

# リポジトリを更新する関数
update_repo() {
  local git_dir=$1
  # 絶対パスに変換
  local repo_dir=$(cd "$(dirname "$git_dir")" && pwd)
  
  cd "$repo_dir" || return
  
  # リモート情報を更新
  git fetch --quiet 2>/dev/null
  
  # git status の出力を取得
  local status_output=$(git status --porcelain 2>/dev/null)
  
  # ステージされたファイルをチェック
  local staged=$(echo "$status_output" | grep -c '^[MADRCU]' || true)
  
  # アンステージなファイルをチェック
  local unstaged=$(echo "$status_output" | grep -c '^.[MADRCU]' || true)
  
  # ステージまたはアンステージファイルがある場合はスキップ
  if [[ $staged -gt 0 || $unstaged -gt 0 ]]; then
    echo "Skip: $repo_dir" >&2
    echo "1" >> "$skip_count_file"
    return
  fi
  
  # デフォルトブランチを取得
  local default_branch=$(get_default_branch)
  
  if [[ -z "$default_branch" ]]; then
    echo "Error: Default branch not found: $repo_dir" >&2
    echo "1" >> "$error_count_file"
    return
  fi
  
  # デフォルトブランチに切り替え
  if ! git checkout --quiet "$default_branch" 2>/dev/null; then
    echo "Error: Failed to switch branch: $repo_dir ($default_branch)" >&2
    echo "1" >> "$error_count_file"
    return
  fi
  
  # git pull を実行（fast-forwardのみ）
  if git pull --quiet --ff-only 2>/dev/null; then
    echo "1" >> "$success_count_file"
  else
    echo "Error: git pull failed: $repo_dir" >&2
    echo "1" >> "$error_count_file"
  fi
}

# 関数をエクスポート
export -f update_repo
export -f get_default_branch
export tmpdir
export success_count_file
export skip_count_file
export error_count_file

# find コマンドの引数配列を構築
find_args=()
find_args+=("."
             "-maxdepth" "4")

# 除外パターンがある場合は -prune オプションを追加
if [[ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]]; then
  find_args+=("(")
  
  for i in "${!EXCLUDE_PATTERNS[@]}"; do
    find_args+=("-path" "${EXCLUDE_PATTERNS[$i]}")
    
    # 最後以外は -o (OR) を追加
    if [[ $i -lt $((${#EXCLUDE_PATTERNS[@]} - 1)) ]]; then
      find_args+=("-o")
    fi
  done
  
  find_args+=(")"
             "-prune"
             "-o")
fi

# 検索条件を追加
find_args+=("-name" ".git"
            "-type" "d")

# 除外パターンがある場合は -print を明示
if [[ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]]; then
  find_args+=("-print")
fi

# リポジトリを並列で更新（12並列）
find "${find_args[@]}" | xargs -P 12 -I {} bash -c 'update_repo "$@"' _ {}

# 結果を集計
success_count=$(awk '{s+=$1} END {print s}' "$success_count_file")
skip_count=$(awk '{s+=$1} END {print s}' "$skip_count_file")
error_count=$(awk '{s+=$1} END {print s}' "$error_count_file")

# サマリーを表示
echo ""
echo "==== Update Results ===="
echo "Updated: ${success_count}"
echo "Skipped (work in progress): ${skip_count}"
echo "Errors: ${error_count}"
