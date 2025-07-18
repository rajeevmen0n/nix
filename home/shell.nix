{pkgs, ...}: {
  imports = [
    ./cli/zsh.nix
    ./cli/fzf.nix
    ./cli/starship.nix
    ./cli/tmux.nix
  ];

  home.packages = with pkgs; [
    neovimWrapped
  ];
}

