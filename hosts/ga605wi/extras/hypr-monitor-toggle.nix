{pkgs, ...}: let
  monitorToggleScript = pkgs.writeShellScriptBin "hypr-monitor-toggle" ''

    scan_monitors() {
        for name in $MONITOR_NAMES; do
            if [[ "$name" == eDP-* ]]; then
                LAPTOP_DISPLAY="$name"
            else
                EXTERNAL_DISPLAY="$name"
            fi
        done
    }

    # Extract monitor names
    MONITOR_NAMES=$(hyprctl monitors | grep '^Monitor' | awk '{print $2}')

    # Identify laptop display (eDP-1 or eDP-2)
    LAPTOP_DISPLAY=""
    EXTERNAL_DISPLAY=""

    scan_monitors

    # Exit if no laptop display found
    if [ -z "$LAPTOP_DISPLAY" ]; then
        if [ -n "$EXTERNAL_DISPLAY" ]; then
            echo "External display connected, not switching"
            exit 1
        else
            echo "Enabling laptop displays"
            hyprctl keyword monitor "eDP-1,2560x1600@240,0x0,1"
            hyprctl keyword monitor "eDP-2,2560x1600@240,0x0,1"
            scan_monitors
        fi
    fi

    # If we found an external display
    if [ -n "$EXTERNAL_DISPLAY" ]; then
        echo "External display connected: $EXTERNAL_DISPLAY"

        # Disable laptop display
        hyprctl keyword monitor "$LAPTOP_DISPLAY,disable"

        # Move all workspaces to external
        for i in {1..9}; do
            hyprctl dispatch moveworkspacetomonitor "$i $EXTERNAL_DISPLAY"
        done
    else
        echo "No external display connected."

        # Move all workspaces back to laptop display
        for i in {1..9}; do
            hyprctl dispatch moveworkspacetomonitor "$i $LAPTOP_DISPLAY"
        done
    fi
  '';

  monitorEventListener = pkgs.writeShellScriptBin "hypr-monitor-event-watcher" ''
    SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

    if [ ! -S "$SOCKET" ]; then
      echo "Hyprland socket not found: $SOCKET"
      exit 1
    fi

    handle() {
      case "$1" in
        monitoradded*|monitorremoved*)
          ${monitorToggleScript}/bin/hypr-monitor-toggle
          ;;
      esac
    }

    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
      handle "$line"
    done
  '';
in {
  environment.systemPackages = [
    monitorEventListener
    monitorToggleScript
    pkgs.socat
    pkgs.gawk
    pkgs.gnugrep
  ];

  systemd.user.services.hypr-monitor-watcher = {
    enable = true;

    wantedBy = ["default.target"];

    unitConfig = {
      Description = "Hyprland Monitor Event Watcher";
      After = ["graphical-session.target"];
    };

    serviceConfig = {
      ExecStart = "${monitorEventListener}/bin/hypr-monitor-event-watcher";
      Restart = "on-failure";
      RestartSec = 2;
      Environment = "PATH=${pkgs.hyprland}/bin:${pkgs.socat}/bin:${pkgs.gawk}/bin:${pkgs.gnugrep}/bin:$PATH";
    };
  };
}
