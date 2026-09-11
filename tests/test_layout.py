from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MultiHostLayoutTests(unittest.TestCase):
    def test_danklinux_is_the_declared_desktop_base(self):
        flake = (ROOT / "flake.nix").read_text()
        desktop = (ROOT / "modules/desktop/danklinux.nix").read_text()

        self.assertIn('url = "github:AvengeMedia/DankMaterialShell/stable"', flake)
        self.assertNotIn("hyprland = {", flake)
        self.assertIn("inputs.dms.nixosModules.dank-material-shell", desktop)
        self.assertIn("programs.dank-material-shell", desktop)
        self.assertIn("programs.hyprland", desktop)
        self.assertFalse((ROOT / "modules/hyprvibe").exists())

    def test_multihost_layout_is_declared(self):
        flake = (ROOT / "flake.nix").read_text()
        self.assertIn("nixosConfigurations", flake)
        self.assertIn("nixtop", flake)
        self.assertIn("xps15", flake)

        for relative_path in [
            "hosts/nixtop/system.nix",
            "hosts/xps15/system.nix",
            "hosts/nixtop/hyprland.lua",
            "hosts/xps15/hyprland.lua",
            "modules/desktop/danklinux.nix",
            "modules/patrick/printing.nix",
            "configs/danklinux/hyprland-base.lua",
        ]:
            self.assertTrue((ROOT / relative_path).is_file(), relative_path)

    def test_no_machine_specific_hardware_is_shared(self):
        shared = ROOT / "modules" / "patrick"
        for path in shared.rglob("*.nix"):
            text = path.read_text()
            self.assertNotIn("nvidia.NVreg_", text, path)
            self.assertNotIn("/dev/disk/by-uuid/", text, path)

    def test_xps15_has_its_own_storage_prime_and_fingerprint_config(self):
        hardware = (ROOT / "hosts/xps15/hardware-configuration.nix").read_text()
        system = (ROOT / "hosts/xps15/system.nix").read_text()
        hyprland = (ROOT / "hosts/xps15/hyprland.lua").read_text()

        self.assertIn("15bd307e-401d-4385-843e-bbe0bfa4cc66", hardware)
        self.assertIn("78C9-94C3", hardware)
        self.assertIn('intelBusId = "PCI:0:2:0"', system)
        self.assertIn('nvidiaBusId = "PCI:1:0:0"', system)
        self.assertIn("prime.offload.enable = true", system)
        self.assertIn("services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix", system)
        self.assertIn("boot.loader.systemd-boot.enable = true", system)
        self.assertIn('scale = 2', hyprland)

    def test_each_uefi_host_uses_systemd_boot_not_grub(self):
        for host in ["nixtop", "xps15"]:
            system = (ROOT / f"hosts/{host}/system.nix").read_text()
            self.assertIn("boot.loader.systemd-boot.enable = true", system)
            self.assertIn("boot.loader.efi.canTouchEfiVariables = true", system)
            self.assertNotIn("boot.loader.grub", system)
            self.assertNotIn("boot.loader = {", system)

    def test_dms_shortcuts_and_terminal_fallback_are_declared(self):
        hyprland = (ROOT / "configs/danklinux/hyprland-base.lua").read_text()
        packages = (ROOT / "modules/patrick/packages.nix").read_text()

        self.assertIn('dms ipc call spotlight toggle', hyprland)
        self.assertIn('dms ipc call settings focusOrToggle', hyprland)
        self.assertIn('dms ipc call lock lock', hyprland)
        self.assertIn('hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("kitty"))', hyprland)
        self.assertIn('systemctl --user start dms.service', hyprland)
        self.assertIn('kitty', packages)
        self.assertIn('dolphin', packages)

    def test_ci_builds_both_system_closures(self):
        workflow = (ROOT / ".github/workflows/nix.yml").read_text()
        self.assertIn("feat/danklinux-multihost", workflow)
        self.assertIn("host: [nixtop, xps15]", workflow)
        self.assertIn("nixosConfigurations.${{ matrix.host }}.config.system.build.toplevel", workflow)


if __name__ == "__main__":
    unittest.main()
