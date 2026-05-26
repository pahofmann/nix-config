{ ... }:

{
  services.printing = {
    enable = true;
    drivers = [ ];
    defaultShared = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  hardware.printers.ensurePrinters = [
    {
      name = "Brother_QL_1110NWB";
      location = "Office";
      deviceUri = "ipp://192.168.2.115/ipp/print";
      model = "everywhere";
    }
  ];

  systemd.services.ensure-printers = {
    serviceConfig = {
      RemainAfterExit = true;
      StartLimitBurst = 0;
      Restart = "on-failure";
    };
  };
}
