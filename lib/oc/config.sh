#!/bin/bash

OPENCODE_BIN="/home/jclee/.opencode/bin/opencode"
OPENCODE_CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"

ENV_FILE="${SCRIPT_DIR}/.env"
if [[ -f "$ENV_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$ENV_FILE"
fi
: "${OPENCODE_SERVER_PASSWORD:?Error: OPENCODE_SERVER_PASSWORD not set. Copy .env.example to .env}"
BIN_DIR="$OPENCODE_CONFIG_DIR/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

declare -A PORTS=( [anti]=3011 [claude]=3012 [co]=3013 )
declare -A XDG_PREFIX=( [anti]=opencode-wt-anti [claude]=opencode-wt-claude [co]=opencode-wt-copilot )
ENVS=(anti claude co)

LOG_DIR="${SCRIPT_DIR}/logs/oc"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'
