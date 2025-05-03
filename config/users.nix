let
  users = {
    default = {
      username = "";
      name = "";
    };
  };

  keys = builtins.attrNames users;
  vals = builtins.map (k: users.${k}) keys;

  bad =
    builtins.filter (
      u: u.username == "" || u.name == ""
    )
    vals;
in
  assert builtins.length bad
  == 0
  || builtins.abort ''
    config/users.nix: every user must have username, and name.
  ''; users
