{ ... }:

{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # The Arctis Pro Wireless USB mixer can report/reapply incorrect volume
    # levels. Keep volume control in PipeWire instead of using its hardware
    # mixer.
    wireplumber.extraConfig."51-arctis-pro-wireless-soft-mixer" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "device.name" = "alsa_card.usb-SteelSeries_Arctis_Pro_Wireless-00"; }
          ];
          actions = {
            "update-props" = {
              "api.alsa.soft-mixer" = true;
            };
          };
        }
      ];
    };
  };
}
