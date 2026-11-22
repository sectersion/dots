# dots

My dotfiles. Public, so nothing secret goes in here.

## Claude Code (`claude/`)

| File | Goes to | What it is |
| --- | --- | --- |
| `claude/settings.json` | `~/.claude/settings.json` | Model, statusline, plugins, marketplaces, theme |
| `claude/statusline.ps1` | `~/.claude/statusline.ps1` | Status line: model, context, cache, branch, PR, rate limits |
| `claude/ponytail-statusline.ps1` | `~/.claude/ponytail-statusline.ps1` | Shows the active ponytail mode in the status line |

### Plugins

Enabled through `settings.json`. Claude Code installs them on first run:

- `ponytail@ponytail` (marketplace: `DietrichGebert/ponytail`)
- `superpowers@claude-plugins-official`
- `mattpocock-skills@claude-plugins-official`

### Secrets and machine-specific values (not in this repo)

The API base URL, auth token and model overrides are kept out of the repo on purpose. Put them in `~/.claude/settings.local.json` on each machine:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "<your endpoint>",
    "ANTHROPIC_AUTH_TOKEN": "<your key>"
  }
}
```

`*.local.json` is in `.gitignore`.

### Install (Windows, PowerShell)

```powershell
Copy-Item claude\statusline.ps1, claude\ponytail-statusline.ps1 $HOME\.claude\
Copy-Item claude\settings.json $HOME\.claude\settings.json   # merge with your existing file if you have one
```

`settings.json` runs the status line through `%USERPROFILE%`. If your shell does not expand that, replace it with the full path to `statusline.ps1`.

## Other tools

| Path | Goes to | What it is |
| --- | --- | --- |
| `git/.gitconfig` | `~/.gitconfig` | Git identity and Git LFS filter |
| `gh/config.yml` | `%APPDATA%\GitHub CLI\config.yml` | GitHub CLI preferences (no tokens; log in with `gh auth login`) |
| `vscode/settings.json` | `%APPDATA%\Code\User\settings.json` | VS Code settings |
| `vscode/extensions.txt` | (reference) | Installed VS Code extensions with versions. Install with `Get-Content vscode\extensions.txt \| ForEach-Object { code --install-extension ($_ -replace '@.*') }` |
| `windows-terminal/settings.json` | Windows Terminal `LocalState\settings.json` | Windows Terminal profiles and keys |
| `opencode/` | `~/.config/opencode/` | opencode CLI and TUI config and plugins |
| `herdr/config.toml` | `%APPDATA%\herdr\config.toml` | herdr config |
