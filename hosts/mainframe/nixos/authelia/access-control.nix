# Who may reach which host. Rules are matched in order, so the catch-all
# lives at the end (mkAfter) and every service adds its rules before it.
{ lib, ... }:

let
  inherit (import ../domain.nix) domain subdomains;
in
{
  services.authelia.instances.main.settings.access_control = lib.mkMerge [
    {
      default_policy = "deny";

      rules = [
        # TODO(refactor): these service rules move into their service modules.
        {
          domain = [ subdomains.headplane ];
          subject = [ ["group:lldap_admin"] ["user:admin"] ];
          policy = "one_factor";
        }
        {
          domain = [ subdomains.headplane ];
          policy = "deny";
        }
        {
          domain = [ subdomains.needledrop ];
          resources = [ "^/admin($|/)" "^/api/admin($|/)" ];
          subject = [ [ "group:needledrop_admin" ] ];
          policy = "one_factor";
        }
        {
          domain = [ subdomains.needledrop ];
          resources = [ "^/admin($|/)" "^/api/admin($|/)" ];
          policy = "deny";
        }
      ];
    }
    {
      rules = lib.mkAfter [
        {
          domain = [ "*.${domain}" domain ];
          policy = "one_factor";
        }
      ];
    }
  ];
}
