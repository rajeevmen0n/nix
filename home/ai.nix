{ pkgs, ... }:

let
  npxApps = [
    {
      name = "pi";
      spec = "@earendil-works/pi-coding-agent@latest";
    }
    {
      name = "claude";
      spec = "@anthropic-ai/claude-code@latest";
    }
    {
      name = "codex";
      spec = "@openai/codex@latest";
    }
  ];
in
{
  home = {
    packages = with pkgs; [
      nodejs_24
    ];

    file = builtins.listToAttrs (map (app: {
      name = ".local/bin/${app.name}";
      value = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          # Automatically resolves and runs the latest version on launch
          exec ${pkgs.nodejs_24}/bin/npx -y ${app.spec} "$@"
        '';
      };
    }) npxApps);

    sessionPath = [
      "$HOME/.local/bin"
    ];

    sessionVariables = {
      NPM_CONFIG_UPDATE_NOTIFIER = "false";
    };
  };
}
