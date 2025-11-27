{ pkgs, ... }:
let
  users = import ../../../config/users.nix;
  home = "/home/${users.default.username}";
  igpuPciPath = "/dev/dri/by-path/pci-0000:65:00.0-card";
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

      if [ -e "${igpuPciPath}" ]; then
          IGPU_CARD=$(realpath "${igpuPciPath}")
      else
          echo "Warning: Could not find iGPU at ${igpuPciPath}, defaulting to card1"
          IGPU_CARD="/dev/dri/card1"
      fi

      UWSM_ENV="${home}/.config/uwsm/env-hyprland"
      PLASMA_ENV="${home}/.config/plasma-workspace/env/gpu-env.sh"

      mkdir -p "$(dirname "$UWSM_ENV")" "$(dirname "$PLASMA_ENV")"
      chown ${users.default.username}:users "${home}/.config" "${home}/.config/uwsm" "${home}/.config/plasma-workspace" "${home}/.config/plasma-workspace/env"

      case "$MODE" in
        Hybrid|Integrated)
          echo "export AQ_DRM_DEVICES=$IGPU_CARD" > "$UWSM_ENV"
          echo "export AQ_NO_ATOMIC=1" >> "$UWSM_ENV"
          echo "export KWIN_DRM_DEVICES=$IGPU_CARD" > "$PLASMA_ENV"
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

      chown ${users.default.username}:users "$(dirname "$UWSM_ENV")" "$(dirname "$PLASMA_ENV")" "$UWSM_ENV" "$PLASMA_ENV"
    '';
  };
}
