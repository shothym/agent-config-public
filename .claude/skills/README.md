# Skills

Claude Code がプロジェクト内で利用する Skill を管理するディレクトリです。

## いつ使うか

- コードの説明・レビューを定型化したいとき
- バックエンド寄りの機能開発を手順付きで進めたいとき（`backend-feature-builder`）
- デプロイやテストなど、ワークフローをスラッシュコマンド化したいとき
- プロジェクト固有の知識（API規約、命名規則など）を Skill としてまとめたいとき

## どこを編集するか

- `*/SKILL.md` - メインの指示と frontmatter
- `*/examples.md` - 利用例・期待される出力形式
- `*/scripts/` - Skill から実行する補助スクリプト
- 新規 Skill は `mkdir .claude/skills/<skill-name>` でディレクトリを作成し、`SKILL.md` を配置

## 参照

- [Skills documentation](https://code.claude.com/docs/en/skills)
