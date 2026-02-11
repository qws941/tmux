#!/bin/bash

tmux_session_name() { echo "oc-$1"; }

is_running() {
    tmux has-session -t "$(tmux_session_name "$1")" 2>/dev/null
}

get_xdg_env() {
    local env="$1"
    local prefix="${XDG_PREFIX[$env]}"
    cat <<EOF
XDG_CONFIG_HOME=$HOME/.config/$prefix
XDG_DATA_HOME=$HOME/.local/share/$prefix
XDG_CACHE_HOME=$HOME/.cache/$prefix
XDG_STATE_HOME=$HOME/.local/state/$prefix
OPENCODE_PORT=${PORTS[$env]}
OPENCODE_SERVER_PASSWORD=$OPENCODE_SERVER_PASSWORD
EOF
}

ensure_xdg_dirs() {
    local env="$1"
    local prefix="${XDG_PREFIX[$env]}"
    mkdir -p "$HOME/.config/$prefix" \
             "$HOME/.local/share/$prefix" \
             "$HOME/.cache/$prefix" \
             "$HOME/.local/state/$prefix"

    local src="$OPENCODE_CONFIG_DIR/oh-my-opencode.json.$env"
    local dst="$HOME/.config/$prefix/oh-my-opencode.jsonc"
    if [[ -f "$src" ]]; then
        cp "$src" "$dst"
    fi

    local main_cfg="$OPENCODE_CONFIG_DIR/opencode.jsonc"
    local dst_main="$HOME/.config/$prefix/opencode.jsonc"
    if [[ -f "$main_cfg" ]] && [[ "$(readlink -f "$main_cfg")" != "$(readlink -f "$dst_main" 2>/dev/null)" ]]; then
        cp -u "$main_cfg" "$dst_main"
    fi
}

validate_env() {
    local env="$1"
    if [[ -z "${PORTS[$env]+x}" ]]; then
        echo -e "${RED}Error:${NC} Unknown environment '$env'. Use: co, claude, anti"
        exit 1
    fi
}

usage() {
    echo "Usage: oc <command> [env]"
    echo ""
    echo "Commands:"
    echo "  start       [co|claude|anti|all]  Start opencode serve in tmux"
    echo "  stop        [co|claude|anti|all]  Stop tmux session"
    echo "  restart     [co|claude|anti|all]  Stop + start"
    echo "  status                            Show all instances"
    echo "  health                            Port + tmux health check"
    echo "  logs        [co|claude|anti]      Attach to tmux session"
    echo "  rotate-logs [co|claude|anti|all]  Capture and rotate tmux logs"
    echo "  switch      <co|claude|anti>      Switch config + restart"
    echo ""
    echo "Environments:"
    echo "  co      GitHub Copilot    :3013"
    echo "  claude  Direct Anthropic  :3012"
    echo "  anti    Antigravity       :3011"
}
