# Blogger API 連携ガイド

## ブログ情報

- **ブログ名**: メモメモ
- **ブログID**: 18765938
- **URL**: https://onchange.blogspot.com/
- **総記事数**: 14件

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

1. **認証URL生成**:
```
https://accounts.google.com/o/oauth2/v2/auth?
  client_id=$BLOGGER_CLIENT_ID&
  redirect_uri=urn:ietf:wg:oauth:2.0:oob&
  scope=https://www.googleapis.com/auth/blogger&
  response_type=code
```

2. **認証コードをアクセストークンに交換**:
```bash
curl -X POST "https://oauth2.googleapis.com/token" \
  -d "client_id=$BLOGGER_CLIENT_ID" \
  -d "client_secret=$BLOGGER_CLIENT_SECRET" \
  -d "code=$AUTH_CODE" \
  -d "grant_type=authorization_code" \
  -d "redirect_uri=urn:ietf:wg:oauth:2.0:oob"
```

3. **リフレッシュトークンでアクセストークン更新**:
```bash
curl -X POST "https://oauth2.googleapis.com/token" \
  -d "client_id=$BLOGGER_CLIENT_ID" \
  -d "client_secret=$BLOGGER_CLIENT_SECRET" \
  -d "refresh_token=$REFRESH_TOKEN" \
  -d "grant_type=refresh_token"
```

## 投稿済み記事

### 時給競争力シミュレーター
- **記事ID**: 8545276010312984829
- **投稿日**: 2026-02-01
- **URL**: http://onchange.blogspot.com/2026/02/blog-post.html
- **関連ツール**: https://hourlywage.pages.dev/hourlywage

## 記事作成ワークフロー

1. `blog-draft.html` に記事内容を作成
2. 画像はBloggerにアップロードしてURLを取得
3. Blogger APIまたは管理画面から投稿

## 注意事項

- APIキーは読み取り専用操作にのみ使用可能
- 投稿・更新・削除にはOAuth 2.0トークンが必要
- アクセストークンは1時間で期限切れ（リフレッシュトークンで更新）
- `.env` ファイルは絶対にコミットしない
