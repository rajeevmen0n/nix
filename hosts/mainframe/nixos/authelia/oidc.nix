# OpenID Connect provider. Services that sign in through Authelia register
# their own client from their own module.
{ ... }:

{
  services.authelia.instances.main.settings.identity_providers.oidc.cors = {
    endpoints = [ "authorization" "token" "revocation" "introspection" "userinfo" ];
    allowed_origins_from_client_redirect_uris = true;
  };
}
