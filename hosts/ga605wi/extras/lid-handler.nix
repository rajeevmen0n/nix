{ pkgs, ... }:
let
  lidHandlerScript = pkgs.writeShellScriptBin "lid-handler" ''
    # Get all active monitors (lines starting with "Monitor "), extract names
    MONITORS=$(hyprctl monitors | grep '^Monitor ' | awk '{print $2}')

    # Check if any non-eDP monitor is present
    EXTERNAL_CONNECTED=false
    for mon in $MONITORS; do
        if [[ ! "$mon" =~ ^eDP- ]]; then
            EXTERNAL_CONNECTED=true
            break
        fi
    done

    # What action triggered the script
    ACTION="$1"

    if [[ "$ACTION" == "close" ]]; then
        if [[ "$EXTERNAL_CONNECTED" == true ]]; then
            echo "Lid closed, external monitor is connected. Doing nothing."
            exit 0
        else
            echo "Lid closed, no external monitor. Suspending..."
            systemctl suspend
        fi
    elif [[ "$ACTION" == "open" ]]; then
        echo "Lid opened. No action."
    fi
  '';
in {
  environment.systemPackages = [ lidHandlerScript ];
}
