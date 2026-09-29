import pathlib
import re
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]


class MultiHostDankLinuxTests(unittest.TestCase):
    def read(self, relative_path: str) -> str:
        return (ROOT / relative_path).read_text()

    def test_declares_two_hosts_with_separate_hardware(self):
        flake = self.read("flake.nix")
        self.assertIn('nixtop = mkHost "nixtop"', flake)
        self.assertIn('xps15 = mkHost "xps15"', flake)
        for host in ("nixtop", "xps15"):
            self.assertTrue((ROOT / "hosts" / host / "system.nix").is_file())
            self.assertTrue((ROOT / "hosts" / host / "hardware-configuration.nix").is_file())

    def test_desktop_uses_native_danklinux_modules_not_plasma(self):
        desktop = self.read("modules/desktop/danklinux.nix")
        self.assertIn("programs.dms-shell", desktop)
        self.assertIn("services.displayManager.dms-greeter", desktop)
        self.assertIn('compositor.name = "hyprland"', desktop)
        self.assertIn("withUWSM = true", desktop)
        self.assertNotIn("sddm", desktop)
        self.assertNotIn("plasma", desktop.lower())

    def test_active_configuration_has_no_hyprvibe_or_plasma_manager(self):
        forbidden = ("hyprvibe", "plasma-manager", "programs.plasma")
        for path in ROOT.rglob("*.nix"):
            contents = path.read_text().lower()
            for token in forbidden:
                self.assertNotIn(token, contents, f"{token} remains in {path}")

    def test_nixtop_preserves_custom_packages_and_printing(self):
        system = self.read("hosts/nixtop/system.nix")
        self.assertIn("../../modules/common/printing.nix", system)
        self.assertIn("../../modules/common/packages.nix", system)
        self.assertIn("../../modules/common/nvidia.nix", system)
        self.assertIn("./boot.nix", system)
        boot = self.read("hosts/nixtop/boot.nix")
        self.assertIn("systemd-boot.enable = true", boot)

    def test_xps_has_host_local_prime_fingerprint_and_uefi_settings(self):
        system = self.read("hosts/xps15/system.nix")
        self.assertIn('intelBusId = "PCI:0:2:0"', system)
        self.assertIn('nvidiaBusId = "PCI:1:0:0"', system)
        self.assertIn("services.fprintd.tod", system)
        self.assertIn("systemd-boot.enable = true", system)
        self.assertIn("systemd-boot.graceful = true", system)

    def test_citrix_is_enabled_only_for_nixtop(self):
        home = self.read("modules/patrick/home.nix")
        self.assertIn("host == \"nixtop\"", home)
        self.assertIn("citrixWorkspace", home)

    def test_home_file_entries_are_declared_in_one_attribute_set(self):
        home = self.read("modules/patrick/home.nix")
        self.assertEqual(home.count("  home.file = {"), 1)
        self.assertIsNone(re.search(r'^\s*home\.file\."', home, re.MULTILINE))

    def test_xps_gets_hermes_and_hyprland_workspace_shortcuts(self):
        home = self.read("modules/patrick/home.nix")
        bindings = self.read("configs/danklinux/hyprland.lua")
        self.assertIn("hermesDesktop", home)
        self.assertIn("--include-desktop --skip-setup", home)
        self.assertIn('fish_add_path "$HOME/.local/bin"', home)
        self.assertIn('".config/hypr/hyprland.lua"', home)
        self.assertIn('hl.dsp.focus({ workspace = i })', bindings)
        self.assertIn('hl.dsp.window.move({ workspace = i })', bindings)
        self.assertIn('"SUPER + SUPER_L"', bindings)
        self.assertIn('spotlight toggle', bindings)
        self.assertIn("release = true", bindings)

    def test_nixtop_preserves_desktop_workflow_in_host_hyprland_config(self):
        home = self.read("modules/patrick/home.nix")
        nixtop = self.read("configs/danklinux/nixtop.lua")
        self.assertIn('host == "nixtop"', home)
        self.assertIn('".config/hypr/nixtop.lua"', home)
        self.assertIn('pcall(dofile, "/home/patrick/.config/hypr/nixtop.lua")', self.read("configs/danklinux/hyprland.lua"))
        self.assertIn("kdePackages.yakuake", home)
        self.assertIn("kdePackages.konsole", home)
        self.assertIn("citrixWorkspace", home)
        self.assertIn('workspace = "2"', nixtop)
        self.assertIn('workspace = "3"', nixtop)
        self.assertIn('workspace = "5"', nixtop)
        self.assertIn('workspace = "9"', nixtop)
        self.assertIn('"F12"', nixtop)
        self.assertIn('"CTRL + ALT + DOWN"', nixtop)
        self.assertIn('"CTRL + ALT + SHIFT + DOWN"', nixtop)


if __name__ == "__main__":
    unittest.main()
