let
  users = import ../../config/users.nix;
in
{
  programs.git = {
    enable = true;
    settings.user = {
      name = users.default.name;
      email = users.default.email;
    };
  };
}
