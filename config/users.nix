let
  users = {
    default = {
      username = "";
    };
  };

  keys = builtins.attrNames users;
  vals = builtins.map (k: users.${k}) keys;

  bad =
    builtins.filter (
      u: u.username == ""
    )
    vals;
in
  assert builtins.length bad
  == 0
  || builtins.abort ''
    config/users.nix: every user must have username.
  ''; users
