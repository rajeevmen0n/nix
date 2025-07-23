{
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  networking.firewall.interfaces."podman+".allowedUDPPorts = [53];

  virtualisation.oci-containers.backend = "podman";
}
