{ ... }: {
  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers.anisette-v3 = {
      image = "docker.io/dadoum/anisette-v3-server:latest";
      autoStart = true;
      ports = [ "127.0.0.1:6969:6969" ];
      volumes = [
        "anisette-v3_data:/home/Alcoholic/.config/anisette-v3/lib/"
      ];
    };
  };
}
