let
  users = import ./users.nix;
in
{
  laptop-nixos = {
    hostname = "matrix";
    dir = "laptop-nixos";
    arch = "x86_64-linux";
    user = users.default;
  };
}