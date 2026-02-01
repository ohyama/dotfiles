#!/bin/bash

# サブディレクトリのGitリポジトリ状態を取得するスクリプト
#
# 使用方法:
#   repo-status.sh [オプション]
#
# オプション:
#   -e, --exclude <pattern>   除外するディレクトリ名を指定
#                             複数指定可能: -e pattern1 -e pattern2 ...
#   -h, --help                このヘルプメッセージを表示
#
# 例:
#   repo-status.sh
#   repo-status.sh -e project-1 -e project-2
#   repo-status.sh --exclude=project-1 --exclude=project-2

# 除外パターン配列
EXCLUDE_PATTERNS=()

# ヘルプメッセージを表示
show_help() {
  cat << EOF
使用方法: $(basename "$0") [オプション]

サブディレクトリのGitリポジトリ状態を一覧表示します。

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
    echo "エラー: 除外パターンが空です" >&2
    return 1
  fi
  
  # 改行を含むパターンを拒否
  if [[ "$pattern" =~ $'\n' ]]; then
    echo "エラー: 除外パターンに改行を含めることはできません: '$pattern'" >&2
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
        echo "エラー: -e/--exclude オプションには引数が必要です" >&2
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
      echo "エラー: 不明なオプション: $1" >&2
      echo "ヘルプを表示するには -h または --help を使用してください" >&2
      exit 1
      ;;
  esac
done

# 一時ディレクトリを作成
tmpdir=$(mktemp -d) || {
  echo "エラー: 一時ディレクトリの作成に失敗しました" >&2
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

# リポジトリ情報を収集する関数
process_repo() {
  local git_dir=$1
  # 絶対パスに変換
  local repo_dir=$(cd "$(dirname "$git_dir")" && pwd)
  
  cd "$repo_dir" || return
  
  local repo_name=$(basename "$repo_dir")
  # フルパスをエンコードして一意なファイル名を生成
  local relative_path="${repo_dir/#$HOME/~}"
  local safe_name="${relative_path//\//_}"
  local output_file="$tmpdir/${safe_name}.txt"
  
  # リモート情報を更新
  git fetch --quiet 2>/dev/null
  
  # カレントブランチを取得
  local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  
  # git status の出力を取得（stderr を /dev/null にリダイレクト）
  local status_output=$(git status --porcelain 2>/dev/null)
  
  # ステージされたファイルの数をカウント
  local staged=$(echo "$status_output" | grep -c '^[MADRCU]' || true)
  [[ "$staged" -eq 0 ]] && staged=""
  
  # アンステージなファイルの数をカウント
  local unstaged=$(echo "$status_output" | grep -c '^.[MADRCU]' || true)
  [[ "$unstaged" -eq 0 ]] && unstaged=""
  
  # アントラックファイルの数をカウント
  local untracked=$(echo "$status_output" | grep -c '^??' || true)
  [[ "$untracked" -eq 0 ]] && untracked=""
  
  # リモートとの差分を取得（ahead/behind）
  local remote_diff=""
  if upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null); then
    ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
    if [[ -n "$ahead_behind" ]]; then
      ahead=$(echo "$ahead_behind" | awk '{print $1}')
      behind=$(echo "$ahead_behind" | awk '{print $2}')
      
      if [[ "$ahead" -gt 0 ]] || [[ "$behind" -gt 0 ]]; then
        remote_diff=""
        [[ "$ahead" -gt 0 ]] && remote_diff="+${ahead}"
        [[ "$behind" -gt 0 ]] && remote_diff="${remote_diff}${remote_diff:+/}-${behind}"
      fi
    fi
  fi
  
  # stashの数を取得
  local stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
  local stash=""
  if [[ "$stash_count" -gt 0 ]]; then
    stash="$stash_count"
  fi
  
  # タブ区切りで出力
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$repo_name" "$current_branch" "$staged" "$unstaged" "$untracked" "$remote_diff" "$stash" > "$output_file"
}

# 関数をエクスポート
export -f process_repo
export tmpdir

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

# データを並列で収集（12並列）
find "${find_args[@]}" | xargs -P 12 -I {} bash -c 'process_repo "$@"' _ {}

# 結果を統合
tmpfile="$tmpdir/result.txt"
cat "$tmpdir"/*.txt | sort > "$tmpfile" 2>/dev/null

# 列名
headers=("Repository" "Current Branch" "Staged" "Unstaged" "Untracked" "Remote Diff" "Stash")

# 文字列の表示幅を取得する関数（マルチバイト文字対応）
get_display_width() {
  local str=$1
  # 文字数をカウント（マルチバイト文字も1文字としてカウント）
  local char_count=$(printf '%s' "$str" | wc -m | tr -d ' ')
  # バイト数をカウント
  local byte_count=$(printf '%s' "$str" | wc -c | tr -d ' ')
  
  # UTF-8の日本語文字は3バイト、表示幅は2
  # ASCII文字は1バイト、表示幅は1
  # 簡易計算: 表示幅 = 文字数 + (バイト数 - 文字数) / 3
  # より正確には: 全角文字数 = (バイト数 - 文字数) / 2（UTF-8の場合）
  # 表示幅 = (文字数 - 全角文字数) + (全角文字数 * 2)
  
  local multibyte_chars=$(( (byte_count - char_count) ))
  if [[ $multibyte_chars -gt 0 ]]; then
    # UTF-8の全角文字（3バイト）を想定
    local wide_chars=$(( multibyte_chars / 2 ))
    local ascii_chars=$(( char_count - wide_chars ))
    echo $(( ascii_chars + wide_chars * 2 ))
  else
    # 全てASCII文字
    echo "$char_count"
  fi
}

# 各列の最大幅を計算
col_widths=()
for i in {0..6}; do
  # ヘッダーの幅
  width=$(get_display_width "${headers[$i]}")
  
  # データの最大幅を取得
  while IFS=$'\t' read -r c1 c2 c3 c4 c5 c6 c7; do
    case $i in
      0) len=$(get_display_width "$c1") ;;
      1) len=$(get_display_width "$c2") ;;
      2) len=$(get_display_width "$c3") ;;
      3) len=$(get_display_width "$c4") ;;
      4) len=$(get_display_width "$c5") ;;
      5) len=$(get_display_width "$c6") ;;
      6) len=$(get_display_width "$c7") ;;
    esac
    [[ $len -gt $width ]] && width=$len
  done < "$tmpfile"
  
  # パディングを追加
  ((width += 2))
  col_widths[$i]=$width
done

# 罫線を描画する関数
print_line() {
  local line_type=$1  # top, middle, bottom
  
  case $line_type in
    top)
      printf "┌"
      for i in {0..6}; do
        printf "─%.0s" $(seq 1 ${col_widths[$i]})
        [[ $i -lt 6 ]] && printf "┬" || printf "┐\n"
      done
      ;;
    middle)
      printf "├"
      for i in {0..6}; do
        printf "─%.0s" $(seq 1 ${col_widths[$i]})
        [[ $i -lt 6 ]] && printf "┼" || printf "┤\n"
      done
      ;;
    bottom)
      printf "└"
      for i in {0..6}; do
        printf "─%.0s" $(seq 1 ${col_widths[$i]})
        [[ $i -lt 6 ]] && printf "┴" || printf "┘\n"
      done
      ;;
  esac
}

# データ行を描画する関数
print_row() {
  local c1=$1 c2=$2 c3=$3 c4=$4 c5=$5 c6=$6 c7=$7
  local bold=$8  # 太字フラグ
  
  # 各列の表示幅を計算
  local w1=$(get_display_width "$c1")
  local w2=$(get_display_width "$c2")
  local w3=$(get_display_width "$c3")
  local w4=$(get_display_width "$c4")
  local w5=$(get_display_width "$c5")
  local w6=$(get_display_width "$c6")
  local w7=$(get_display_width "$c7")
  
  # パディングを計算（列幅 - 表示幅 - 2）
  local p1=$((col_widths[0] - w1 - 1))
  local p2=$((col_widths[1] - w2 - 1))
  local p3=$((col_widths[2] - w3 - 1))
  local p4=$((col_widths[3] - w4 - 1))
  local p5=$((col_widths[4] - w5 - 1))
  local p6=$((col_widths[5] - w6 - 1))
  local p7=$((col_widths[6] - w7 - 1))
  
  # 太字の場合はANSIエスケープシーケンスを追加
  if [[ "$bold" == "true" ]]; then
    printf "│ \033[1m%s\033[0m%*s│ \033[1m%s\033[0m%*s│ \033[1m%s\033[0m%*s│ \033[1m%s\033[0m%*s│ \033[1m%s\033[0m%*s│ \033[1m%s\033[0m%*s│ \033[1m%s\033[0m%*s│\n" \
      "$c1" $p1 "" "$c2" $p2 "" "$c3" $p3 "" "$c4" $p4 "" "$c5" $p5 "" "$c6" $p6 "" "$c7" $p7 ""
  else
    printf "│ %s%*s│ %s%*s│ %s%*s│ %s%*s│ %s%*s│ %s%*s│ %s%*s│\n" \
      "$c1" $p1 "" "$c2" $p2 "" "$c3" $p3 "" "$c4" $p4 "" "$c5" $p5 "" "$c6" $p6 "" "$c7" $p7 ""
  fi
}

# 表を描画
print_line top
print_row "${headers[0]}" "${headers[1]}" "${headers[2]}" "${headers[3]}" "${headers[4]}" "${headers[5]}" "${headers[6]}" "true"
print_line middle

first=true
while IFS= read -r line; do
  # awkを使ってタブ区切りフィールドを正確に分割（空フィールドも保持）
  c1=$(echo "$line" | awk -F'\t' '{print $1}')
  c2=$(echo "$line" | awk -F'\t' '{print $2}')
  c3=$(echo "$line" | awk -F'\t' '{print $3}')
  c4=$(echo "$line" | awk -F'\t' '{print $4}')
  c5=$(echo "$line" | awk -F'\t' '{print $5}')
  c6=$(echo "$line" | awk -F'\t' '{print $6}')
  c7=$(echo "$line" | awk -F'\t' '{print $7}')
  
  if [[ "$first" != "true" ]]; then
    print_line middle
  fi
  first=false
  print_row "$c1" "$c2" "$c3" "$c4" "$c5" "$c6" "$c7" "false"
done < "$tmpfile"

print_line bottom
