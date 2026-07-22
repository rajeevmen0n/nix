{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gemini-cli
  ];
}
