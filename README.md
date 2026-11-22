# dots

My dotfiles, kept in one place so a new machine is quick to set up. The repo is public, so it holds no secrets, tokens, or private endpoints. Anything like that lives in a local file that is gitignored.

## Layout

| Path | Goes to | What it is |
| --- | --- | --- |
| `claude/settings.json` | `~/.claude/settings.json` | Claude Code model, status line, plugins, marketplaces, theme |
| `claude/statusline.ps1` | `~/.claude/statusline.ps1` | Status line: model, context, cache, branch, PR, rate limits |
| `claude/ponytail-statusline.ps1` | `~/.claude/ponytail-statusline.ps1` | Shows the active ponytail mode in the status line |
| `git/.gitconfig` | `~/.gitconfig` | Git identity and Git LFS filter |
| `gh/config.yml` | `%APPDATA%\GitHub CLI\config.yml` | GitHub CLI preferences (no tokens; log in with `gh auth login`) |
| `vscode/settings.json` | `%APPDATA%\Code\User\settings.json` | VS Code settings |
| `vscode/extensions.txt` | (reference) | VS Code extensions with versions |
| `windows-terminal/settings.json` | Windows Terminal `LocalState\settings.json` | Profiles, keys, default profile |
| `opencode/` | `~/.config/opencode/` | opencode CLI, TUI config, and plugins |
| `herdr/config.toml` | `%APPDATA%\herdr\config.toml` | herdr config |

## Claude Code

Enabled plugins are listed in `claude/settings.json`. Claude Code installs them on first run:

- `ponytail@ponytail` (marketplace: `DietrichGebert/ponytail`)
- `superpowers@claude-plugins-official`
- `mattpocock-skills@claude-plugins-official`

The API endpoint, auth token, and model overrides are not in this repo. Put them in `~/.claude/settings.local.json` on each machine:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "<your endpoint>",
    "ANTHROPIC_AUTH_TOKEN": "<your key>"
  }
}
```

`*.local.json` is in `.gitignore`.

## Install (Windows, PowerShell)

```powershell
# Claude Code
Copy-Item claude\statusline.ps1, claude\ponytail-statusline.ps1 $HOME\.claude\
Copy-Item claude\settings.json $HOME\.claude\settings.json   # merge with your existing file if you have one

# VS Code extensions
Get-Content vscode\extensions.txt | ForEach-Object { code --install-extension ($_ -replace '@.*') }
```

`claude/settings.json` runs the status line through `%USERPROFILE%`. If your shell does not expand that, replace it with the full path to `statusline.ps1`.

The other files go to the locations listed in the table above. Copy them over, or merge them with your existing config.

## Ideas for later

Found on this machine but not added yet:

- **PowerToys** (`AppData/Local/Microsoft/PowerToys`): FancyZones, Awake, and other module settings. Probably want to check the per-module JSON files for anything machine-specific first.
- **Godot** (`AppData/Roaming/Godot/editor_settings-4.7.tres`): editor settings. `projects.cfg` and `recent_dirs` are project-specific, so skip those.
- **KiCad** (`AppData/Roaming/KiCad/10.0`): preferences and library tables. Check for absolute paths before adding.
- **Docker** (`.docker/daemon.json`, `windows-daemon.json`): small, no secrets. Skip `config.json`, which has registry credentials.
- **npm and pnpm**: `~/.npmrc` has an auth token, so it can only go in once the token is removed. Also check whether a pnpm config file exists.
- **Python**: no `pip.ini` found yet.
- **PowerShell profile**: none exists on this machine. Worth creating one and adding it to the repo.
- **Shell and editor configs**: no `.bashrc`, `.vimrc`, Neovim, or Starship config was found.

Skipped on purpose: Obsidian's `AppData/Roaming/obsidian` (Electron session data, not config), runtime folders, logs, and databases.
