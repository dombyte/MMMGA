#!/bin/bash -e
RC=''
RED=''
YELLOW=''
CYAN=''
GREEN=''


sudo -v

while true; do
    sudo -n true
    sleep 60
done 2>/dev/null &
KEEPALIVE_PID=$!


killpid() {
kill $KEEPALIVE_PID
}

brewprogram_exists() {
for cmd in "$@"; do
    brew list "$cmd" >/dev/null 2>&1 || return 1
done
return 0
}
command_exists() {
for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || return 1
done
return 0
}