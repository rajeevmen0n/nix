{
  pkgs,
  ...
}: {
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers = {
      onlypros = {
        enable = true;
        package = pkgs.paperServers.paper-1_21_11;
        jvmOpts = "-Xms6G -Xmx6G";

        symlinks = {
          "ops.json" = pkgs.writeText "ops.json" (builtins.toJSON [
            {
              uuid = "668de38c-5812-4f67-8834-4e8ab6fac630";
              name = "icyfire_";
              level = 4;
              bypassesPlayerLimit = true;
            }
          ]);
        };
      };
    };
  };
}
