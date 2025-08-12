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

