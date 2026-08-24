{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs_24
  ];

  home.file.".local/bin/pi" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Automatically resolves and runs the latest version on launch
      exec ${pkgs.nodejs_22}/bin/npx -y @earendil-works/pi-coding-agent@latest "$@"
    '';
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
