{ pkgs, ... }:

{
  services.flatpak.enable = true;

  systemd.services.flatpak-automatic-update = {
    description = "Flatpak Automatic Update";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "flatpak-update-notify" ''
        if ${pkgs.flatpak}/bin/flatpak update -y; then
          ${pkgs.libnotify}/bin/notify-send "Flatpak Updates" "All Flatpak applications have been updated successfully." -i system-software-update
        else
          ${pkgs.libnotify}/bin/notify-send "Flatpak Updates" "Some Flatpak updates failed. Check the system logs for details." -i dialog-error
        fi
      ''}";
      User = "root";
    };
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

  systemd.timers.flatpak-automatic-update = {
    description = "Timer for Flatpak Automatic Update";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
