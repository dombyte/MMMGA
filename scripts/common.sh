#!/bin/bash -e
RC=''
RED=''
YELLOW=''
CYAN=''
GREEN=''


command_exists() {
for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || return 1
done
return 0
}

brewprogram_exists() {
for cmd in "$@"; do
    brew list "$cmd" >/dev/null 2>&1 || return 1
done
return 0
}

setup_askpass() {
    # Create a temporary askpass helper script
    ASKPASS_SCRIPT="/tmp/mmmga_askpass_$$"
    cat > "$ASKPASS_SCRIPT" << 'EOF'
#!/bin/sh
osascript -e 'display dialog "Administrator password required for MMMGA setup:" default answer "" with hidden answer' -e 'text returned of result' 2>/dev/null
EOF
    chmod +x "$ASKPASS_SCRIPT"
    export SUDO_ASKPASS="$ASKPASS_SCRIPT"
}

cleanup_askpass() {
    # Clean up the temporary askpass script
    if [ -n "$ASKPASS_SCRIPT" ] && [ -f "$ASKPASS_SCRIPT" ]; then
        rm -f "$ASKPASS_SCRIPT"
    fi
}
