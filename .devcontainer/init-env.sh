#!/bin/bash
# Dev Container の initializeCommand で実行し .env を自動生成する

set -euo pipefail

# コンテナ内のマウント先パスをホストと合わせるためのパスを取得する
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

# PROJECT_NAME のバリデーション
if [ -f "$ENV_FILE" ]; then
  PROJECT_NAME="$(grep '^PROJECT_NAME=' "$ENV_FILE" | cut -d= -f2 | tr -d '"' || true)"
fi
if [ -z "${PROJECT_NAME:-}" ]; then
  echo "ERROR: PROJECT_NAME is not set in .devcontainer/.env" >&2
  exit 1
fi

# Docker Compose のプロジェクト名
# プロジェクト名は小文字英数字・ハイフン・アンダースコアのみ許可されるため変換する
BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
COMPOSE_PROJECT_NAME="$(echo "${PROJECT_NAME}_${BRANCH_NAME}" | tr '[:upper:]' '[:lower:]' | sed 's|/|-|g' | sed 's/[^a-z0-9_-]//g')"

# プロジェクトディレクトリ全体をマウントするため、メインワークツリーの親ディレクトリを取得する
# GIT_COMMON_DIR (.git) → メインワークツリー → プロジェクトルートディレクトリ
GIT_COMMON_DIR="$(cd "$(git rev-parse --git-common-dir)" && pwd)"
PROJECT_ROOT_DIR="$(dirname "$(dirname "$GIT_COMMON_DIR")")"

# .env に環境変数を追記 （冪等性を確保するため、既存の値を削除してから追記）
if [ -f "$ENV_FILE" ]; then
  sed -i '' '/^COMPOSE_PROJECT_NAME=/d' "$ENV_FILE"
  sed -i '' '/^PROJECT_ROOT_DIR=/d' "$ENV_FILE"
fi

cat >> "$ENV_FILE" <<EOF
COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
PROJECT_ROOT_DIR=${PROJECT_ROOT_DIR}
EOF
