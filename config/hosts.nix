let
  users = import ./users.nix;
in {
  ga605wi = {
    hostname = "matrix";
    dir = "ga605wi";
    arch = "x86_64-linux";
    user = users.default;
  };

  mainframe = {
    hostname = "mainframe";
    dir = "mainframe";
    arch = "aarch64";
    user = users.default;
  };
}

