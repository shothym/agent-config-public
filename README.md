## ホームディレクトリへ反映（Claude Code）

リポジトリの `.claude/skills/` と `.claude/agents/` を、**シンボリックリンク**で `~/.claude/` に反映します。

### Quick Start

1. terminal-notifier をインストール（Mac のみ。Linux は `notify-send` などを適宜インストールしてください）。
```
brew install terminal-notifier
```
2. `./scripts/install-claude-symlinks.sh` を実行して、シンボリックリンクを作成
    - settings.jsonに必要な項目はあらかじめ./.claude/settings.jsonに追加してから実行してください。（e.g. permissions, enabledPlugin, etc.）
3. mac側の設定でterminal-notifierからの通知を許可する。（設定 > 通知 > アプリケーションの通知 > terminal-notifier）

もし通知が鳴らない場合は、`terminal-notifier` コマンドが正しくインストールされているか、ターミナルから直接 `$HOMEBREW_PREFIX/bin/terminal-notifier -message "Test notification"` を実行してみてください。通知が表示されない場合は、Macの通知設定を確認し、ターミナルからの通知が許可されていることやコマンドのパスを確認してください。

### 設定の反映

```bash
./scripts/install-claude-symlinks.sh
```

- **スキル**: `.claude/skills/<name>/` のうち **`SKILL.md` があるディレクトリ**だけを列挙し、`~/.claude/skills/<name>` へリンクします。
- **エージェント**: `.claude/agents/*.md` を `~/.claude/agents/` へファイル単位でリンクします（`README.md` は除外）。
- リンク先は**絶対パス**です。
- `~/.claude/skills/<name>` または `~/.claude/agents/<file>.md` が**すでに通常ファイル／通常ディレクトリ**の場合は上書きせずエラーにします（手元のエージェントなどと名前が被ったときは退避してください）。

前提: Claude Code が `~/.claude/` 配下のスキル・エージェントを読み込むこと。

### 設定の削除

このリポジトリを指しているシンボリックリンクだけを削除します（中身が実ファイルのパスは削除しません）。

```bash
./scripts/uninstall-claude-symlinks.sh
```

## 参考資料
- https://code.claude.com/docs/en/sub-agents
- https://code.claude.com/docs/en/skills
- https://cursor.com/docs/context/skill
- https://agentskills.io/home
