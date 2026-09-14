let
  users = import ../../config/users.nix;
in
{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user = {
        name = users.default.name;
        email = users.default.email;
      };
    };
  };
}
