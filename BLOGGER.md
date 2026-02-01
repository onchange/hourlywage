# Blogger API 連携ガイド

## ブログ情報

- **ブログ名**: メモメモ
- **ブログID**: 18765938
- **URL**: https://onchange.blogspot.com/
- **総記事数**: 15件

## 認証情報

認証情報は `.env` ファイルに保存（`.gitignore` で除外済み）:

```
BLOGGER_API_KEY=your_api_key
BLOGGER_CLIENT_ID=your_client_id
BLOGGER_CLIENT_SECRET=your_client_secret
BLOGGER_BLOG_ID=18765938
```

## API エンドポイント

### 記事一覧取得（認証不要）
```bash
curl "https://www.googleapis.com/blogger/v3/blogs/18765938/posts?key=$BLOGGER_API_KEY&maxResults=10"
```

### 特定記事取得（認証不要）
```bash
curl "https://www.googleapis.com/blogger/v3/blogs/18765938/posts/{postId}?key=$BLOGGER_API_KEY"
```

### 記事投稿（OAuth 2.0 認証必要）
```bash
curl -X POST \
  "https://www.googleapis.com/blogger/v3/blogs/18765938/posts" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "kind": "blogger#post",
    "title": "記事タイトル",
    "content": "<p>記事本文（HTML）</p>"
  }'
```

### 記事更新（OAuth 2.0 認証必要）
```bash
curl -X PUT \
  "https://www.googleapis.com/blogger/v3/blogs/18765938/posts/{postId}" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "kind": "blogger#post",
    "title": "更新後タイトル",
    "content": "<p>更新後本文</p>"
  }'
```

## OAuth 2.0 認証フロー

投稿・更新にはOAuth 2.0認証が必要:

### 初回認証（スクリプト使用）

1. **認証URLを取得**:
```bash
./scripts/blogger-auth.sh
```

2. **表示されたURLをブラウザで開き、認証後のコードでトークン取得**:
```bash
./scripts/blogger-token.sh <認証コード>
```

3. **表示されたトークンを`.env`に追加**

### 手動認証

1. **認証URL生成**:
```
https://accounts.google.com/o/oauth2/v2/auth?
  client_id=$BLOGGER_CLIENT_ID&
  redirect_uri=http://localhost:8080&
  scope=https://www.googleapis.com/auth/blogger&
  response_type=code&
  access_type=offline&
  prompt=consent
```

2. **認証コードをアクセストークンに交換**:
```bash
curl -X POST "https://oauth2.googleapis.com/token" \
  -d "client_id=$BLOGGER_CLIENT_ID" \
  -d "client_secret=$BLOGGER_CLIENT_SECRET" \
  -d "code=$AUTH_CODE" \
  -d "grant_type=authorization_code" \
  -d "redirect_uri=http://localhost:8080"
```

### トークンリフレッシュ

アクセストークンは1時間で期限切れになります。リフレッシュトークンを使って更新：

```bash
source .env && curl -s -X POST "https://oauth2.googleapis.com/token" \
  -d "client_id=${BLOGGER_CLIENT_ID}" \
  -d "client_secret=${BLOGGER_CLIENT_SECRET}" \
  -d "refresh_token=${BLOGGER_REFRESH_TOKEN}" \
  -d "grant_type=refresh_token" | jq .
```

レスポンスの`access_token`を`.env`の`BLOGGER_ACCESS_TOKEN`に更新してください。

## 投稿済み記事

### 生成AI用語集
- **記事ID**: 2183129097181157496
- **投稿日**: 2026-02-01
- **URL**: https://onchange.blogspot.com/2026/02/ai-moethinking.html
- **内容**: MoE、Thinking、Reasoning、RLHF、RAG等の主要概念まとめ

### 時給競争力シミュレーター
- **記事ID**: 8545276010312984829
- **投稿日**: 2026-02-01
- **URL**: http://onchange.blogspot.com/2026/02/blog-post.html
- **関連ツール**: https://hourlywage.pages.dev/hourlywage

## 記事作成ワークフロー

1. 記事内容をHTML形式で作成
2. 画像はBlogger管理画面でアップロードしてURLを取得
3. Blogger API（curl）または管理画面から投稿

## 注意事項

- APIキーは読み取り専用操作にのみ使用可能
- 投稿・更新・削除にはOAuth 2.0トークンが必要
- アクセストークンは1時間で期限切れ（リフレッシュトークンで更新）
- `.env` ファイルは絶対にコミットしない
