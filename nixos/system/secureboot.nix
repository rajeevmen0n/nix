{ lib, ...}:
{
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;

    limine = {
      enable = true;

      secureBoot.enable = true;
    };
  };
}
