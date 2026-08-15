#!/usr/bin/env bash
set ${SET_X:+-x} -eou pipefail
trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG
log() {
    echo "=== $* ==="
}

CONFIG="/usr/share/obsidian/malachite.json"

if [[ ! -f "$CONFIG" ]]; then
    echo "Warning: Malachite config not found at /usr/share/obsidian/malachite.json"
    exit 0
fi

IMAGES=$(jq -c '.images[]' "$CONFIG")

echo "Generating Malachite Desktop Launchers..."

mkdir -p /usr/share/applications

for img in $IMAGES; do
    NAME=$(echo "$img" | jq -r '.name')
    PRETTY=$(echo "$img" | jq -r '.pretty_name')

    cat <<DESK > "/usr/share/applications/malachite-$NAME.desktop"
[Desktop Entry]
Name=Malachite $PRETTY
Comment=Enter the $PRETTY-based Malachite distrobox
Exec=distrobox enter $NAME
Icon=utilities-terminal
Type=Application
Categories=Development;System;TerminalEmulator;
Terminal=true
Actions=Update;Recreate;Setup;

[Desktop Action Update]
Name=Update Container
Exec=ujust malachite-update $NAME
Terminal=true

[Desktop Action Recreate]
Name=Recreate (Wipe State)
Exec=ujust malachite-recreate $NAME
Terminal=true

[Desktop Action Setup]
Name=Setup / Replace
Exec=ujust malachite-setup $NAME
Terminal=true
DESK
    echo "Generated malachite-$NAME.desktop"
done

echo "Configuring Malachite Persistence (tmpfiles)..."

mkdir -p /usr/lib/tmpfiles.d
cat <<TMP > /usr/lib/tmpfiles.d/obsidian.conf
# Create persistent directories for Obsidian system data
d /var/lib/obsidian 0777 root root - -
TMP

echo "Malachite setup complete."
