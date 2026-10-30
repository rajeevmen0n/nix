# Single source of truth for the base domain and every hostname under it.
# Change `domain` here and every module follows.
rec {
  domain = "icyfire.dev";

  subdomains = {
    anisette = "anisette.${domain}";
    auth = "auth.${domain}";
    gev = "gev.${domain}";
    headplane = "headplane.${domain}";
    headscale = "headscale.${domain}";
    ldap = "ldap.${domain}";
    needledrop = "needledrop.${domain}";
  };

  # MagicDNS base domain of the tailnet (not a web host)
  tailnet = "tailnet.${domain}";

  # LDAP directory root, e.g. dc=ldap,dc=icyfire,dc=dev
  ldapBaseDn = builtins.concatStringsSep "," (
    map (part: "dc=${part}") ([ "ldap" ] ++ builtins.filter builtins.isString (builtins.split "\\." domain))
  );
}
