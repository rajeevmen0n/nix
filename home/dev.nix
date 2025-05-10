{ pkgs, ... }: {
  imports = [
    ./shell.nix
    ./gui/ghostty.nix
  ];

  home.packages = with pkgs; [
    neovimWrapped
  ];
}
