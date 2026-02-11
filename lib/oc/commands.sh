#!/bin/bash

cmd_start() {
    local env="$1"
    local session
    session="$(tmux_session_name "$env")"

    if is_running "$env"; then
        echo -e "${YELLOW}⚠${NC}  ${CYAN}$env${NC} already running (session: $session)"
        return 0
    fi

    ensure_xdg_dirs "$env"

    local env_vars
    env_vars=$(get_xdg_env "$env")

    local node_bin
    node_bin="$(dirname "$(which node)" 2>/dev/null || echo "$HOME/.nvm/versions/node/v22.22.0/bin")"

    tmux new-session -d -s "$session" \
        "$(echo "$env_vars" | tr '\n' ' ') \
        PATH=\"$node_bin:\$PATH\" \
        $OPENCODE_BIN serve --port ${PORTS[$env]} --hostname 127.0.0.1; \
        echo 'Process exited. Press Enter to close.'; read"

    sleep 1
    if is_running "$env"; then
        echo -e "${GREEN}✓${NC}  ${CYAN}$env${NC} started on port ${PORTS[$env]} (session: $session)"
    else
        echo -e "${RED}✗${NC}  ${CYAN}$env${NC} failed to start"
        return 1
    fi
}

cmd_stop() {
    local env="$1"
    local session
    session="$(tmux_session_name "$env")"

    if ! is_running "$env"; then
        echo -e "${DIM}·${NC}  ${CYAN}$env${NC} not running"
        return 0
    fi

    tmux kill-session -t "$session"
    echo -e "${GREEN}✓${NC}  ${CYAN}$env${NC} stopped"
}

cmd_restart() {
    local env="$1"
    cmd_stop "$env"
    sleep 1
    cmd_start "$env"
}

cmd_status() {
    echo -e "${BOLD}OpenCode Instances${NC}"
    echo -e "${DIM}─────────────────────────────────────────${NC}"

    local current_profile
    current_profile=$(cat "$OPENCODE_CONFIG_DIR/.current-profile" 2>/dev/null || echo "unknown")

    for env in "${ENVS[@]}"; do
        local session port status_icon status_text pid_info
        session="$(tmux_session_name "$env")"
        port="${PORTS[$env]}"

        if is_running "$env"; then
            status_icon="${GREEN}●${NC}"
            status_text="running"
            pid_info=$(lsof -ti "tcp:$port" 2>/dev/null | head -1)
            [[ -n "$pid_info" ]] && status_text="running (pid:$pid_info)"
        else
            status_icon="${RED}○${NC}"
            status_text="stopped"
        fi

        local active_marker=""
        [[ "$env" == "$current_profile" ]] && active_marker=" ${YELLOW}★${NC}"

        printf "  %b  %-8s  :%s  %-24s  %s%b\n" \
            "$status_icon" "$env" "$port" "$status_text" "$session" "$active_marker"
    done

    echo ""
    echo -e "${DIM}Active profile: ${NC}${CYAN}$current_profile${NC}"
    echo -e "${DIM}★ = current shared config${NC}"
}

cmd_logs() {
    local env="$1"
    local session
    session="$(tmux_session_name "$env")"

    if ! is_running "$env"; then
        echo -e "${RED}Error:${NC} $env is not running"
        return 1
    fi

    echo -e "${DIM}Attaching to $session... (Ctrl-b d to detach)${NC}"
    tmux attach-session -t "$session"
}

cmd_switch() {
    local env="$1"

    if [[ -x "$BIN_DIR/$env" ]]; then
        "$BIN_DIR/$env"
    else
        echo -e "${RED}Error:${NC} No switcher script for '$env'"
        return 1
    fi

    if is_running "$env"; then
        echo -e "${DIM}Restarting $env...${NC}"
        cmd_restart "$env"
    fi
}

cmd_health() {
    echo -e "${BOLD}OpenCode Health Check${NC}"
    echo -e "${DIM}─────────────────────────────────────────${NC}"

    local all_ok=true
    for env in "${ENVS[@]}"; do
        local port="${PORTS[$env]}"
        local tmux_ok=false port_ok=false

        is_running "$env" && tmux_ok=true
        curl -sf -o /dev/null --connect-timeout 2 "http://127.0.0.1:$port" 2>/dev/null && port_ok=true

        if $tmux_ok && $port_ok; then
            echo -e "  ${GREEN}✓${NC}  ${CYAN}$env${NC}  tmux:${GREEN}ok${NC}  port:${GREEN}$port${NC}"
        elif $tmux_ok && ! $port_ok; then
            echo -e "  ${YELLOW}⚠${NC}  ${CYAN}$env${NC}  tmux:${GREEN}ok${NC}  port:${RED}$port unresponsive${NC}"
            all_ok=false
        elif ! $tmux_ok && $port_ok; then
            echo -e "  ${YELLOW}⚠${NC}  ${CYAN}$env${NC}  tmux:${RED}dead${NC}  port:${GREEN}$port (orphan?)${NC}"
            all_ok=false
        else
            echo -e "  ${DIM}·${NC}  ${CYAN}$env${NC}  ${DIM}stopped${NC}"
        fi
    done

    echo ""
    $all_ok && echo -e "  ${GREEN}All healthy${NC}" || echo -e "  ${YELLOW}Issues detected${NC}"
}

cmd_logs_rotate() {
    local env="$1"
    local session logfile
    session="$(tmux_session_name "$env")"

    if ! is_running "$env"; then
        echo -e "${DIM}·${NC}  ${CYAN}$env${NC} not running (skip rotate)"
        return 0
    fi

    mkdir -p "$LOG_DIR"
    logfile="$LOG_DIR/${env}-$(date +%Y%m%d).log"

    tmux capture-pane -t "$session" -p -S - > "$logfile"
    find "$LOG_DIR" -type f -name "${env}-*.log" -mtime +7 -delete

    echo -e "${GREEN}✓${NC}  ${CYAN}$env${NC} logs rotated -> $logfile"
}
