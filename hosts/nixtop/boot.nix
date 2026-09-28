{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  boot.kernelParams = [
    "video.only_lcd=0"
    "console=tty0"
    "fbcon=map:0"
    "video=DP-2:e"
    "video=DP-3:e"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
  ];

  systemd.services.disable-usb-wakeup = {
    description = "Disable USB and PCIe wakeup for sleep issues";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      for device in XHC0 XHC1 XHC2 GP17 GPP0 GPP7 UP00 DP00 DP40 DP48 DP50 EP00 DP58 DP60 XH00 DP68; do
        if grep -q "^$device.*enabled" /proc/acpi/wakeup 2>/dev/null; then
          echo "$device" > /proc/acpi/wakeup
        fi
      done
    '';
  };
}
