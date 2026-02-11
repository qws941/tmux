# PROJECT KNOWLEDGE BASE

**Generated:** 2026-02-11
**Commit:** 2c116d3
**Branch:** master

## OVERVIEW

Bash tmux configuration and session management toolkit. Symlinked as `~/.tmux`. Includes modular tmux config (`conf.d/`), fzf-powered session management (`bin/`), per-project layout templates (`layouts/`), and OpenCode AI multi-environment manager (`oc` service + `ocenv` shortcuts).

## STRUCTURE

```
tmux/
├── tmux.conf                # Modular loader: sources conf.d/*.conf
├── oc                       # OpenCode multi-env manager (anti/claude/co)
├── ocenv                    # Generic env shortcut (profile switch or attach)
├── claude / anti / co       # 2-line stubs → delegate to ocenv via OCENV_NAME
├── bin/
│   ├── tmux-sessionizer     # fzf session picker with LIVE preview
│   ├── tmux-auto-attach     # SSH auto-attach on login
│   ├── tmux-status-sessions # Clickable status bar session tabs
│   └── tmux-session-kill    # fzf multi-select session killer
├── conf.d/
│   ├── 00-core.conf         # Terminal, performance, mouse, scrollback
│   ├── 10-theme.conf        # Tokyo Night colors
│   ├── 20-keys.conf         # Keybindings (prefix=C-a)
│   └── 90-plugins.conf      # TPM init
├── layouts/                 # Per-project YAML: window/pane configs
│   ├── default.yml          # Single pane fallback
│   ├── resume.yml           # 3-pane: editor + terminal + dev-server
│   ├── proxmox.yml          # 3-pane + logs window
│   ├── splunk.yml           # 3-pane + test window
│   ├── blacklist.yml        # 3-pane + api window
│   └── safework.yml         # 3-pane + test window
├── systemd/
│   └── tmux-server.service  # User unit: persistent tmux server
└── data/
    └── in-memoria.db        # In-Memoria AI cache (binary, gitignored)
```

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Change keybindings | `conf.d/20-keys.conf` |
| Modify theme colors | `conf.d/10-theme.conf` |
| Tune performance | `conf.d/00-core.conf` |
| Add tmux plugin | `conf.d/90-plugins.conf` |
| Add project layout | `layouts/{project}.yml` |
| Fix session picker | `bin/tmux-sessionizer` |
| Fix status bar tabs | `bin/tmux-status-sessions` |
| OpenCode env management | `oc` (service), `ocenv` (shortcuts), `claude`/`anti`/`co` (stubs) |
| SSH auto-attach | `bin/tmux-auto-attach` + `~/.bashrc` integration |
| Systemd tmux service | `systemd/tmux-server.service` |

## CONVENTIONS

- **Prefix**: `C-a` (NOT default C-b)
- **escape-time 0**: CRITICAL for OpenCode TUI responsiveness. Never increase.
- **conf.d ordering**: Numbered prefixes control load order (00, 10, 20, 90)
- **Theme**: Tokyo Night consistently across tmux + fzf
  - bg=`#1a1b26` fg=`#a9b1d6` accent=`#7aa2f7`
  - fzf color string: `bg+:#292e42,fg:#a9b1d6,fg+:#c0caf5,hl:#bb9af7,hl+:#bb9af7,info:#7aa2f7,prompt:#7dcfff,pointer:#bb9af7,marker:#9ece6a,header:#565f89`
- **OpenCode envs**: 3 isolated environments with XDG separation
  - `anti` = Antigravity (:3011), `claude` = Direct Anthropic (:3012), `co` = Copilot (:3013)
- **Shortcuts pattern**: `claude`/`anti`/`co` are 2-line stubs that exec `ocenv` with `OCENV_NAME`. No args = switch config profile, with args = attach to `oc-{env}` session at `~/dev/$project`
- **Layout YMLs**: ASCII diagrams document pane arrangement in comments
- **Live session switching**: sessionizer uses `focus:execute-silent` to switch sessions while navigating fzf picker
- **Commit style**: Conventional commits (feat:, fix:, chore:, etc.)

## ANTI-PATTERNS

| Never | Why |
|-------|-----|
| Set `escape-time` > 0 | Breaks OpenCode TUI input responsiveness |
| Change fzf color scheme without updating ALL fzf calls | Tokyo Night must be consistent across sessionizer, session-kill, etc. |
| Hardcode password in `oc` scripts | `OPENCODE_SERVER_PASSWORD` must come from `.env` (gitignored) — never inline |
| Add conf.d files without numbered prefix | Breaks deterministic load order |
| Modify `data/in-memoria.db` | Binary AI cache, auto-generated |
| Skip `tmux source-file` after conf.d changes | Changes won't apply until reload |

## COMMANDS

| Key | Action |
|-----|--------|
| `prefix + r` | Reload tmux config |
| `prefix + f` | Open sessionizer popup (fzf picker) |
| `prefix + X` | Kill current session |
| `Alt + {1-9}` | Switch to window N (no prefix needed) |
| `prefix + \|` | Vertical split |
| `prefix + -` | Horizontal split |
| `prefix + h/j/k/l` | Navigate panes (vim-style) |

## NOTES

- **SSH integration**: `~/.bashrc` calls `tmux-auto-attach` on SSH login, which launches `tmux-sessionizer` if no session exists
- **Systemd service**: `tmux-server.service` (user unit, oneshot + RemainAfterExit) keeps tmux alive across logouts
- **Live preview**: sessionizer uses `tmux capture-pane -p -e` for ANSI-color live preview of sessions in fzf
- **Session scan paths**: `~/dev` + `~/.config/opencode` (hardcoded in sessionizer)
- **Status bar**: `tmux-status-sessions` generates clickable session tabs for status-right
- All scripts are extensionless bash — `#!/usr/bin/env bash` shebang
