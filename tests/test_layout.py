from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MultiHostLayoutTests(unittest.TestCase):
    def test_multihost_hyprvibe_layout_is_declared(self):
        flake = (ROOT / "flake.nix").read_text()
        self.assertIn("nixosConfigurations", flake)
        self.assertIn("nixtop", flake)
        self.assertIn("xps15", flake)
        self.assertIn("hyprland", flake)

        for relative_path in [
            "hosts/nixtop/system.nix",
            "hosts/xps15/system.nix",
            "modules/hyprvibe/default.nix",
            "modules/patrick/printing.nix",
            "configs/hyprland-base.lua",
        ]:
            self.assertTrue((ROOT / relative_path).is_file(), relative_path)

    def test_no_machine_specific_hardware_is_shared(self):
        shared = ROOT / "modules" / "patrick"
        for path in shared.rglob("*.nix"):
            text = path.read_text()
            self.assertNotIn("nvidia.NVreg_", text, path)
            self.assertNotIn("/dev/disk/by-uuid/", text, path)

    def test_xps15_has_its_own_storage_and_prime_offload_config(self):
        hardware = (ROOT / "hosts/xps15/hardware-configuration.nix").read_text()
        system = (ROOT / "hosts/xps15/system.nix").read_text()
        self.assertIn("15bd307e-401d-4385-843e-bbe0bfa4cc66", hardware)
        self.assertIn("78C9-94C3", hardware)
        self.assertNotIn("assertion = false", hardware)
        self.assertIn('intelBusId = "PCI:0:2:0"', system)
        self.assertIn('nvidiaBusId = "PCI:1:0:0"', system)
        self.assertIn("prime.offload.enable = true", system)

    def test_xps15_goodix_533c_uses_the_supported_tod_driver(self):
        system = (ROOT / "hosts/xps15/system.nix").read_text()
        self.assertIn("services.fprintd.enable = true", system)
        self.assertIn("services.fprintd.tod.enable = true", system)
        self.assertIn("services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix", system)


if __name__ == "__main__":
    unittest.main()
