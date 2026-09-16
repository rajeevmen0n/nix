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
  npxAppPackages = map (app:
    pkgs.writeShellScriptBin app.name ''
      # Automatically resolves and runs the latest version on launch
      exec ${pkgs.nodejs_24}/bin/npx -y ${app.spec} "$@"
    '') npxApps;
in
{
  home = {
    packages = with pkgs; [
      nodejs_24
    ] ++ npxAppPackages;

    sessionVariables = {
      NPM_CONFIG_UPDATE_NOTIFIER = "false";
    };
  };
}
