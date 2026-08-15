#!/usr/bin/env bash
set ${SET_X:+-x} -eou pipefail
trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG
log() {
  echo "=== $* ==="
}

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://quay.io/fptbb/obsidian"
IMAGE_TAG="latest"
IMAGE_BRANCH="latest"

if [[ -f "$IMAGE_INFO" ]]; then
    sed -i 's/"image-name": [^,]*/"image-name": "'"obsidian"'"/' $IMAGE_INFO
    sed -i 's/"image-vendor": [^,]*/"image-vendor": "'"fptbb"'"/' $IMAGE_INFO
    sed -i 's|"image-tag": [^,]*|"image-tag": "'"$IMAGE_TAG"'"|' $IMAGE_INFO
    sed -i 's|"image-branch": [^,]*|"image-branch": "'"$IMAGE_BRANCH"'"|' $IMAGE_INFO
    sed -i 's|"version-pretty": "Stable (F\([^"]*\))"|"version-pretty": "Latest (Alma 10)"|' $IMAGE_INFO
    sed -i 's|"image-ref": [^,]*|"image-ref": "'"$IMAGE_REF"'"|' $IMAGE_INFO
fi

YAFTI_CONFIG="/usr/share/yafti/yafti.yml"

if [[ -f "$YAFTI_CONFIG" ]]; then
  sed -i 's/^title: Bazzite Portal/title: System Utilities/' "$YAFTI_CONFIG"

  sed -i '/^screens:/a\
  - title: "Obsidian Utilities"\
    description: "Obsidian-specific installers and maintenance tools"\
    actions:\
      - id: "obsidian-themes"\
        title: "Obsidian Themes"\
        description: "Installs Catppuccin, Kora, and PlasMusic."\
        default: false\
        script: "ujust obsidian-manage-themes"\
      - id: "obsidian-nixpkgs"\
        title: "Install Nix"\
        description: "Installs the Nix package manager."\
        default: false\
        script: "ujust obsidian-nixpkgs"\
      - id: "obsidian-devbox"\
        title: "Install DevBox"\
        description: "Installs DevBox for disposable development environments."\
        default: false\
        script: "ujust obsidian-devbox"\
      - id: "dotfiles-update"\
        title: "Update Dotfiles"\
        description: "Pulls dotfiles changes from the repo and applies them locally. This can overwrite or remove local files."\
        default: false\
        script: "ujust dotfiles-update"\
      - id: "dotfiles-apply"\
        title: "Apply Dotfiles"\
        description: "Applies the repo state to this system. This can overwrite or remove local files."\
        default: false\
        script: "ujust dotfiles-apply"\
      - id: "dotfiles-status"\
        title: "Dotfiles Status"\
        description: "Shows what files are currently changed before syncing or applying."\
        default: false\
        script: "ujust dotfiles-status"\
      - id: "dotfiles-diff"\
        title: "Dotfiles Diff"\
        description: "Shows the exact line-by-line changes before syncing or applying."\
        default: false\
        script: "ujust dotfiles-diff"\
      - id: "dotfiles-sync"\
        title: "Sync Dotfiles"\
        description: "Pushes local computer changes into the dotfiles repo. Check status and diff first to avoid syncing unwanted changes."\
        default: false\
        script: "ujust dotfiles-sync"\
      - id: "obsidian-gpg-reload"\
        title: "Reload GPG Stack"\
        description: "Restarts the smartcard and GPG services."\
        default: false\
        script: "ujust obsidian-gpg-reload"\
' "$YAFTI_CONFIG"
fi

# Icon replacements
mkdir -p /usr/share/icons/hicolor/scalable/apps/
mkdir -p /usr/share/icons/hicolor/scalable/places/

if [[ -f /usr/share/pixmaps/fp-logo.svg ]]; then
    ln -sf /usr/share/pixmaps/fp-logo.svg /usr/share/icons/hicolor/scalable/apps/obsidian-logo-icon.svg 2>/dev/null || true
    ln -sf /usr/share/pixmaps/fp-logo.svg /usr/share/icons/hicolor/scalable/places/distributor-logo.svg 2>/dev/null || true
fi

log "Branding setup for Obsidian completed."
