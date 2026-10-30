# Who may reach which host. Rules are matched in order, so the catch-all
# lives at the end (mkAfter) and every service adds its own rules from its own
# module, ahead of it.
{ lib, ... }:

let
  inherit (import ../domain.nix) domain;
in
{
  services.authelia.instances.main.settings.access_control = {
    default_policy = "deny";

    rules = lib.mkAfter [
      {
        domain = [ "*.${domain}" domain ];
        policy = "one_factor";
      }
    ];
  };
}
