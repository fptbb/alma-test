export project_root := `git rev-parse --show-toplevel`
export git_branch := `git branch --show-current`

username := "fptbb"
image_name := "obsidian"
image_tag := "latest"
online_image := "quay.io/fptbb/obsidian:latest"
payload_ref := "localhost/payload:latest"
iso_dest := "obsidian-live-amd64.iso"

_default:
    @just --list

generate:
    #!/usr/bin/bash
    bluebuild generate ./recipes/recipe.yml -o Containerfile

validate:
    #!/usr/bin/bash
    bluebuild validate

prune:
    #!/usr/bin/bash
    bluebuild prune

build:
    #!/usr/bin/bash
    bluebuild build ./recipes/recipe.yml

build-installer:
    #!/usr/bin/bash
    sudo bluebuild generate-iso --iso-name obsidian-installer.iso recipe recipes/recipe.yml

format-justfiles:
    #!/usr/bin/bash
    just --fmt --unstable ./files/justfiles/
    echo "Justfiles formatted."
