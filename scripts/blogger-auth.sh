#!/bin/bash

# Blogger OAuth認証スクリプト
# 使用方法: ./scripts/blogger-auth.sh

set -e

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

# 認証URLを生成
AUTH_URL="https://accounts.google.com/o/oauth2/v2/auth?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&scope=https://www.googleapis.com/auth/blogger&response_type=code&access_type=offline&prompt=consent"

echo "=========================================="
echo "Blogger OAuth認証"
echo "=========================================="
echo ""
echo "1. 以下のURLをブラウザで開いてください:"
echo ""
echo "$AUTH_URL"
echo ""
echo "2. Googleアカウントで認証してください"
echo ""
echo "3. 認証後、ブラウザに認証コードが表示されます"
echo "   そのコードをコピーして、以下のコマンドを実行してください:"
echo ""
echo "   ./scripts/blogger-token.sh <認証コード>"
echo ""
