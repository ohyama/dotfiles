#!/bin/bash

# Claude Code のカスタムステータスラインスクリプト
#
# stdin から JSON セッションデータを受け取り、2 行構成で以下を表示します。
#   1 行目: 作業ディレクトリ、git ブランチ（dirty 印）、モデル・effort
#   2 行目: コンテキスト使用率（バー + % + トークン数）、
#           5h / 7d レート制限使用率（バー + % + リセットまでの残り時間）
#
# 表示はすべて使用率ベースで、< 50% = 緑 / 50〜75% = 黄 / >= 75% = 赤 に
# 色分けします。バーの幅は COLUMNS（ターミナル幅）の半分に収まるよう
# 自動調整します。

input=$(cat)

# 現在時刻（リセット残り時間の計算用）
NOW=$(date +%s)

# ANSI カラーコード
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# 使用率に応じた色を返す（< 50% = 緑、50〜75% = 黄、>= 75% = 赤）
color_for_usage() {
  local pct=$1
  if (( pct >= 75 )); then
    printf '%s' "$RED"
  elif (( pct >= 50 )); then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# 使用率と幅からプログレスバー文字列を生成（█ = 使用済み、░ = 残り）
make_bar() {
  local pct=$1 width=$2
  local filled=$(( pct * width / 100 ))
  (( filled > width )) && filled=$width
  (( filled < 0 )) && filled=0
  local bar="" i
  for (( i = 0; i < filled; i++ )); do bar="${bar}█"; done
  for (( i = filled; i < width; i++ )); do bar="${bar}░"; done
  printf '%s' "$bar"
}

# トークン数を 156k / 1M のような短い表記に整形
fmt_tokens() {
  local n=$1
  if (( n >= 1000000 )); then
    # 0.1M 単位で四捨五入し、端数がなければ整数表記
    local m10=$(( (n + 50000) / 100000 ))
    if (( m10 % 10 == 0 )); then
      printf '%sM' "$(( m10 / 10 ))"
    else
      printf '%s.%sM' "$(( m10 / 10 ))" "$(( m10 % 10 ))"
    fi
  elif (( n >= 1000 )); then
    printf '%sk' "$(( (n + 500) / 1000 ))"
  else
    printf '%s' "$n"
  fi
}

# リセット時刻（epoch 秒）までの残り時間を 45m / 2h10m / 3d4h に整形
fmt_reset() {
  local epoch=$1
  local diff=$(( epoch - NOW ))
  (( diff < 0 )) && diff=0
  local days=$(( diff / 86400 ))
  local hours=$(( (diff % 86400) / 3600 ))
  local mins=$(( (diff % 3600) / 60 ))
  if (( days > 0 )); then
    printf '%sd%sh' "$days" "$hours"
  elif (( hours > 0 )); then
    printf '%sh%sm' "$hours" "$mins"
  else
    printf '%sm' "$mins"
  fi
}

# model.id と effort.level から表示ラベルを生成
#   例: claude-opus-4-8[1m] + high -> "Opus 4.8 (high)"
#       claude-haiku-4-5-20251001 -> "Haiku 4.5"（8 桁日付は除外）
model_label() {
  local id=$1 level=$2

  # 末尾の [...]（コンテキスト表記）と claude- プレフィックスを除去
  id="${id%%\[*}"
  id="${id#claude-}"

  # '-' で分割し、先頭をファミリー名、残りの数字をバージョンとして結合
  local parts family="" version="" token
  IFS='-' read -r -a parts <<< "$id"
  for token in "${parts[@]}"; do
    if [[ -z "$family" ]]; then
      family="$token"
    elif [[ "$token" =~ ^[0-9]{8}$ ]]; then
      # 8 桁の日付トークンはバージョンに含めない
      continue
    elif [[ "$token" =~ ^[0-9]+$ ]]; then
      version="${version}${version:+.}${token}"
    fi
  done

  # ファミリー名の先頭を大文字化（macOS 標準の bash 3.2 でも動くよう tr を使う）
  local head
  head=$(printf '%s' "${family:0:1}" | tr '[:lower:]' '[:upper:]')
  local label="${head}${family:1}${version:+ }${version}"

  # 想定外の長い ID への保険として最大 20 文字で切り詰める
  if (( ${#label} > 20 )); then
    label="${label:0:19}…"
  fi

  printf '%s%s' "$label" "${level:+ ($level)}"
}

# パスを短縮表示（$HOME -> ~、5 階層以上は末尾 3 階層のみ）
shorten_dir() {
  local path=$1
  if [[ "$path" == "$HOME"* ]]; then
    path="~${path#"$HOME"}"
  fi

  local parts
  IFS='/' read -r -a parts <<< "$path"
  local n=${#parts[@]}
  if (( n > 4 )); then
    printf '…/%s/%s/%s' "${parts[n-3]}" "${parts[n-2]}" "${parts[n-1]}"
  else
    printf '%s' "$path"
  fi
}

# --- JSON からフィールドを抽出 ---

MODEL_ID=$(echo "$input" | jq -r '.model.id // ""')
EFFORT=$(echo "$input" | jq -r '.effort.level // ""')
CWD=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
CTX_PCT=$(printf '%.0f' "$CTX_PCT")
CTX_USED=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
CTX_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
FH_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
[[ -n "$FH_PCT" ]] && FH_PCT=$(printf '%.0f' "$FH_PCT")
FH_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
[[ -n "$FH_RESET" ]] && FH_RESET=$(printf '%.0f' "$FH_RESET")
SD_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
[[ -n "$SD_PCT" ]] && SD_PCT=$(printf '%.0f' "$SD_PCT")
SD_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
[[ -n "$SD_RESET" ]] && SD_RESET=$(printf '%.0f' "$SD_RESET")

# --- バー幅の決定（ウインドウ幅の半分に収まるよう調整） ---

COLS=${COLUMNS:-80}
HALF=$(( COLS / 2 ))

# 2 行目はモデル・effort とバー 3 本（コンテキスト + 5h + 7d）を並べる。
# モデルラベル・絵文字・%・トークン数・残り時間などの固定部分 ≒ 65 桁
LINE2_FIXED=65
BARS_TOTAL=$(( HALF - LINE2_FIXED ))
(( BARS_TOTAL < 12 )) && BARS_TOTAL=12

# コンテキスト・5h・7d のバーはすべて同じ幅にする
BAR_W=$(( BARS_TOTAL / 3 ))
(( BAR_W < 3 )) && BAR_W=3
(( BAR_W > 5 )) && BAR_W=5

CTX_W=$BAR_W
RATE_W=$BAR_W

# --- 1 行目: 作業ディレクトリ + ブランチ（dirty 印） ---

DIR_LABEL=$(shorten_dir "$CWD")
LINE1="📁 ${DIR_LABEL}"

# index.lock 競合による表示欠けを避けるため GIT_OPTIONAL_LOCKS=0 を付ける
if GIT_OPTIONAL_LOCKS=0 git -C "$CWD" rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(GIT_OPTIONAL_LOCKS=0 git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ "$BRANCH" == "HEAD" ]] && BRANCH="(detached)"

  # ステージ / アンステージ / アントラックをカウント
  status_output=$(GIT_OPTIONAL_LOCKS=0 git -C "$CWD" status --porcelain 2>/dev/null)
  staged=$(printf '%s\n' "$status_output" | grep -c '^[MTADRCU]')
  unstaged=$(printf '%s\n' "$status_output" | grep -c '^.[MTADRCU]')
  untracked=$(printf '%s\n' "$status_output" | grep -c '^??')

  # 変更数を統合表記に（0 は省略、クリーンなら空）
  changes=""
  [[ "$staged" -gt 0 ]] && changes="+${staged}"
  [[ "$unstaged" -gt 0 ]] && changes="${changes}${changes:+ }*${unstaged}"
  [[ "$untracked" -gt 0 ]] && changes="${changes}${changes:+ }?${untracked}"

  LINE1="${LINE1}  🌿 ${BRANCH}${changes:+ }${changes}"
fi

echo -e "$LINE1"

# --- 2 行目: モデル・effort + コンテキスト使用率 + 5h / 7d レート制限（存在する場合のみ） ---

MODEL_LABEL=$(model_label "$MODEL_ID" "$EFFORT")
CTX_COLOR=$(color_for_usage "$CTX_PCT")
CTX_BAR=$(make_bar "$CTX_PCT" "$CTX_W")
CTX_TOKENS="$(fmt_tokens "$CTX_USED")/$(fmt_tokens "$CTX_SIZE")"

LINE2="🤖 ${MODEL_LABEL}  🧠 ${CTX_COLOR}${CTX_BAR} ${CTX_PCT}%${RESET} ${CTX_TOKENS}"

if [[ -n "$FH_PCT" ]]; then
  FH_COLOR=$(color_for_usage "$FH_PCT")
  FH_BAR=$(make_bar "$FH_PCT" "$RATE_W")
  FH_TIME=""
  [[ -n "$FH_RESET" ]] && FH_TIME=" $(fmt_reset "$FH_RESET")"
  LINE2="${LINE2}  🕔 ${FH_COLOR}${FH_BAR} ${FH_PCT}%${RESET}${FH_TIME}"
fi

if [[ -n "$SD_PCT" ]]; then
  SD_COLOR=$(color_for_usage "$SD_PCT")
  SD_BAR=$(make_bar "$SD_PCT" "$RATE_W")
  SD_TIME=""
  [[ -n "$SD_RESET" ]] && SD_TIME=" $(fmt_reset "$SD_RESET")"
  LINE2="${LINE2}  🗓️ ${SD_COLOR}${SD_BAR} ${SD_PCT}%${RESET}${SD_TIME}"
fi

echo -e "$LINE2"

exit 0
