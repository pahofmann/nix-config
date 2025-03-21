{ config, pkgs, ... }:

{
  home.username = "patrick";
  home.homeDirectory = "/home/patrick";
  programs.fish = {
    enable = true;
    shellAliases = {
      k = "kubectl";
      brg = "${pkgs.bat-extras.batgrep}/bin/batgrep";
      cat = "${pkgs.bat}/bin/bat --paging=never";
      clock = ''${pkgs.tty-clock}/bin/tty-clock -B -c -C 4 -f "%a, %d %b"'';
      dadjoke = ''${pkgs.curlMinimal}/bin/curl --header "Accept: text/plain" https://icanhazdadjoke.com/'';
      dmesg = "${pkgs.util-linux}/bin/dmesg --human --color=always";
      neofetch = "${pkgs.fastfetch}/bin/fastfetch";
      glow = "${pkgs.glow}/bin/glow --pager";
      hr = ''${pkgs.hr}/bin/hr "─━"'';
      htop = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker";
      less = "${pkgs.bat}/bin/bat";
      lm = "${pkgs.lima-bin}/bin/limactl";
      lolcat = "${pkgs.dotacat}/bin/dotacat";
      moon = "${pkgs.curlMinimal}/bin/curl -s wttr.in/Moon";
      more = "${pkgs.bat}/bin/bat";
      parrot = "${pkgs.terminal-parrot}/bin/terminal-parrot -delay 50 -loops 7";
      pq = "${pkgs.pueue}/bin/pueue";
      ruler = ''${pkgs.hr}/bin/hr "╭─³⁴⁵⁶⁷⁸─╮"'';
      screenfetch = "${pkgs.fastfetch}/bin/fastfetch";
      speedtest = "${pkgs.speedtest-go}/bin/speedtest-go";
      store-path = "${pkgs.coreutils-full}/bin/readlink (${pkgs.which}/bin/which $argv)";
      top = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
      tree = "${pkgs.eza}/bin/eza --tree";
      wormhole = "${pkgs.wormhole-william}/bin/wormhole-william";
      where-am-i = "${pkgs.geoclue2}/libexec/geoclue-2.0/demos/where-am-i";
      lock-armstrong = "fusermount -u ~/Vaults/Armstrong";
      unlock-armstrong = "${pkgs.gocryptfs}/bin/gocryptfs ~/Crypt/Armstrong ~/Vaults/Armstrong";
      lock-secrets = "fusermount -u ~/Vaults/Secrets";
      unlock-secrets = "${pkgs.gocryptfs}/bin/gocryptfs ~/Crypt/Secrets ~/Vaults/Secrets";
    };
    functions = {
      kns = {
        description = "Switch Kubernetes namespace";
        body = ''
          if test (count $argv) -eq 1
            kubectl config set-context --current --namespace=$argv[1]
          else
            echo "Usage: kns <namespace>"
          end
        '';
      };
    };
  };
  programs.plasma = {
    enable = true;
    shortcuts = {
      "ActivityManager"."switch-to-activity-156adec6-167e-45ff-96ba-05d283f6abb8" = "none";
      "ActivityManager"."switch-to-activity-9baa637a-6b09-4325-88b7-929989b0b265" = [ ];
      "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Alt+K";
      "kaccess"."Toggle Screen Reader On and Off" = "Meta+Alt+S";
      "kcm_touchpad"."Disable Touchpad" = "Touchpad Off";
      "kcm_touchpad"."Enable Touchpad" = "Touchpad On";
      "kcm_touchpad"."Toggle Touchpad" = ["Touchpad Toggle" "Meta+Ctrl+Zenkaku Hankaku\\,Touchpad Toggle" "Meta+Ctrl+Zenkaku Hankaku"];
      "kmix"."decrease_microphone_volume" = "Microphone Volume Down";
      "kmix"."decrease_volume" = "Volume Down";
      "kmix"."decrease_volume_small" = "Shift+Volume Down";
      "kmix"."increase_microphone_volume" = "Microphone Volume Up";
      "kmix"."increase_volume" = "Volume Up";
      "kmix"."increase_volume_small" = "Shift+Volume Up";
      "kmix"."mic_mute" = ["Microphone Mute" "Meta+Volume Mute\\,Microphone Mute" "Meta+Volume Mute\\,Mute Microphone"];
      "kmix"."mute" = "Volume Mute";
      "ksmserver"."Halt Without Confirmation" = "none\\,\\,Shut Down Without Confirmation";
      "ksmserver"."Lock Session" = ["Screensaver\\,Meta+L" "Screensaver\\,Lock Session"];
      "ksmserver"."Log Out" = "Ctrl+Alt+Del";
      "ksmserver"."Log Out Without Confirmation" = "none\\,\\,Log Out Without Confirmation";
      "ksmserver"."LogOut" = "none\\,\\,Log Out";
      "ksmserver"."Reboot" = "none\\,\\,Reboot";
      "ksmserver"."Reboot Without Confirmation" = "none\\,\\,Reboot Without Confirmation";
      "ksmserver"."Shut Down" = "none\\,\\,Shut Down";
      "kwin"."Activate Window Demanding Attention" = "Meta+Ctrl+A";
      "kwin"."Cycle Overview" = "none";
      "kwin"."Cycle Overview Opposite" = "none";
      "kwin"."Decrease Opacity" = "none\\,\\,Decrease Opacity of Active Window by 5%";
      "kwin"."Edit Tiles" = "Meta+T";
      "kwin"."Expose" = "Ctrl+F9";
      "kwin"."ExposeAll" = ["Ctrl+F10" "Launch (C)\\,Ctrl+F10" "Launch (C)\\,Toggle Present Windows (All desktops)"];
      "kwin"."ExposeClass" = "Ctrl+F7";
      "kwin"."ExposeClassCurrentDesktop" = "none";
      "kwin"."Grid View" = "Meta+G";
      "kwin"."Increase Opacity" = "none\\,\\,Increase Opacity of Active Window by 5%";
      "kwin"."Kill Window" = "Meta+Ctrl+Esc";
      "kwin"."Move Tablet to Next Output" = "none";
      "kwin"."MoveMouseToCenter" = "Meta+F6";
      "kwin"."MoveMouseToFocus" = "Meta+F5";
      "kwin"."MoveZoomDown" = "none";
      "kwin"."MoveZoomLeft" = "none";
      "kwin"."MoveZoomRight" = "none";
      "kwin"."MoveZoomUp" = "none";
      "kwin"."Overview" = "Meta+W";
      "kwin"."Setup Window Shortcut" = "none\\,\\,Setup Window Shortcut";
      "kwin"."Show Desktop" = "Meta+D";
      "kwin"."Switch One Desktop Down" = "Ctrl+Alt+Down";
      "kwin"."Switch One Desktop Up" = "Ctrl+Alt+Up";
      "kwin"."Switch One Desktop to the Left" = "Meta+Ctrl+Left";
      "kwin"."Switch One Desktop to the Right" = "Meta+Ctrl+Right";
      "kwin"."Switch Window Down" = "Meta+Alt+Down";
      "kwin"."Switch Window Left" = "Meta+Alt+Left";
      "kwin"."Switch Window Right" = "Meta+Alt+Right";
      "kwin"."Switch Window Up" = "Meta+Alt+Up";
      "kwin"."Switch to Desktop 1" = "Ctrl+F1";
      "kwin"."Switch to Desktop 10" = "none\\,\\,Switch to Desktop 10";
      "kwin"."Switch to Desktop 11" = "none\\,\\,Switch to Desktop 11";
      "kwin"."Switch to Desktop 12" = "none\\,\\,Switch to Desktop 12";
      "kwin"."Switch to Desktop 13" = "none\\,\\,Switch to Desktop 13";
      "kwin"."Switch to Desktop 14" = "none\\,\\,Switch to Desktop 14";
      "kwin"."Switch to Desktop 15" = "none\\,\\,Switch to Desktop 15";
      "kwin"."Switch to Desktop 16" = "none\\,\\,Switch to Desktop 16";
      "kwin"."Switch to Desktop 17" = "none\\,\\,Switch to Desktop 17";
      "kwin"."Switch to Desktop 18" = "none\\,\\,Switch to Desktop 18";
      "kwin"."Switch to Desktop 19" = "none\\,\\,Switch to Desktop 19";
      "kwin"."Switch to Desktop 2" = "Ctrl+F2";
      "kwin"."Switch to Desktop 20" = "none\\,\\,Switch to Desktop 20";
      "kwin"."Switch to Desktop 3" = "Ctrl+F3";
      "kwin"."Switch to Desktop 4" = "Ctrl+F4";
      "kwin"."Switch to Desktop 5" = "none\\,\\,Switch to Desktop 5";
      "kwin"."Switch to Desktop 6" = "none\\,\\,Switch to Desktop 6";
      "kwin"."Switch to Desktop 7" = "none\\,\\,Switch to Desktop 7";
      "kwin"."Switch to Desktop 8" = "none\\,\\,Switch to Desktop 8";
      "kwin"."Switch to Desktop 9" = "none\\,\\,Switch to Desktop 9";
      "kwin"."Switch to Next Desktop" = "none\\,\\,Switch to Next Desktop";
      "kwin"."Switch to Next Screen" = "none\\,\\,Switch to Next Screen";
      "kwin"."Switch to Previous Desktop" = "none\\,\\,Switch to Previous Desktop";
      "kwin"."Switch to Previous Screen" = "none\\,\\,Switch to Previous Screen";
      "kwin"."Switch to Screen 0" = "none\\,\\,Switch to Screen 0";
      "kwin"."Switch to Screen 1" = "none\\,\\,Switch to Screen 1";
      "kwin"."Switch to Screen 2" = "none\\,\\,Switch to Screen 2";
      "kwin"."Switch to Screen 3" = "none\\,\\,Switch to Screen 3";
      "kwin"."Switch to Screen 4" = "none\\,\\,Switch to Screen 4";
      "kwin"."Switch to Screen 5" = "none\\,\\,Switch to Screen 5";
      "kwin"."Switch to Screen 6" = "none\\,\\,Switch to Screen 6";
      "kwin"."Switch to Screen 7" = "none\\,\\,Switch to Screen 7";
      "kwin"."Switch to Screen Above" = "none\\,\\,Switch to Screen Above";
      "kwin"."Switch to Screen Below" = "none\\,\\,Switch to Screen Below";
      "kwin"."Switch to Screen to the Left" = "none\\,\\,Switch to Screen to the Left";
      "kwin"."Switch to Screen to the Right" = "none\\,\\,Switch to Screen to the Right";
      "kwin"."Toggle Night Color" = "none";
      "kwin"."Toggle Window Raise/Lower" = "none\\,\\,Toggle Window Raise/Lower";
      "kwin"."Walk Through Windows" = "Alt+Tab";
      "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
      "kwin"."Walk Through Windows Alternative" = "none";
      "kwin"."Walk Through Windows Alternative (Reverse)" = "none";
      "kwin"."Walk Through Windows of Current Application" = "Alt+`";
      "kwin"."Walk Through Windows of Current Application (Reverse)" = "Alt+~";
      "kwin"."Walk Through Windows of Current Application Alternative" = "none";
      "kwin"."Walk Through Windows of Current Application Alternative (Reverse)" = "none";
      "kwin"."Window Above Other Windows" = "none\\,\\,Keep Window Above Others";
      "kwin"."Window Below Other Windows" = "none\\,\\,Keep Window Below Others";
      "kwin"."Window Close" = "Alt+F4";
      "kwin"."Window Fullscreen" = "none\\,\\,Make Window Fullscreen";
      "kwin"."Window Grow Horizontal" = "none\\,\\,Expand Window Horizontally";
      "kwin"."Window Grow Vertical" = "none\\,\\,Expand Window Vertically";
      "kwin"."Window Lower" = "none\\,\\,Lower Window";
      "kwin"."Window Maximize" = "Meta+PgUp";
      "kwin"."Window Maximize Horizontal" = "none\\,\\,Maximize Window Horizontally";
      "kwin"."Window Maximize Vertical" = "none\\,\\,Maximize Window Vertically";
      "kwin"."Window Minimize" = "Meta+PgDown";
      "kwin"."Window Move" = "none\\,\\,Move Window";
      "kwin"."Window Move Center" = "none\\,\\,Move Window to the Center";
      "kwin"."Window No Border" = "none\\,\\,Toggle Window Titlebar and Frame";
      "kwin"."Window On All Desktops" = "F1";
      "kwin"."Window One Desktop Down" = "Ctrl+Alt+Shift+Down";
      "kwin"."Window One Desktop Up" = "Ctrl+Alt+Shift+Up";
      "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
      "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
      "kwin"."Window One Screen Down" = "none\\,\\,Move Window One Screen Down";
      "kwin"."Window One Screen Up" = "none\\,\\,Move Window One Screen Up";
      "kwin"."Window One Screen to the Left" = "none\\,\\,Move Window One Screen to the Left";
      "kwin"."Window One Screen to the Right" = "none\\,\\,Move Window One Screen to the Right";
      "kwin"."Window Operations Menu" = "Alt+F3";
      "kwin"."Window Pack Down" = "none";
      "kwin"."Window Pack Left" = "none\\,\\,Move Window Left";
      "kwin"."Window Pack Right" = "none\\,\\,Move Window Right";
      "kwin"."Window Pack Up" = "none\\,\\,Move Window Up";
      "kwin"."Window Quick Tile Bottom" = "Meta+Down";
      "kwin"."Window Quick Tile Bottom Left" = "none\\,\\,Quick Tile Window to the Bottom Left";
      "kwin"."Window Quick Tile Bottom Right" = "none\\,\\,Quick Tile Window to the Bottom Right";
      "kwin"."Window Quick Tile Left" = "Meta+Left";
      "kwin"."Window Quick Tile Right" = "Meta+Right";
      "kwin"."Window Quick Tile Top" = "Meta+Up";
      "kwin"."Window Quick Tile Top Left" = "none\\,\\,Quick Tile Window to the Top Left";
      "kwin"."Window Quick Tile Top Right" = "none\\,\\,Quick Tile Window to the Top Right";
      "kwin"."Window Raise" = "none\\,\\,Raise Window";
      "kwin"."Window Resize" = "Alt+X\\,\\,Resize Window";
      "kwin"."Window Shade" = "none\\,\\,Shade Window";
      "kwin"."Window Shrink Horizontal" = "none\\,\\,Shrink Window Horizontally";
      "kwin"."Window Shrink Vertical" = "none\\,\\,Shrink Window Vertically";
      "kwin"."Window to Desktop 1" = "none\\,\\,Window to Desktop 1";
      "kwin"."Window to Desktop 10" = "none\\,\\,Window to Desktop 10";
      "kwin"."Window to Desktop 11" = "none\\,\\,Window to Desktop 11";
      "kwin"."Window to Desktop 12" = "none\\,\\,Window to Desktop 12";
      "kwin"."Window to Desktop 13" = "none\\,\\,Window to Desktop 13";
      "kwin"."Window to Desktop 14" = "none\\,\\,Window to Desktop 14";
      "kwin"."Window to Desktop 15" = "none\\,\\,Window to Desktop 15";
      "kwin"."Window to Desktop 16" = "none\\,\\,Window to Desktop 16";
      "kwin"."Window to Desktop 17" = "none\\,\\,Window to Desktop 17";
      "kwin"."Window to Desktop 18" = "none\\,\\,Window to Desktop 18";
      "kwin"."Window to Desktop 19" = "none\\,\\,Window to Desktop 19";
      "kwin"."Window to Desktop 2" = "none\\,\\,Window to Desktop 2";
      "kwin"."Window to Desktop 20" = "none\\,\\,Window to Desktop 20";
      "kwin"."Window to Desktop 3" = "none\\,\\,Window to Desktop 3";
      "kwin"."Window to Desktop 4" = "none\\,\\,Window to Desktop 4";
      "kwin"."Window to Desktop 5" = "none\\,\\,Window to Desktop 5";
      "kwin"."Window to Desktop 6" = "none\\,\\,Window to Desktop 6";
      "kwin"."Window to Desktop 7" = "none\\,\\,Window to Desktop 7";
      "kwin"."Window to Desktop 8" = "none\\,\\,Window to Desktop 8";
      "kwin"."Window to Desktop 9" = "none\\,\\,Window to Desktop 9";
      "kwin"."Window to Next Desktop" = "none\\,\\,Window to Next Desktop";
      "kwin"."Window to Next Screen" = "Meta+Shift+Right";
      "kwin"."Window to Previous Desktop" = "none\\,\\,Window to Previous Desktop";
      "kwin"."Window to Previous Screen" = "Meta+Shift+Left";
      "kwin"."Window to Screen 0" = "none\\,\\,Move Window to Screen 0";
      "kwin"."Window to Screen 1" = "none\\,\\,Move Window to Screen 1";
      "kwin"."Window to Screen 2" = "none\\,\\,Move Window to Screen 2";
      "kwin"."Window to Screen 3" = "none\\,\\,Move Window to Screen 3";
      "kwin"."Window to Screen 4" = "none\\,\\,Move Window to Screen 4";
      "kwin"."Window to Screen 5" = "none\\,\\,Move Window to Screen 5";
      "kwin"."Window to Screen 6" = "none\\,\\,Move Window to Screen 6";
      "kwin"."Window to Screen 7" = "none\\,\\,Move Window to Screen 7";
      "kwin"."view_actual_size" = "Meta+0";
      "kwin"."view_zoom_in" = ["Meta++" "Meta+\x3d\\,Meta++" "Meta+\x3d\\,Zoom In"];
      "kwin"."view_zoom_out" = "Meta+-";
      "mediacontrol"."mediavolumedown" = "none\\,\\,Media volume down";
      "mediacontrol"."mediavolumeup" = "none\\,\\,Media volume up";
      "mediacontrol"."nextmedia" = "Media Next";
      "mediacontrol"."pausemedia" = "Media Pause";
      "mediacontrol"."playmedia" = "none\\,\\,Play media playback";
      "mediacontrol"."playpausemedia" = "Media Play";
      "mediacontrol"."previousmedia" = "Media Previous";
      "mediacontrol"."stopmedia" = "Media Stop";
      "org_kde_powerdevil"."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
      "org_kde_powerdevil"."Decrease Screen Brightness" = "Monitor Brightness Down";
      "org_kde_powerdevil"."Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
      "org_kde_powerdevil"."Hibernate" = "Hibernate";
      "org_kde_powerdevil"."Increase Keyboard Brightness" = "Keyboard Brightness Up";
      "org_kde_powerdevil"."Increase Screen Brightness" = "Monitor Brightness Up";
      "org_kde_powerdevil"."Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
      "org_kde_powerdevil"."PowerDown" = "Power Down";
      "org_kde_powerdevil"."PowerOff" = "Power Off";
      "org_kde_powerdevil"."Sleep" = "Sleep";
      "org_kde_powerdevil"."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
      "org_kde_powerdevil"."Turn Off Screen" = "none";
      "org_kde_powerdevil"."powerProfile" = ["Battery" "Meta+B\\,Battery" "Meta+B\\,Switch Power Profile"];
      "plasmashell"."activate application launcher" = ["Meta" "Alt+F1\\,Meta" "Alt+F1\\,Activate Application Launcher"];
      "plasmashell"."activate task manager entry 1" = "Meta+1";
      "plasmashell"."activate task manager entry 10" = "none\\,Meta+0\\,Activate Task Manager Entry 10";
      "plasmashell"."activate task manager entry 2" = "Meta+2";
      "plasmashell"."activate task manager entry 3" = "Meta+3";
      "plasmashell"."activate task manager entry 4" = "Meta+4";
      "plasmashell"."activate task manager entry 5" = "Meta+5";
      "plasmashell"."activate task manager entry 6" = "Meta+6";
      "plasmashell"."activate task manager entry 7" = "Meta+7";
      "plasmashell"."activate task manager entry 8" = "Meta+8";
      "plasmashell"."activate task manager entry 9" = "Meta+9";
      "plasmashell"."clear-history" = "none\\,\\,Clear Clipboard History";
      "plasmashell"."clipboard_action" = "Meta+Ctrl+X";
      "plasmashell"."cycle-panels" = "Meta+Alt+P";
      "plasmashell"."cycleNextAction" = "none\\,\\,Next History Item";
      "plasmashell"."cyclePrevAction" = "none\\,\\,Previous History Item";
      "plasmashell"."manage activities" = "Meta+Q";
      "plasmashell"."next activity" = "Meta+A\\,none\\,Walk through activities";
      "plasmashell"."previous activity" = "Meta+Shift+A\\,none\\,Walk through activities (Reverse)";
      "plasmashell"."repeat_action" = "none\\,Meta+Ctrl+R\\,Manually Invoke Action on Current Clipboard";
      "plasmashell"."show dashboard" = "Ctrl+F12";
      "plasmashell"."show-barcode" = "none\\,\\,Show Barcode…";
      "plasmashell"."show-on-mouse-pos" = "Meta+V";
      "plasmashell"."stop current activity" = "Meta+S";
      "plasmashell"."switch to next activity" = "none\\,\\,Switch to Next Activity";
      "plasmashell"."switch to previous activity" = "none\\,\\,Switch to Previous Activity";
      "plasmashell"."toggle do not disturb" = "none\\,\\,Toggle do not disturb";
      "services/Alacritty.desktop"."_launch" = "Ctrl+Alt+T";
      "services/org.kde.konsole.desktop"."_launch" = [ ];
      "services/org.kde.plasma-systemmonitor.desktop"."_launch" = ["Ctrl+Shift+Esc" "Meta+Esc"];
      "services/org.kde.spectacle.desktop"."RecordWindow" = [ ];
    };
    configFile = {
      "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
      "baloofilerc"."General"."dbVersion" = 2;
      "baloofilerc"."General"."exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.tfstate*,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.terraform,.venv,venv,core-dumps,lost+found";
      "baloofilerc"."General"."exclude filters version" = 9;
      "dolphinrc"."DetailsMode"."PreviewSize" = 16;
      "dolphinrc"."General"."EditableUrl" = true;
      "dolphinrc"."General"."FilterBar" = true;
      "dolphinrc"."General"."GlobalViewProps" = false;
      "dolphinrc"."General"."OpenExternallyCalledFolderInNewTab" = true;
      "dolphinrc"."General"."ShowFullPathInTitlebar" = true;
      "dolphinrc"."General"."ViewPropsTimestamp" = "2025,1,28,1,13,32.849";
      "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
      "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 22;
      "dolphinrc"."PreviewSettings"."Plugins" = "appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,ffmpegthumbs";
      "kactivitymanagerdrc"."activities"."156adec6-167e-45ff-96ba-05d283f6abb8" = "Default";
      "kactivitymanagerdrc"."activities"."9baa637a-6b09-4325-88b7-929989b0b265" = "Default";
      "kactivitymanagerdrc"."main"."currentActivity" = "156adec6-167e-45ff-96ba-05d283f6abb8";
      "katerc"."General"."Days Meta Infos" = 30;
      "katerc"."General"."Save Meta Infos" = true;
      "katerc"."General"."Show Full Path in Title" = false;
      "katerc"."General"."Show Menu Bar" = true;
      "katerc"."General"."Show Status Bar" = true;
      "katerc"."General"."Show Tab Bar" = true;
      "katerc"."General"."Show Url Nav Bar" = true;
      "katerc"."KTextEditor Renderer"."Animate Bracket Matching" = false;
      "katerc"."KTextEditor Renderer"."Auto Color Theme Selection" = true;
      "katerc"."KTextEditor Renderer"."Color Theme" = "Breeze Dark";
      "katerc"."KTextEditor Renderer"."Line Height Multiplier" = 1;
      "katerc"."KTextEditor Renderer"."Show Indentation Lines" = false;
      "katerc"."KTextEditor Renderer"."Show Whole Bracket Expression" = false;
      "katerc"."KTextEditor Renderer"."Text Font" = "Hack,10,-1,7,400,0,0,0,0,0,0,0,0,0,0,1";
      "katerc"."KTextEditor Renderer"."Text Font Features" = "";
      "katerc"."KTextEditor Renderer"."Word Wrap Marker" = false;
      "katerc"."KTextEditor::Search"."Search History" = "home.sessionVariables,environment.variables,fish,pkg,neofetch";
      "katerc"."Printing/HeaderFooter"."FooterBackground" = "211,211,211";
      "katerc"."Printing/HeaderFooter"."FooterBackgroundEnabled" = false;
      "katerc"."Printing/HeaderFooter"."FooterEnabled" = true;
      "katerc"."Printing/HeaderFooter"."FooterForeground" = "0,0,0";
      "katerc"."Printing/HeaderFooter"."FooterFormatCenter" = "";
      "katerc"."Printing/HeaderFooter"."FooterFormatLeft" = "";
      "katerc"."Printing/HeaderFooter"."FooterFormatRight" = "%U";
      "katerc"."Printing/HeaderFooter"."HeaderBackground" = "211,211,211";
      "katerc"."Printing/HeaderFooter"."HeaderBackgroundEnabled" = false;
      "katerc"."Printing/HeaderFooter"."HeaderEnabled" = true;
      "katerc"."Printing/HeaderFooter"."HeaderFooterFont" = "Hack,10,-1,7,400,0,0,0,0,0,0,0,0,0,0,1";
      "katerc"."Printing/HeaderFooter"."HeaderForeground" = "0,0,0";
      "katerc"."Printing/HeaderFooter"."HeaderFormatCenter" = "%f";
      "katerc"."Printing/HeaderFooter"."HeaderFormatLeft" = "%y";
      "katerc"."Printing/HeaderFooter"."HeaderFormatRight" = "%p";
      "katerc"."Printing/Layout"."BackgroundColorEnabled" = false;
      "katerc"."Printing/Layout"."BoxColor" = "invalid";
      "katerc"."Printing/Layout"."BoxEnabled" = false;
      "katerc"."Printing/Layout"."BoxMargin" = 6;
      "katerc"."Printing/Layout"."BoxWidth" = 1;
      "katerc"."Printing/Layout"."Font" = "Hack,10,-1,7,400,0,0,0,0,0,0,0,0,0,0,1";
      "katerc"."Printing/Text"."DontPrintFoldedCode" = true;
      "katerc"."Printing/Text"."Legend" = false;
      "katerc"."Printing/Text"."LineNumbers" = false;
      "katerc"."filetree"."editShade" = "31,81,106";
      "katerc"."filetree"."listMode" = false;
      "katerc"."filetree"."middleClickToClose" = false;
      "katerc"."filetree"."shadingEnabled" = true;
      "katerc"."filetree"."showCloseButton" = false;
      "katerc"."filetree"."showFullPathOnRoots" = false;
      "katerc"."filetree"."showToolbar" = true;
      "katerc"."filetree"."sortRole" = 0;
      "katerc"."filetree"."viewShade" = "81,49,95";
      "kcminputrc"."Libinput/5426/123/Razer Razer Viper Ultimate Dongle"."PointerAccelerationProfile" = 1;
      "kded5rc"."Module-browserintegrationreminder"."autoload" = false;
      "kded5rc"."Module-device_automounter"."autoload" = false;
      "kdeglobals"."DirSelect Dialog"."DirSelectDialog Size" = "1462,762";
      "kdeglobals"."General"."TerminalApplication" = "alacritty";
      "kdeglobals"."General"."TerminalService" = "Alacritty.desktop";
      "kdeglobals"."KDE"."ShowDeleteCommand" = false;
      "kdeglobals"."KFileDialog Settings"."Allow Expansion" = false;
      "kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = true;
      "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation" = false;
      "kdeglobals"."KFileDialog Settings"."Decoration position" = 2;
      "kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."PathCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."Show Bookmarks" = false;
      "kdeglobals"."KFileDialog Settings"."Show Full Path" = false;
      "kdeglobals"."KFileDialog Settings"."Show Inline Previews" = true;
      "kdeglobals"."KFileDialog Settings"."Show Preview" = false;
      "kdeglobals"."KFileDialog Settings"."Show Speedbar" = true;
      "kdeglobals"."KFileDialog Settings"."Show hidden files" = false;
      "kdeglobals"."KFileDialog Settings"."Sort by" = "Name";
      "kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
      "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
      "kdeglobals"."KFileDialog Settings"."Sort reversed" = false;
      "kdeglobals"."KFileDialog Settings"."Speedbar Width" = 140;
      "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";
      "kdeglobals"."PreviewSettings"."EnableRemoteFolderThumbnail" = false;
      "kdeglobals"."PreviewSettings"."MaximumRemoteSize" = 0;
      "kdeglobals"."Shortcuts"."Help" = "";
      "kdeglobals"."WM"."activeBackground" = "49,54,59";
      "kdeglobals"."WM"."activeBlend" = "252,252,252";
      "kdeglobals"."WM"."activeForeground" = "252,252,252";
      "kdeglobals"."WM"."inactiveBackground" = "42,46,50";
      "kdeglobals"."WM"."inactiveBlend" = "161,169,177";
      "kdeglobals"."WM"."inactiveForeground" = "161,169,177";
      "kiorc"."Confirmations"."ConfirmDelete" = true;
      "kiorc"."Confirmations"."ConfirmEmptyTrash" = true;
      "kiorc"."Confirmations"."ConfirmTrash" = false;
      "kiorc"."Executable scripts"."behaviourOnLaunch" = "alwaysAsk";
      "krunnerrc"."Plugins"."baloosearchEnabled" = false;
      "kservicemenurc"."Show"."compressfileitemaction" = true;
      "kservicemenurc"."Show"."extractfileitemaction" = true;
      "kservicemenurc"."Show"."forgetfileitemaction" = true;
      "kservicemenurc"."Show"."installFont" = true;
      "kservicemenurc"."Show"."kactivitymanagerd_fileitem_linking_plugin" = true;
      "kservicemenurc"."Show"."kio-admin" = true;
      "kservicemenurc"."Show"."makefileactions" = true;
      "kservicemenurc"."Show"."mountisoaction" = true;
      "kservicemenurc"."Show"."movetonewfolderitemaction" = true;
      "kservicemenurc"."Show"."nextclouddolphinactionplugin" = true;
      "kservicemenurc"."Show"."runInKonsole" = true;
      "kservicemenurc"."Show"."slideshowfileitemaction" = true;
      "kservicemenurc"."Show"."tagsfileitemaction" = true;
      "kservicemenurc"."Show"."wallpaperfileitemaction" = true;
      "ksmserverrc"."General"."loginMode" = "emptySession";
      "ksplashrc"."KSplash"."Theme" = "a2n.kuro";
      "ktrashrc"."\\/home\\/patrick\\/.local\\/share\\/Trash"."Days" = 7;
      "ktrashrc"."\\/home\\/patrick\\/.local\\/share\\/Trash"."LimitReachedAction" = 0;
      "ktrashrc"."\\/home\\/patrick\\/.local\\/share\\/Trash"."Percent" = 10;
      "ktrashrc"."\\/home\\/patrick\\/.local\\/share\\/Trash"."UseSizeLimit" = true;
      "ktrashrc"."\\/home\\/patrick\\/.local\\/share\\/Trash"."UseTimeLimit" = false;
      "kwalletrc"."Wallet"."First Use" = false;
      "kwinrc"."Desktops"."Id_1" = "f0e751e1-a3c9-4c0b-a319-6209a31638fd";
      "kwinrc"."Desktops"."Id_2" = "89001b3b-76e1-46b8-a893-8878b24847a4";
      "kwinrc"."Desktops"."Id_3" = "2e5b6191-8032-4931-bdfb-9d732b473ac8";
      "kwinrc"."Desktops"."Id_4" = "453a1516-206a-40c1-9b01-45e804ab8836";
      "kwinrc"."Desktops"."Id_5" = "9c303275-55ec-4984-8bd6-310ad656e44d";
      "kwinrc"."Desktops"."Id_6" = "4e72255a-9c2b-4780-93df-0a7adaa6077f";
      "kwinrc"."Desktops"."Number" = 6;
      "kwinrc"."Desktops"."Rows" = 6;
      "kwinrc"."Effect-overview"."BorderActivate" = 9;
      "kwinrc"."Plugins"."magiclampEnabled" = true;
      "kwinrc"."Plugins"."squashEnabled" = false;
      "kwinrc"."TabBox"."LayoutName" = "sidebar";
      "kwinrc"."TabBox"."MultiScreenMode" = 1;
      "kwinrc"."TabBox"."OrderMinimizedMode" = 1;
      "kwinrc"."Tiling"."padding" = 4;
      "kwinrc"."Tiling/24307a62-31b7-5646-9be3-efbbdc882e98"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":\x5b{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}\x5d}";
      "kwinrc"."Tiling/44892490-598a-51e9-9740-29d2778b42f0"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":\x5b{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}\x5d}";
      "kwinrc"."Tiling/488733f0-bf20-500f-aee0-7509c9c2347b"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":\x5b{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}\x5d}";
      "kwinrc"."Tiling/5b35a2a2-0916-5966-bfdf-3cceeb12beae"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/8b9fb500-1b63-5166-b5c6-a2b42f46fd98"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":\x5b{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}\x5d}";
      "kwinrc"."Tiling/92e842d7-5928-5c43-884a-4912e7cc82ed"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/b1a28ef5-49b0-53ec-a62a-87e71e6c1ba6"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/cb69c1ef-f7fa-5111-bb50-f6c837837dfc"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/d02c035d-eef0-5c68-aa2f-2e83d0ba08b1"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Xwayland"."Scale" = 1;
      "kwinrulesrc"."General"."count" = 2;
      "kwinrulesrc"."General"."rules" = "deb6e47f-c93b-43f0-a849-65962a43597a,a7abdee9-5089-43f6-853f-3bf76cae5f31";
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."Description" = "Chrome - Main";
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."activity" = "156adec6-167e-45ff-96ba-05d283f6abb8";
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."activityrule" = 3;
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."desktops" = "f0e751e1-a3c9-4c0b-a319-6209a31638fd";
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."desktopsrule" = 3;
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."position" = "0,0";
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."positionrule" = 3;
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."size" = "2521,1440";
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."sizerule" = 3;
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."windowrole" = "browser";
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."wmclass" = "google-chrome Google-chrome";
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."wmclasscomplete" = true;
      "kwinrulesrc"."a7abdee9-5089-43f6-853f-3bf76cae5f31"."wmclassmatch" = 1;
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."Description" = "Todoist";
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."activity" = "156adec6-167e-45ff-96ba-05d283f6abb8";
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."activityrule" = 3;
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."desktops" = "453a1516-206a-40c1-9b01-45e804ab8836";
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."desktopsrule" = 3;
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."position" = "0,0";
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."positionrule" = 3;
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."size" = "1323,1440";
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."sizerule" = 3;
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."windowrole" = "browser-window";
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."wmclass" = "todoist Todoist";
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."wmclasscomplete" = true;
      "kwinrulesrc"."deb6e47f-c93b-43f0-a849-65962a43597a"."wmclassmatch" = 1;
      "plasma-localerc"."Formats"."LANG" = "en_US.UTF-8";
      "plasmanotifyrc"."Applications/com.nextcloud.desktopclient.nextcloud"."Seen" = true;
      "plasmanotifyrc"."Applications/google-chrome"."Seen" = true;
      "plasmanotifyrc"."Applications/teams-for-linux"."Seen" = true;
      "plasmanotifyrc"."Applications/todoist"."Seen" = true;
      "plasmarc"."Theme"."name" = "breeze-dark";
      "plasmarc"."Wallpapers"."usersWallpapers" = "";
      "spectaclerc"."Annotations"."annotationToolType" = 6;
      "spectaclerc"."GuiConfig"."captureDelay" = 2;
      "spectaclerc"."GuiConfig"."captureMode" = 0;
      "spectaclerc"."ImageSave"."lastImageSaveAsLocation" = "file:///home/patrick/work-nextcloud/Finance/Belege/2025_02/Patrick/PERFORM_ESIM_CC.png";
      "spectaclerc"."ImageSave"."lastImageSaveLocation" = "file:///home/patrick/work-nextcloud/Finance/Belege/2025_02/Patrick/PERFORM_ESIM_CC.png";
      "spectaclerc"."ImageSave"."translatedScreenshotsFolder" = "Screenshots";
      "spectaclerc"."VideoSave"."translatedScreencastsFolder" = "Screencasts";
    };
    dataFile = {
      "dolphin/view_properties/global/.directory"."Dolphin"."ViewMode" = 1;
      "kate/anonymous.katesession"."Document 0"."URL" = "";
      "kate/anonymous.katesession"."Kate Plugins"."cmaketoolsplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."compilerexplorer" = false;
      "kate/anonymous.katesession"."Kate Plugins"."eslintplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."externaltoolsplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."formatplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katebacktracebrowserplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katebuildplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katecloseexceptplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katecolorpickerplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katectagsplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katefilebrowserplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katefiletreeplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."kategdbplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."kategitblameplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katekonsoleplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."kateprojectplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."katereplicodeplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katesearchplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."katesnippetsplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katesqlplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katesymbolviewerplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katexmlcheckplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."katexmltoolsplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."keyboardmacrosplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."ktexteditorpreviewplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."latexcompletionplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."lspclientplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."openlinkplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."rainbowparens" = false;
      "kate/anonymous.katesession"."Kate Plugins"."rbqlplugin" = false;
      "kate/anonymous.katesession"."Kate Plugins"."tabswitcherplugin" = true;
      "kate/anonymous.katesession"."Kate Plugins"."textfilterplugin" = true;
      "kate/anonymous.katesession"."MainWindow0"."Active ViewSpace" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-H-Splitter" = "0,2019,0";
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-0-Bar-0-TvList" = "kate_private_plugin_katefiletreeplugin,kateproject,kateprojectgit,lspclient_symbol_outline";
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-0-LastSize" = 200;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-0-SectSizes" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-0-Splitter" = 755;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-1-Bar-0-TvList" = "";
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-1-LastSize" = 200;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-1-SectSizes" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-1-Splitter" = 755;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-2-Bar-0-TvList" = "";
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-2-LastSize" = 200;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-2-SectSizes" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-2-Splitter" = 2019;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-3-Bar-0-TvList" = "output,diagnostics,kate_plugin_katesearch,kateprojectinfo,kate_private_plugin_katekonsoleplugin";
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-3-LastSize" = 200;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-3-SectSizes" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-3-Splitter" = 1772;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-Style" = 2;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-Sidebar-Visible" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-diagnostics-Position" = 3;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-diagnostics-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-diagnostics-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_plugin_katesearch-Position" = 3;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_plugin_katesearch-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_plugin_katesearch-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katefiletreeplugin-Position" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katefiletreeplugin-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katefiletreeplugin-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katekonsoleplugin-Position" = 3;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katekonsoleplugin-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kate_private_plugin_katekonsoleplugin-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateproject-Position" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateproject-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateproject-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectgit-Position" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectgit-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectgit-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectinfo-Position" = 3;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectinfo-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-kateprojectinfo-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-lspclient_symbol_outline-Position" = 0;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-lspclient_symbol_outline-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-lspclient_symbol_outline-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-output-Position" = 3;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-output-Show-Button-In-Sidebar" = true;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-ToolView-output-Visible" = false;
      "kate/anonymous.katesession"."MainWindow0"."Kate-MDI-V-Splitter" = "0,755,0";
      "kate/anonymous.katesession"."MainWindow0"."ToolBarsMovable" = "Disabled";
      "kate/anonymous.katesession"."MainWindow0 Settings"."ToolBarsMovable" = "Disabled";
      "kate/anonymous.katesession"."MainWindow0 Settings"."WindowState" = 8;
      "kate/anonymous.katesession"."MainWindow0-Splitter 0"."Children" = "MainWindow0-ViewSpace 0";
      "kate/anonymous.katesession"."MainWindow0-Splitter 0"."Orientation" = 1;
      "kate/anonymous.katesession"."MainWindow0-Splitter 0"."Sizes" = 2019;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0"."Active View" = 0;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0"."Count" = 1;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0"."Documents" = 0;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0"."View 0" = 0;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0 0"."CursorColumn" = 1;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0 0"."CursorLine" = 0;
      "kate/anonymous.katesession"."MainWindow0-ViewSpace 0 0"."ScrollLine" = 370;
      "kate/anonymous.katesession"."Open Documents"."Count" = 1;
      "kate/anonymous.katesession"."Open MainWindows"."Count" = 1;
      "kate/anonymous.katesession"."Plugin:kateprojectplugin:"."projects" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."BinaryFiles" = false;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."CurrentExcludeFilter" = "-1";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."CurrentFilter" = "-1";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."ExcludeFilters" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."ExpandSearchResults" = false;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."Filters" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."FollowSymLink" = false;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."HiddenFiles" = false;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."MatchCase" = false;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."Place" = 1;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."Recursive" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."Replaces" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."Search" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchAsYouTypeAllProjects" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchAsYouTypeCurrentFile" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchAsYouTypeFolder" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchAsYouTypeOpenFiles" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchAsYouTypeProject" = true;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchDiskFiles" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SearchDiskFiless" = "";
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."SizeLimit" = 128;
      "kate/anonymous.katesession"."Plugin:katesearchplugin:MainWindow:0"."UseRegExp" = false;
    };
  };
  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

    #   programs.starship = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   enableFishIntegration = true;
    #   # https://github.com/etrigan63/Catppuccin-starship
    #   settings = {
    #     add_newline = false;
    #     command_timeout = 1000;
    #     time = {
    #       disabled = true;
    #     };
    #     format = "\b[](bg:$style fg:#4169e1)[$symbol$status](bg:$style)[](fg:$style)";
    #   };
    # };

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    neofetch

    #communication
    signal-desktop
    whatsapp-for-linux
    teamspeak3


    yakuake
    google-chrome
    citrix_workspace
    teams-for-linux
    pass # secret management
    nextcloud-client

    #dev
    vscode-fhs
    direnv
    kubectl
    kubernetes-helm

    #3D printing
    prusa-slicer

  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Patrick Hofmann";
    userEmail = "git@hfmnn.com";
    extraConfig = {
      # Sign all commits using ssh key
      commit.gpgsign = true;
      tag.gpgSign = true;
      init.defaultBranch = "main";
      user.signingkey = "C992EF803666696D";
    };
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };


  # gnupg
  services = {
      gnome-keyring.enable = true;
      gpg-agent = {
          enable = true;
          defaultCacheTtl = 1800;
          enableSshSupport = true;
      };
  };
  programs.gpg.enable = true;
  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Nextcloud
  services.nextcloud-client.enable=true;
  services.nextcloud-client.startInBackground=true;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

}
