{ pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    timeout = 5;

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 10;
      default = "2";
      memtest86.enable = true;
      timeoutStyle = "menu";
    };
  };

  boot.loader.systemd-boot.configurationLimit = 10;

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
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "disable-wakeup" ''
        # Disable the main USB controllers that are causing wake issues
        for device in XHC0 XHC1 XHC2 GP17; do
          if grep -q "^$device.*enabled" /proc/acpi/wakeup 2>/dev/null; then
            echo "Disabling wakeup for $device"
            echo "$device" > /proc/acpi/wakeup
          fi
        done

        # Disable PCIe devices that can cause wake issues
        for device in GPP0 GPP7 UP00 DP00 DP40 DP48 DP50 EP00 DP58 DP60 XH00 DP68; do
          if grep -q "^$device.*enabled" /proc/acpi/wakeup 2>/dev/null; then
            echo "Disabling wakeup for $device"
            echo "$device" > /proc/acpi/wakeup
          fi
        done
      '';
    };
  };
}
