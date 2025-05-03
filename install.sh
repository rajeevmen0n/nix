#!/usr/bin/env bash

source "uname.sh"

src=`pwd`
if [ "$linux_os" = "nixos" ]
then
    dst="/etc/nixos"
    sudo ln -sfn "$src/flake.nix" "$dst/flake.nix"
    sudo ln -sfn "$src/hosts" "$dst/hosts"
    sudo ln -sfn "$src/home" "$dst/home"
    sudo ln -sfn "$src/config" "$dst/config"
    sudo ln -sfn "$src/nixos" "$dst/nixos"
else
    dst="$HOME/.config/home-manager"
    mkdir -p "$dst"
    ln -sfn "$src/flake.nix" "$dst/flake.nix"
    ln -sfn "$src/hosts" "$dst/hosts"
    ln -sfn "$src/home" "$dst/home"
    ln -sfn "$src/config" "$dst/config"
    ln -sfn "$src/nixos" "$dst/nixos"
fi
echo "generated soft links to $dst"