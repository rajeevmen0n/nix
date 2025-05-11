{ pkgs, ... }:
{
  systemd.user.services.gpu-env = {
    enable = true;

    wantedBy = [ "graphical-session.target" ];

    unitConfig = {
      Description = "Generate GPU-specific session env vars";
      After = [ "graphical-session-pre.target" ];
    };

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      read -r MODE < <(${pkgs.supergfxctl}/bin/supergfxctl --get)

      UWSM_ENV="$HOME/.config/uwsm/env-hyprland"
      PLASMA_ENV="$XDG_RUNTIME_DIR/environment.d/99-gpu-env.conf"

      mkdir -p "$(dirname "$UWSM_ENV")" "$(dirname "$PLASMA_ENV")"

      case "$MODE" in
        Hybrid|Integrated)
          echo "export AQ_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0" > "$UWSM_ENV"
          echo "export AQ_NO_ATOMIC=1" >> "$UWSM_ENV"
          echo "KWIN_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0" > "$PLASMA_ENV"
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