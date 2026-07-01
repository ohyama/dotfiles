#!/bin/bash

# サブディレクトリのGitリポジトリ状態を取得するスクリプト
#
# git worktree (git-gtr) 運用に対応し、各リポジトリ配下の worktree を
# グループ化してインデント表示します。
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
各リポジトリの worktree はメインリポジトリ配下にインデント表示されます。

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

# 作業ディレクトリを保存（絶対パス）
WORK_DIR=$(pwd)

# 経過時間計算用の現在エポック秒
NOW=$(date +%s)

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

# 最終コミットからの経過時間を compact 表記に変換（例: now, 5m, 3h, 2d, 1w, 4mo）
format_age() {
  local commit_time="$1"
  local diff=$(( NOW - commit_time ))
  (( diff < 0 )) && diff=0

  if (( diff < 60 )); then
    echo "now"
  elif (( diff < 3600 )); then
    echo "$(( diff / 60 ))m"
  elif (( diff < 86400 )); then
    echo "$(( diff / 3600 ))h"
  elif (( diff < 604800 )); then
    echo "$(( diff / 86400 ))d"
  elif (( diff < 2592000 )); then
    echo "$(( diff / 604800 ))w"
  else
    echo "$(( diff / 2592000 ))mo"
  fi
}

# 単一 worktree の情報を1行（タブ区切り）で出力する関数
#   引数: worktree パス, メインリポジトリ絶対パス, リポジトリ表示名, リポジトリ共有stash
process_worktree() {
  local wt="$1"
  local repo_dir="$2"
  local repo_name="$3"
  local repo_stash="$4"

  # worktree の絶対パス（シンボリックリンク等を正規化）
  local wt_abs
  wt_abs=$(cd "$wt" 2>/dev/null && pwd) || return

  # メインリポジトリかどうか
  local is_main="false"
  [[ "$wt_abs" == "$repo_dir" ]] && is_main="true"

  # ブランチ名（detached は (detached) 表記）
  local branch
  branch=$(git -C "$wt_abs" rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ "$branch" == "HEAD" ]] && branch="(detached)"

  # git status の出力を取得
  local status_output
  status_output=$(git -C "$wt_abs" status --porcelain 2>/dev/null)

  # ステージ/アンステージ/アントラックをカウント
  local staged unstaged untracked
  staged=$(printf '%s\n' "$status_output" | grep -c '^[MTADRCU]')
  unstaged=$(printf '%s\n' "$status_output" | grep -c '^.[MTADRCU]')
  untracked=$(printf '%s\n' "$status_output" | grep -c '^??')

  # 変更数を統合表記に（0 は省略、クリーンなら空）
  local changes=""
  [[ "$staged" -gt 0 ]] && changes="+${staged}"
  [[ "$unstaged" -gt 0 ]] && changes="${changes}${changes:+ }*${unstaged}"
  [[ "$untracked" -gt 0 ]] && changes="${changes}${changes:+ }?${untracked}"

  # upstream との差分（ahead/behind）
  local remote_diff=""
  if git -C "$wt_abs" rev-parse --abbrev-ref --symbolic-full-name @{upstream} >/dev/null 2>&1; then
    local ahead_behind
    ahead_behind=$(git -C "$wt_abs" rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
    if [[ -n "$ahead_behind" ]]; then
      local ahead behind
      ahead=$(echo "$ahead_behind" | awk '{print $1}')
      behind=$(echo "$ahead_behind" | awk '{print $2}')
      if [[ "$ahead" -gt 0 ]] || [[ "$behind" -gt 0 ]]; then
        [[ "$ahead" -gt 0 ]] && remote_diff="+${ahead}"
        [[ "$behind" -gt 0 ]] && remote_diff="${remote_diff}${remote_diff:+/}-${behind}"
      fi
    fi
  fi

  # 最終コミットからの経過時間
  local last=""
  local commit_time
  commit_time=$(git -C "$wt_abs" log -1 --format=%ct 2>/dev/null)
  [[ -n "$commit_time" ]] && last=$(format_age "$commit_time")

  # stash はリポジトリ単位で共有されるため main 行のみ表示
  local stash=""
  [[ "$is_main" == "true" ]] && stash="$repo_stash"

  # 行種別・表示名・ソートキーを決定
  local row_type name order
  if [[ "$is_main" == "true" ]]; then
    row_type="main"
    name="$repo_name"
    order=0
  else
    row_type="wt"
    name="$branch"
    order=1
  fi

  # ソートキー: リポジトリでグループ化 → main(0) を先頭 → ブランチ名昇順
  # 区切りに US(\x1f)を使い、パス・ブランチ名と衝突しないようにする
  local SEP=$'\x1f'
  local sortkey="${repo_name}${SEP}${order}${SEP}${branch}"

  # タブ区切りで出力:
  #   sortkey, group, type, name, branch, changes, remote, stash, last
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$sortkey" "$repo_name" "$row_type" "$name" "$branch" \
    "$changes" "$remote_diff" "$stash" "$last"
}

# メインリポジトリ単位で情報を収集する関数
process_repo() {
  local git_dir=$1
  # 絶対パスに変換
  local repo_dir
  repo_dir=$(cd "$(dirname "$git_dir")" && pwd) || return

  # 作業ディレクトリからの相対パスを計算（表示名）
  local repo_name
  repo_name=$(realpath --relative-to="$WORK_DIR" "$repo_dir" 2>/dev/null || \
    REPO_DIR="$repo_dir" WORK_DIR="$WORK_DIR" python3 -c 'import os, os.path; print(os.path.relpath(os.environ["REPO_DIR"], os.environ["WORK_DIR"]))')

  # 並列実行時の衝突を避けるため一意な一時ファイルを使う
  local output_file
  output_file=$(mktemp "$tmpdir/repo.XXXXXX") || return

  # リモート情報を更新（リポジトリ単位で1回だけ）
  git -C "$repo_dir" fetch --quiet 2>/dev/null

  # stash の数を取得（worktree 間で共有されるためリポジトリ単位で1回）
  local stash_count
  stash_count=$(git -C "$repo_dir" stash list 2>/dev/null | wc -l | tr -d ' ')
  local repo_stash=""
  [[ "$stash_count" -gt 0 ]] && repo_stash="$stash_count"

  # worktree を列挙して1つずつ処理（main 含む）
  local wt
  git -C "$repo_dir" worktree list --porcelain 2>/dev/null \
    | sed -n 's/^worktree //p' \
    | while IFS= read -r wt; do
        [[ -z "$wt" ]] && continue
        # find と同じ除外パターンを worktree パスにも適用
        if [[ -n "$EXCLUDE_PATTERNS_STR" ]]; then
          skip=false
          while IFS= read -r pat; do
            [[ -z "$pat" ]] && continue
            case "$wt/" in
              $pat) skip=true; break ;;
            esac
          done <<< "$EXCLUDE_PATTERNS_STR"
          [[ "$skip" == true ]] && continue
        fi
        process_worktree "$wt" "$repo_dir" "$repo_name" "$repo_stash"
      done > "$output_file"
}

# 除外パターンを worktree フィルタ用にサブシェルへ渡す（改行区切り）
# find の -prune はメインリポジトリ探索にのみ効くため、git worktree list で
# 列挙した worktree パスは process_repo 側で同じパターンに対して再フィルタする。
EXCLUDE_PATTERNS_STR=""
if [[ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]]; then
  EXCLUDE_PATTERNS_STR=$(printf '%s\n' "${EXCLUDE_PATTERNS[@]}")
fi

# 関数をエクスポート
export -f process_repo
export -f process_worktree
export -f format_age
export tmpdir
export WORK_DIR
export NOW
export EXCLUDE_PATTERNS_STR

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

# 検索条件を追加（メインリポジトリの .git ディレクトリのみ。
# worktree の .git はファイルなのでここでは拾わず、各リポジトリで列挙する）
find_args+=("-name" ".git"
            "-type" "d"
            "-print0")

# データを並列で収集（12並列、メインリポジトリ単位）
# 空白を含むパスに対応するため NUL 区切りで受け渡す
find "${find_args[@]}" | xargs -0 -P 12 -I {} bash -c 'process_repo "$@"' _ {}

# 結果を統合（sortkey で整列。バイト順で安定させる）
tmpfile="$tmpdir/result.tsv"
cat "$tmpdir"/repo.* 2>/dev/null | LC_ALL=C sort > "$tmpfile"

# 列名
headers=("Repository" "Branch" "Changes" "Remote" "Stash" "Last")

# 文字列の表示幅を取得する関数（マルチバイト文字対応）
get_display_width() {
  local str=$1
  # 文字数をカウント（マルチバイト文字も1文字としてカウント）
  local char_count=$(printf '%s' "$str" | wc -m | tr -d ' ')
  # バイト数をカウント
  local byte_count=$(printf '%s' "$str" | wc -c | tr -d ' ')

  # UTF-8の日本語文字は3バイト、表示幅は2
  # ASCII文字は1バイト、表示幅は1
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

# セルの表示幅を取得する関数
# Repository 列の worktree 行はツリー罫線プレフィックス（" ├ " / " └ "）を持つ。
# 罫線文字(├└)は3バイトだが視覚幅は1なので get_display_width が誤カウントする。
# プレフィックスの視覚幅は固定3桁として扱い、名前部分のみ get_display_width で計測する。
cell_display_width() {
  local s=$1
  case "$s" in
    " ├ "*|" └ "*)
      local rest="${s#" ├ "}"
      rest="${rest#" └ "}"
      echo $(( 3 + $(get_display_width "$rest") ))
      ;;
    *)
      get_display_width "$s"
      ;;
  esac
}

# 収集結果をパースして配列に格納
g_group=(); g_type=(); g_name=(); g_branch=()
g_changes=(); g_remote=(); g_stash=(); g_last=()
total=0
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  # 空フィールドを保持するため awk で分割（IFS=タブだと空フィールドが潰れる）
  g_group[$total]=$(printf '%s' "$line" | awk -F'\t' '{print $2}')
  g_type[$total]=$(printf '%s' "$line" | awk -F'\t' '{print $3}')
  g_name[$total]=$(printf '%s' "$line" | awk -F'\t' '{print $4}')
  g_branch[$total]=$(printf '%s' "$line" | awk -F'\t' '{print $5}')
  g_changes[$total]=$(printf '%s' "$line" | awk -F'\t' '{print $6}')
  g_remote[$total]=$(printf '%s' "$line" | awk -F'\t' '{print $7}')
  g_stash[$total]=$(printf '%s' "$line" | awk -F'\t' '{print $8}')
  g_last[$total]=$(printf '%s' "$line" | awk -F'\t' '{print $9}')
  total=$((total + 1))
done < "$tmpfile"

# Repository 列の表示文字列（ツリー罫線プレフィックス付き）と太字フラグを構築
g_col0=(); g_bold=()
for ((i = 0; i < total; i++)); do
  if [[ "${g_type[$i]}" == "main" ]]; then
    g_col0[$i]="${g_name[$i]}"
    g_bold[$i]="true"
  else
    # 同一グループ内の最後の worktree なら └、それ以外は ├
    if [[ $((i + 1)) -ge $total ]] || [[ "${g_group[$((i + 1))]}" != "${g_group[$i]}" ]]; then
      g_col0[$i]=" └ ${g_name[$i]}"
    else
      g_col0[$i]=" ├ ${g_name[$i]}"
    fi
    g_bold[$i]="false"
  fi
done

# 指定列・行のセル値を返す
cell_value() {
  local col=$1 row=$2
  case $col in
    0) printf '%s' "${g_col0[$row]}" ;;
    1) printf '%s' "${g_branch[$row]}" ;;
    2) printf '%s' "${g_changes[$row]}" ;;
    3) printf '%s' "${g_remote[$row]}" ;;
    4) printf '%s' "${g_stash[$row]}" ;;
    5) printf '%s' "${g_last[$row]}" ;;
  esac
}

# 各列の最大幅を計算
col_widths=()
for c in {0..5}; do
  # ヘッダーの幅
  width=$(cell_display_width "${headers[$c]}")

  # データの最大幅を取得
  for ((i = 0; i < total; i++)); do
    len=$(cell_display_width "$(cell_value "$c" "$i")")
    [[ $len -gt $width ]] && width=$len
  done

  # パディングを追加
  ((width += 2))
  col_widths[$c]=$width
done

# 罫線を描画する関数
print_line() {
  local line_type=$1  # top, middle, bottom
  local left mid right i
  case $line_type in
    top)    left="┌"; mid="┬"; right="┐" ;;
    middle) left="├"; mid="┼"; right="┤" ;;
    bottom) left="└"; mid="┴"; right="┘" ;;
  esac

  printf "%s" "$left"
  for i in {0..5}; do
    printf "─%.0s" $(seq 1 ${col_widths[$i]})
    [[ $i -lt 5 ]] && printf "%s" "$mid" || printf "%s\n" "$right"
  done
}

# データ行を描画する関数
print_row() {
  local c1=$1 c2=$2 c3=$3 c4=$4 c5=$5 c6=$6 bold=$7
  local cells=("$c1" "$c2" "$c3" "$c4" "$c5" "$c6")

  printf "│"
  local idx c w pad
  for idx in 0 1 2 3 4 5; do
    c="${cells[$idx]}"
    w=$(cell_display_width "$c")
    pad=$(( col_widths[$idx] - w - 1 ))
    (( pad < 0 )) && pad=0
    if [[ "$bold" == "true" ]]; then
      printf " \033[1m%s\033[0m%*s│" "$c" "$pad" ""
    else
      printf " %s%*s│" "$c" "$pad" ""
    fi
  done
  printf "\n"
}

# 表を描画
print_line top
print_row "${headers[0]}" "${headers[1]}" "${headers[2]}" "${headers[3]}" "${headers[4]}" "${headers[5]}" "true"
print_line middle

for ((i = 0; i < total; i++)); do
  # 新しいリポジトリグループの先頭（main 行）の前に区切り線を引く（先頭グループを除く）
  if [[ "${g_type[$i]}" == "main" ]] && [[ $i -gt 0 ]]; then
    print_line middle
  fi
  print_row "${g_col0[$i]}" "${g_branch[$i]}" "${g_changes[$i]}" "${g_remote[$i]}" "${g_stash[$i]}" "${g_last[$i]}" "${g_bold[$i]}"
done

print_line bottom
