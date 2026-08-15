#!/usr/bin/env bash
set ${SET_X:+-x} -eou pipefail
trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG
log() {
  echo "=== $* ==="
}

log "Installing Netbird"

# adds the official netbird repository
cat <<EOF > /etc/yum.repos.d/netbird.repo
[netbird]
name=netbird
baseurl=https://pkgs.netbird.io/yum/
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-netbird
EOF

# imports the gpg key to allow local validation
if [ -f /etc/pki/rpm-gpg/RPM-GPG-KEY-netbird ]; then
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-netbird
fi

# installs the packages while blocking the failing post-transaction systemd hooks
dnf install -y --setopt=tsflags=noscripts netbird netbird-ui

log "Creating systemd service for Netbird"

cat <<EOF > /usr/lib/systemd/system/netbird.service
[Unit]
Description=NetBird Daemon
Documentation=https://netbird.io/docs
After=network-online.target syslog.target NetworkManager.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/netbird service run --config /etc/netbird/config.json --log-file /var/log/netbird/client.log
Restart=on-failure
RestartSec=5
TimeoutStopSec=10

CacheDirectory=netbird
LogsDirectory=netbird
RuntimeDirectory=netbird
StateDirectory=netbird

[Install]
WantedBy=multi-user.target
EOF

log "Enabling Netbird service"

mkdir -p /usr/lib/systemd/system/multi-user.target.wants
ln -sf ../netbird.service /usr/lib/systemd/system/multi-user.target.wants/netbird.service

log "Netbird installation complete."