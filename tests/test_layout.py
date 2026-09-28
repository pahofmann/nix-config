import pathlib
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

    def test_citrix_is_enabled_only_for_nixtop(self):
        home = self.read("modules/patrick/home.nix")
        self.assertIn("host == \"nixtop\"", home)
        self.assertIn("citrixWorkspace", home)


if __name__ == "__main__":
    unittest.main()
