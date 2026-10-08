{ pkgs, ... }:

let
  arctisMicLedSync = pkgs.writeShellApplication {
    name = "arctis-mic-led-sync";
    runtimeInputs = [ pkgs.alsa-utils pkgs.gnugrep pkgs.wireplumber ];
    text = ''
      # The Stream Deck's MicMute plugin controls PipeWire.  The Arctis LED,
      # however, is driven by its USB capture switch, which is intentionally
      # bypassed by the soft-mixer workaround below.  Mirror PipeWire's final
      # state to that switch after the plugin has handled the key press.
      # StreamController dispatches actions asynchronously.  Its MicMute
      # action needs to update PipeWire before this companion action reads it.
      sleep 0.15
      if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q '\[MUTED\]'; then
        amixer -c 0 cset numid=3 off >/dev/null
      else
        amixer -c 0 cset numid=3 on >/dev/null
      fi
    '';
  };
in
{
  environment.systemPackages = [ arctisMicLedSync ];

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
