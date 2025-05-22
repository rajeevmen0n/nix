{ pkgs, ... }: {
  imports = [
    ./shell.nix
    ./apps/ghostty.nix
  ];

  home.packages = with pkgs; [
    neovimWrapped
  ];
}
