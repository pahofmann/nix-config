{ ... }:

{
  fileSystems."/mnt/ha-config" = {
    device = "//192.168.2.100/config";
    fsType = "cifs";
    options = [
      "credentials=/home/patrick/.config/.smbcredentials"
      "uid=1000"
      "gid=100"
      "file_mode=0660"
      "dir_mode=0770"
      "vers=3.0"
      "x-systemd.automount"
      "noauto"
    ];
  };

  fileSystems."/mnt/media" = {
    device = "//192.168.2.10/media";
    fsType = "cifs";
    options = [
      "credentials=/home/patrick/.config/.smbcredentials-media"
      "uid=1000"
      "gid=100"
      "file_mode=0660"
      "dir_mode=0770"
      "vers=3.1.1"
      "x-systemd.automount"
      "noauto"
    ];
  };

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
