{
  programs.plasma = {
    enable = true;
    input = {
      mice = [
        {
          name = "Logitech G305";
          enable = true;
          accelerationProfile = "none";
          naturalScroll = false;
          vendorId = "046d";
          productId = "4074";
        }
      ];
      touchpads = [
        {
          name = "ASUF1209:00 2808:0219 Touchpad";
          enable = true;
          naturalScroll = true;
          vendorId = "2808";
          productId = "0219";
        }
      ];
    };
  };
}