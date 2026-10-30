# OpenID Connect provider. Each client is a service that signs in through
# Authelia.
{ ... }:

let
  inherit (import ../domain.nix) subdomains;
in
{
  services.authelia.instances.main.settings.identity_providers.oidc = {
    cors = {
      endpoints = [ "authorization" "token" "revocation" "introspection" "userinfo" ];
      allowed_origins_from_client_redirect_uris = true;
    };

    # TODO(refactor): this client moves into its service module.
    clients = [
      {
        client_id = "headplane";
        client_name = "Headplane";
        client_secret = "$pbkdf2-sha512$310000$YUphTm7Ul5jE1pnkcSbjJA$N6UZKR4MERopfUDJR5IVutOGrpawq02CEKH2r1GxfR9HvOzoE1ML3/wPWqgrC0BaMy2Fx/ggWvqbJgXdA4gu.w";
        authorization_policy = "one_factor";
        token_endpoint_auth_method = "client_secret_post";
        redirect_uris = [
          "https://${subdomains.headplane}/admin/oidc/callback"
        ];
        scopes = [ "openid" "profile" "email" ];
      }
    ];
  };
}
