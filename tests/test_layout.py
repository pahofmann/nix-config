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


if __name__ == "__main__":
    unittest.main()
