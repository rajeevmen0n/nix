{ pkgs, ... }:
let
  users = import ../../config/users.nix;
  home = "/home/${users.default.username}";
in 
{
  systemd.services.gpu-env = {
    enable = true;

    wantedBy = [ "multi-user.target" ];

    unitConfig = {
      Description = "Generate GPU-specific session env vars";
      After = [ "supergfxd.service" ];
      Before = [ "graphical-session.target" "display-manager.target" ];
    };

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      attempts=0
      while ! MODE=$(timeout 0.5 ${pkgs.supergfxctl}/bin/supergfxctl --get 2>/dev/null); do
        attempts=$((attempts + 1))
        if [ $attempts -gt 10 ]; then
          echo "supergfxctl is not responding, giving up."
          exit 1
        fi
      done

      UWSM_ENV="${home}/.config/uwsm/env-hyprland"
      PLASMA_ENV="${home}/.config/plasma-workspace/env/gpu-env.sh"

      mkdir -p "$(dirname "$UWSM_ENV")" "$(dirname "$PLASMA_ENV")"

      case "$MODE" in
        Hybrid|Integrated)
          echo "export AQ_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0" > "$UWSM_ENV"
          echo "export AQ_NO_ATOMIC=1" >> "$UWSM_ENV"
          echo "export KWIN_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0" > "$PLASMA_ENV"
          ;;
        AsusMuxDgpu)
          echo "# AsusMuxDgpu mode — no overrides" > "$UWSM_ENV"
          echo "# AsusMuxDgpu mode — no KWIN_DRM_DEVICES" > "$PLASMA_ENV"
          ;;
        *)
          echo "# Unknown mode: '$MODE'" > "$UWSM_ENV"
          echo "# Unknown mode: '$MODE'" > "$PLASMA_ENV"
          ;;
      esac
    '';
  };
}