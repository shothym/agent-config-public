# Code Review 出力例

このファイルは `code-review` Skill の期待される出力形式を示す。レビュー時はこのフォーマットに沿ってフィードバックを返す。

## 例: 関数のレビュー

```markdown
## Critical

### 1. SQLインジェクションの可能性
- **場所**: `src/user/repository.go:42`
- **内容**: ユーザー入力を直接 SQL に結合している
- **修正例**:
  ```go
  // Before
  query := fmt.Sprintf("SELECT * FROM users WHERE id = '%s'", userInput)

  // After
  row := db.QueryRow("SELECT * FROM users WHERE id = $1", userInput)
  ```

## Warning

### 2. エラーハンドリングの欠如
- **場所**: `src/user/repository.go:55`
- **内容**: エラーを握りつぶしている
- **修正例**: `if err != nil { return fmt.Errorf("fetch user: %w", err) }`

## Suggestion

### 3. 変数名の明確化
- **場所**: `src/user/repository.go:12`
- **内容**: `d` よりも `db` のほうが意図が伝わる
```

## 例: 複数ファイルのレビュー

対象が複数ファイルの場合、ファイル単位でセクションを分ける。各セクション内では上記の Critical / Warning / Suggestion の順で記載する。
