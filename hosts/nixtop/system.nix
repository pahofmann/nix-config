{ pkgs, ... }:
let
  # OpenRazer 3.12.4 uses transaction ID 0xff for the Viper Ultimate's
  # device_mode requests.  The mouse/receiver firmware responds reliably to
  # 0x3f instead.  A failed mode switch leaves the generic HID mapping active,
  # where BTN_MIDDLE can disappear after a KVM, cable, or wireless hand-off.
  #
  # This is deliberately a kernel-driver-only patch: it touches just the two
  # device_mode requests for 1532:007a/007b, keeps OpenRazer's battery API
  # intact for the DMS widget, and can be removed once upstream ships it.
  openrazerViperMiddlePatch = pkgs.writeText "openrazer-viper-middle.patch" ''
    --- a/driver/razermouse_driver.c
    +++ b/driver/razermouse_driver.c
    @@ -3784,4 +3787,6 @@ static ssize_t razer_attr_write_device_mode(struct device *dev, struct device_a
         case USB_DEVICE_ID_RAZER_DEATHADDER_V2_PRO_WIRELESS:
         case USB_DEVICE_ID_RAZER_DEATHADDER_V2_MINI:
    +    case USB_DEVICE_ID_RAZER_VIPER_ULTIMATE_WIRED:
    +    case USB_DEVICE_ID_RAZER_VIPER_ULTIMATE_WIRELESS:
         request.transaction_id.id = 0x3f;
         break;
    @@ -3818,8 +3823,6 @@ static ssize_t razer_attr_write_device_mode(struct device *dev, struct device_a
         case USB_DEVICE_ID_RAZER_DEATHADDER_ESSENTIAL:
         case USB_DEVICE_ID_RAZER_DEATHADDER_ESSENTIAL_WHITE_EDITION:
         case USB_DEVICE_ID_RAZER_VIPER:
    -    case USB_DEVICE_ID_RAZER_VIPER_ULTIMATE_WIRED:
    -    case USB_DEVICE_ID_RAZER_VIPER_ULTIMATE_WIRELESS:
         case USB_DEVICE_ID_RAZER_BASILISK_X_HYPERSPEED:
         case USB_DEVICE_ID_RAZER_VIPER_MINI:
         case USB_DEVICE_ID_RAZER_VIPER_8K:
    @@ -3875,4 +3878,6 @@ static ssize_t razer_attr_read_device_mode(struct device *dev, struct device_at
         case USB_DEVICE_ID_RAZER_MAMBA_WIRELESS_RECEIVER:
         case USB_DEVICE_ID_RAZER_MAMBA_WIRELESS_WIRED:
    +    case USB_DEVICE_ID_RAZER_VIPER_ULTIMATE_WIRED:
    +    case USB_DEVICE_ID_RAZER_VIPER_ULTIMATE_WIRELESS:
         request.transaction_id.id = 0x3f;
         break;
    @@ -3947,8 +3952,6 @@ static ssize_t razer_attr_read_device_mode(struct device *dev, struct device_at
         case USB_DEVICE_ID_RAZER_DEATHADDER_ESSENTIAL:
         case USB_DEVICE_ID_RAZER_DEATHADDER_ESSENTIAL_WHITE_EDITION:
         case USB_DEVICE_ID_RAZER_VIPER:
    -    case USB_DEVICE_ID_RAZER_VIPER_ULTIMATE_WIRED:
    -    case USB_DEVICE_ID_RAZER_VIPER_ULTIMATE_WIRELESS:
         case USB_DEVICE_ID_RAZER_BASILISK_X_HYPERSPEED:
         case USB_DEVICE_ID_RAZER_VIPER_MINI:
         case USB_DEVICE_ID_RAZER_VIPER_8K:
    @@ -5947,7 +5947,10 @@ razer_input_mapping(struct hid_device *hdev, struct hid_input *hidinput,
          * 15-element arrays on reports 4 and 5 with usage 0x10003. If
          * hid-core tries to interpret this misshapen descriptor it will
          * botch it and add spurious event codes to input->evkey. */
    -    if (field->application == HID_UP_GENDESK
    +    if (!(hdev->product == USB_DEVICE_ID_RAZER_VIPER_ULTIMATE_WIRELESS &&
    +          to_usb_interface(hdev->dev.parent)->cur_altsetting->desc.bInterfaceProtocol ==
    +              USB_INTERFACE_PROTOCOL_MOUSE) &&
    +        field->application == HID_UP_GENDESK
             && usage->hid == (HID_UP_GENDESK | 0x0003)) {
             return -1;
         }
  '';
in {
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ../../modules/common/base.nix
    ../../modules/common/audio.nix
    ../../modules/common/flatpak.nix
    ../../modules/common/gaming.nix
    ../../modules/common/nvidia.nix
    ../../modules/common/packages.nix
    ../../modules/common/printing.nix
    ../../modules/common/storage-containers.nix
    ../../modules/desktop/danklinux.nix
  ];

  networking.hostName = "nixtop";

  # Install Logitech's uaccess rule so the logged-in desktop user can open
  # LIGHTSPEED HID++ receiver nodes; Solaar needs raw hidraw access for
  # SUPERSTRIKE settings and battery telemetry.
  hardware.logitech.wireless.enable = true;

  # One-reboot diagnostic variant: start without OpenRazer or its watchdog.
  # The generic HID driver should then bind the Viper receiver.
  specialisation.no-openrazer.configuration = {
    hardware.openrazer.enable = pkgs.lib.mkForce false;
    boot.blacklistedKernelModules = [ "razermouse" ];
    systemd.services.razer-viper-middle-click.enable = false;
  };

  # Keep the workaround in the per-machine kernel package: no installed
  # application or daemon source is modified, and the DMS battery widget
  # continues to use the normal OpenRazer API.
  boot.kernelPackages = pkgs.linuxPackages.extend (_: prev: {
    openrazer = prev.openrazer.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ openrazerViperMiddlePatch ];
    });
  });

  # `ichbin.nas` is a local-only name served by the router.  Do not let a
  # public resolver supplied by another connection win the DNS race: keep the
  # router as the sole DNS server for the wired LAN and reserve Cloudflare for
  # the case where no connection-specific DNS server is available.
  networking.networkmanager.ensureProfiles.profiles.wired-home = {
    connection = {
      id = "Wired connection 1";
      uuid = "d7539298-8feb-3ac4-bec1-a56221ce572b";
      type = "ethernet";
      interface-name = "eno1";
    };
    ipv4 = {
      method = "auto";
      dns = "192.168.2.253";
      ignore-auto-dns = true;
    };
    ipv6.method = "disabled";
  };
  services.resolved.settings.Resolve.FallbackDNS = [ "1.1.1.1" ];

  # Hermes connects from the home server with a dedicated Ed25519 key.  Keep
  # SSH key-only, disable root access, and expose only the required LAN port.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  users.users.patrick.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTNv3+MJQjHewsO1eHfxXPst+sODGEXPlqcfUpBxNUM hermes-nixtop"
  ];

  # ESPHome Desktop accepts paired build requests from Home Assistant on this
  # peer-link port.  The builder itself remains local to this machine.
  networking.firewall.allowedTCPPorts = [ 22 6055 ];
  patrick.danklinux.enable = true;

  # DMS controls power profiles through this D-Bus service.  A desktop should
  # always start at full performance rather than inheriting a laptop-style
  # powersave governor.
  services.power-profiles-daemon.enable = true;
  systemd.services.force-performance-profile = {
    description = "Use the performance power profile on the desktop";
    wantedBy = [ "multi-user.target" ];
    requires = [ "power-profiles-daemon.service" ];
    after = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
    };
  };

  # Google Chrome reads managed extension policies from
  # /etc/opt/chrome/policies.  Keep Bitwarden present without an imperative
  # Web Store installation in the user profile.
  programs.chromium = {
    enable = true;
    # 1 = restore the windows and tabs from the last regular session.
    extraOpts = {
      RestoreOnStartup = 1;
    };
    extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden Password Manager
    ];
  };
}
