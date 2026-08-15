#!/usr/bin/env bash
set ${SET_X:+-x} -eou pipefail
trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG
log() {
    echo "=== $* ==="
}

log "Setting up default wallpapers for Obsidian LTS."

mkdir -p /usr/share/backgrounds /usr/share/wallpapers

if [ -d /usr/share/wallpapers/Fox1 ]; then
    ln -sf /usr/share/wallpapers/Fox1/contents/images/2560x1080.jxl /usr/share/backgrounds/default.jxl 2>/dev/null || true
    ln -sf /usr/share/wallpapers/Fox1/contents/images_dark/2560x1080.jxl /usr/share/backgrounds/default-dark.jxl 2>/dev/null || true
    ln -sf /usr/share/wallpapers/Fox1/contents/images_dark/2560x1080.jxl /usr/share/wallpapers/convergence.jxl 2>/dev/null || true
fi

if [ -f /usr/share/wallpapers/fox.png ]; then
    ln -sf /usr/share/wallpapers/fox.png /usr/share/wallpapers/convergence.png 2>/dev/null || true
fi

log "Wallpaper configuration complete."