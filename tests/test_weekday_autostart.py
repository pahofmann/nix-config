import pathlib
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
HOME_NIX = (ROOT / "modules/patrick/home.nix").read_text()


class WeekdayAutostartTests(unittest.TestCase):
    def test_work_apps_use_a_weekday_gate_before_their_delay(self):
        self.assertIn('name = "weekday-autostart"', HOME_NIX)
        self.assertIn('date +%u', HOME_NIX)
        self.assertIn('1|2|3|4|5', HOME_NIX)
        self.assertIn(
            'Exec=${weekdayAutostart}/bin/weekday-autostart '
            '${delayedAutostart}/bin/delayed-autostart 3 '
            '/run/current-system/sw/bin/webex-wrapped',
            HOME_NIX,
        )
        self.assertIn(
            'Exec=${weekdayAutostart}/bin/weekday-autostart '
            '${delayedAutostart}/bin/delayed-autostart 3 '
            '${pkgs.teams-for-linux}/bin/teams-for-linux',
            HOME_NIX,
        )

    def test_personal_apps_remain_unrestricted(self):
        self.assertIn(
            'Exec=${delayedAutostart}/bin/delayed-autostart 3 '
            '${pkgs.signal-desktop}/bin/signal-desktop',
            HOME_NIX,
        )


if __name__ == "__main__":
    unittest.main()
