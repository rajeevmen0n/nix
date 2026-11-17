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
        package = pkgs.paperServers.paper-26_3;
        jvmOpts = "-Xms6G -Xmx6G";

        serverProperties.level-seed = "1453617059429781824";

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
