#!/usr/bin/env bash
set ${SET_X:+-x} -eou pipefail
trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG
log() {
  echo "=== $* ==="
}

mkdir -p /etc/ublue-os

if [ -f /usr/share/ublue-os/topgrade.toml ]; then
  sed -i 's|^\(paths = \[.*\)\]|\1, "/etc/ublue-os/fp-topgrade.toml"]|' /usr/share/ublue-os/topgrade.toml || true
fi

cat <<EOF > /etc/ublue-os/fp-topgrade.toml
[commands]
"AppImage Updater" = "fp-appimage-updater update"
EOF