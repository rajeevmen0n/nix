{
  programs.plasma = {
    enable = true;

    input.touchpads = [
      {
        name = "ASUF1209:00 2808:0219 Touchpad";
        enable = true;
        naturalScroll = false;
        vendorId = "2808";
        productId = "0219";
      }
    ];
  };
}
