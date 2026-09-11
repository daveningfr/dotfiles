#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
backup_root="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
install_packages=true

if [[ "${1:-}" == "--no-packages" ]]; then
    install_packages=false
fi

if [[ "$install_packages" == true ]]; then
    if ! command -v yay >/dev/null 2>&1; then
        printf 'yay is required to install requirements.txt.\n' >&2
        printf 'Install yay first, or rerun with --no-packages.\n' >&2
        exit 1
    fi

    mapfile -t packages < <(awk '!/^[[:space:]]*(#|$)/ { print $1 }' "$repo_root/requirements.txt")
    yay -S --needed "${packages[@]}"
fi

link_item() {
    local source="$1"
    local target="$2"

    if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then
        return
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p "$backup_root"
        mv -- "$target" "$backup_root/"
        printf 'Backed up %s\n' "$target"
    fi

    mkdir -p "$(dirname -- "$target")"
    ln -s -- "$source" "$target"
    printf 'Linked %s\n' "$target"
}

for path in "$repo_root/.config"/*; do
    [[ -e "$path" ]] || continue
    link_item "$path" "$HOME/.config/$(basename -- "$path")"
done

for path in "$repo_root/.local/bin"/*; do
    [[ -e "$path" ]] || continue
    link_item "$path" "$HOME/.local/bin/$(basename -- "$path")"
done

link_item "$repo_root/.zshrc" "$HOME/.zshrc"
link_item "$repo_root/.p10k.zsh" "$HOME/.p10k.zsh"

printf 'Dotfiles installed from %s\n' "$repo_root"
[[ -d "$backup_root" ]] && printf 'Backups stored in %s\n' "$backup_root"
