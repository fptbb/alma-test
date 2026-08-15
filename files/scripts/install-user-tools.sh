#!/usr/bin/env bash
set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG
log() {
  echo "=== $* ==="
}

DEST_DIR="${1:-/usr/bin}"

log "Installing user tools dynamically from latest release binaries to $DEST_DIR..."

mkdir -p "$DEST_DIR"

DEST_DIR="$DEST_DIR" python3 -c '
import urllib.request, urllib.parse, json, os, tarfile, io

dest_dir = os.environ.get("DEST_DIR", "/usr/bin")

def install_gitlab_latest(project, asset_map):
    encoded = urllib.parse.quote(project, safe="")
    url = f"https://gitlab.com/api/v4/projects/{encoded}/releases"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req) as resp:
        releases = json.loads(resp.read().decode())
    if not releases:
        raise RuntimeError(f"No releases found for {project}")
    latest = releases[0]
    tag = latest.get("tag_name")
    print(f"[{project}] Latest tag: {tag}")
    links = {link["name"]: link["url"] for link in latest.get("assets", {}).get("links", [])}
    
    for asset_name, binary_name in asset_map.items():
        dest_path = os.path.join(dest_dir, binary_name)
        if asset_name not in links:
            matched = [k for k in links.keys() if asset_name.replace("-static", "") in k or k.replace("-static", "") in asset_name]
            if matched:
                asset_name = matched[0]
            else:
                raise RuntimeError(f"Asset {asset_name} not found in release {tag} of {project}. Available: {list(links.keys())}")
        dl_url = links[asset_name]
        print(f"Downloading {asset_name} -> {dest_path}...")
        dl_req = urllib.request.Request(dl_url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(dl_req) as dl_resp:
            content = dl_resp.read()
        os.makedirs(os.path.dirname(dest_path), exist_ok=True)
        with open(dest_path, "wb") as f:
            f.write(content)
        os.chmod(dest_path, 0o755)
        print(f"Successfully installed {dest_path} ({len(content)} bytes)")

def install_github_tar_latest(repo, binary_name):
    url = f"https://api.github.com/repos/{repo}/releases/latest"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req) as resp:
        release = json.loads(resp.read().decode())
    tag = release.get("tag_name")
    print(f"[{repo}] Latest tag: {tag}")
    dl_url = None
    for asset in release.get("assets", []):
        if "linux" in asset["name"] and "amd64" in asset["name"]:
            dl_url = asset["browser_download_url"]
            break
    if not dl_url:
        raise RuntimeError(f"No suitable linux amd64 asset found for {repo}")
    
    dest_path = os.path.join(dest_dir, binary_name)
    print(f"Downloading {dl_url} -> {dest_path}...")
    dl_req = urllib.request.Request(dl_url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(dl_req) as dl_resp:
        archive_data = dl_resp.read()
    
    with tarfile.open(fileobj=io.BytesIO(archive_data), mode="r:*") as tar:
        member = None
        for m in tar.getmembers():
            if os.path.basename(m.name) == binary_name:
                member = m
                break
        if not member:
            raise RuntimeError(f"Binary {binary_name} not found in archive")
        f = tar.extractfile(member)
        content = f.read()
        with open(dest_path, "wb") as out:
            out.write(content)
        os.chmod(dest_path, 0o755)
        print(f"Successfully extracted and installed {dest_path} ({len(content)} bytes)")

install_gitlab_latest("fpsys/fp-appimage-updater", {
    "fp-appimage-updater.x64-musl": "fp-appimage-updater"
})

install_gitlab_latest("fpsys/fp-dotfiles-manager", {
    "fp-dotfiles-manager-static": "fp-dotfiles-manager",
    "fp-dotfiles-tui-static": "fp-dotfiles-tui"
})

install_gitlab_latest("fpsys/fp-no-dash", {
    "fp-no-dash": "fp-no-dash"
})

try:
    install_github_tar_latest("doy/rbw", "rbw")
except Exception as e:
    print(f"Warning: Failed to install rbw from GitHub: {e}")
'

log "User tools binary installation completed successfully!"
