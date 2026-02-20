# PROJECT KNOWLEDGE BASE

**Generated:** 2026-02-21
**Commit:** 055788d
**Branch:** master

## OVERVIEW

Bash tmux configuration and session management toolkit. Symlinked as `~/.tmux`. Includes modular tmux config (`conf.d/`), fzf-powered session management (`bin/`), per-project layout templates (`layouts/`), and systemd-managed persistent server.

## STRUCTURE

```
tmux/
├── tmux.conf                # Modular loader: sources conf.d/*.conf
├── sessionizer.conf         # SCAN_DIR + EXTRA_DIRS for session picker
├── bin/
│   ├── tmux-sessionizer     # fzf session picker + creation wizard
│   ├── tmux-layout-apply    # YAML layout → tmux panes/windows
│   ├── tmux-auto-attach     # SSH auto-attach on login
│   ├── tmux-responsive      # Hook-based responsive statusbar (3 tiers)
│   ├── tmux-session-cycle   # PgUp/PgDn session cycling
│   ├── tmux-session-kill    # fzf multi-select session killer
│   ├── tmux-session-rename  # Rename session from fzf
│   ├── tmux-session-order   # Session ordering helper
│   ├── tmux-session-sync    # Sync sessions with ~/dev dirs
│   ├── tmux-sidebar         # Sidebar pane renderer
│   ├── tmux-sidebar-init    # Sidebar creation on session start
│   ├── tmux-sidebar-toggle  # Toggle sidebar visibility
│   ├── tmux-git-status      # Git branch/status for statusbar
│   └── tmux-sys-stats       # CPU/mem stats for statusbar
├── conf.d/
│   ├── 00-core.conf         # Terminal, performance, mouse, scrollback
│   ├── 10-theme.conf        # Tokyo Night colors
│   ├── 20-keys.conf         # Keybindings (prefix=C-a)
│   ├── 30-statusbar.conf    # Dual status bar + responsive hook
│   └── 90-plugins.conf      # TPM + resurrect + continuum
├── layouts/                 # Per-project YAML: window/pane configs
│   ├── default.yml          # Single pane fallback
│   ├── resume.yml           # 3-pane: editor + terminal + dev-server
│   ├── proxmox.yml          # 3-pane + logs window
│   ├── splunk.yml           # 3-pane + test window
│   ├── blacklist.yml        # 3-pane + api window
│   ├── safework.yml         # 3-pane + test window
│   └── safework2.yml        # Variant layout
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
| Fix statusbar | `conf.d/30-statusbar.conf` + `bin/tmux-responsive` |
| Fix sidebar | `bin/tmux-sidebar` + `bin/tmux-sidebar-init` |
| SSH auto-attach | `bin/tmux-auto-attach` + `~/.bashrc` integration |
| Systemd tmux service | `systemd/tmux-server.service` |
| Session scan config | `sessionizer.conf` |

## CONVENTIONS

- **Prefix**: `C-a` (NOT default C-b)
- **escape-time 0**: CRITICAL for TUI responsiveness. Never increase.
- **conf.d ordering**: Numbered prefixes control load order (00, 10, 20, 30, 90)
- **Theme**: Tokyo Night consistently across tmux + fzf
  - bg=`#1a1b26` fg=`#a9b1d6` accent=`#7aa2f7`
  - fzf color string: `bg+:#292e42,fg:#a9b1d6,fg+:#c0caf5,hl:#bb9af7,hl+:#bb9af7,info:#7aa2f7,prompt:#7dcfff,pointer:#bb9af7,marker:#9ece6a,header:#565f89`
- **Layout auto-apply**: sessionizer → `tmux-layout-apply` matches `layouts/{session_name}.yml`, falls back to `default.yml`
- **Layout YMLs**: ASCII diagrams document pane arrangement in comments
- **Live session switching**: sessionizer uses `focus:execute-silent` to switch sessions while navigating fzf picker
- **Responsive statusbar**: 3 tiers (minimal <40, compact 40-79, normal >=80 cols), triggered by `client-resized` hook
- **Session persistence**: Manual save/restore (prefix+S/R). Auto-restore on tmux server start. Auto-save disabled.
- **Commit style**: Conventional commits (feat:, fix:, chore:, etc.)

## ANTI-PATTERNS

| Never | Why |
|-------|-----|
| Set `escape-time` > 0 | Breaks TUI input responsiveness |
| Change fzf color scheme without updating ALL fzf calls | Tokyo Night must be consistent across sessionizer, session-kill, etc. |
| Add conf.d files without numbered prefix | Breaks deterministic load order |
| Modify `data/in-memoria.db` | Binary AI cache, auto-generated |
| Skip `tmux source-file` after conf.d changes | Changes won't apply until reload |
| Commit `.env` | Contains secrets — gitignored |

## COMMANDS

| Key | Action |
|-----|--------|
| `prefix + r` | Reload tmux config |
| `prefix + f` or `prefix + +` | Open sessionizer popup (fzf picker) |
| `prefix + X` | Kill current session |
| `prefix + S` | Manual session save (resurrect) |
| `prefix + R` | Manual session restore (resurrect) |
| `prefix + L` | Toggle last session |
| `F1-F5` | Switch to window 1-5 (no prefix needed) |
| `PgUp / PgDn` | Cycle sessions prev/next (no prefix needed) |
| `prefix + \|` | Vertical split |
| `prefix + -` | Horizontal split |
| `Alt + Left/Right` | Navigate panes (no prefix needed) |

## NOTES

- **SSH integration**: `~/.bashrc` calls `tmux-auto-attach` on SSH login, which launches `tmux-sessionizer` if no session exists
- **Systemd service**: `tmux-server.service` (user unit, oneshot + RemainAfterExit) keeps tmux alive across logouts
- **Live preview**: sessionizer uses `tmux capture-pane -p -e` for ANSI-color live preview of sessions in fzf
- **Session scan paths**: `~/dev` (configured in `sessionizer.conf`)
- **Dual status bar**: Line 0 = window tabs + git/sys-stats, Line 1 = clickable session tabs + "+" button
- All scripts are extensionless bash — `#!/usr/bin/env bash` shebang
- **Continuum**: auto-save disabled (`@continuum-save-interval '0'`), auto-restore on start enabled
