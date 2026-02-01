#!/bin/bash

# 認証コードをアクセストークンに交換するスクリプト
# 使用方法: ./scripts/blogger-token.sh <認証コード>

set -e

AUTH_CODE="$1"

if [ -z "$AUTH_CODE" ]; then
    echo "使用方法: ./scripts/blogger-token.sh <認証コード>"
    exit 1
fi

# .envファイルから認証情報を読み込み
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

CLIENT_ID="${BLOGGER_CLIENT_ID}"
CLIENT_SECRET="${BLOGGER_CLIENT_SECRET}"
REDIRECT_URI="http://localhost:8080"

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
    echo "エラー: .envファイルにBLOGGER_CLIENT_IDとBLOGGER_CLIENT_SECRETを設定してください"
    exit 1
fi

echo "トークンを取得中..."

RESPONSE=$(curl -s -X POST "https://oauth2.googleapis.com/token" \
    -d "client_id=${CLIENT_ID}" \
    -d "client_secret=${CLIENT_SECRET}" \
    -d "code=${AUTH_CODE}" \
    -d "grant_type=authorization_code" \
    -d "redirect_uri=${REDIRECT_URI}")

echo ""
echo "レスポンス:"
echo "$RESPONSE" | jq .

# アクセストークンとリフレッシュトークンを抽出
ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')
REFRESH_TOKEN=$(echo "$RESPONSE" | jq -r '.refresh_token')

if [ "$ACCESS_TOKEN" != "null" ] && [ -n "$ACCESS_TOKEN" ]; then
    echo ""
    echo "=========================================="
    echo "トークン取得成功!"
    echo "=========================================="
    echo ""
    echo ".envファイルに以下を追加してください:"
    echo ""
    echo "BLOGGER_ACCESS_TOKEN=${ACCESS_TOKEN}"
    if [ "$REFRESH_TOKEN" != "null" ] && [ -n "$REFRESH_TOKEN" ]; then
        echo "BLOGGER_REFRESH_TOKEN=${REFRESH_TOKEN}"
    fi
else
    echo ""
    echo "エラー: トークンの取得に失敗しました"
    exit 1
fi
