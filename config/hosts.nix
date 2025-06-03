let
  users = import ./users.nix;
in
{
  ga605wi = {
    hostname = "matrix";
    dir = "ga605wi";
    arch = "x86_64-linux";
    user = users.default;
  };
}