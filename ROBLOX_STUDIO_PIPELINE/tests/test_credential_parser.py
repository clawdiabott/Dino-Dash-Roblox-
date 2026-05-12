import tempfile
import unittest
from pathlib import Path

from tools.roblox_env import load_env_file, normalize_path, redact_env


class CredentialParserTests(unittest.TestCase):
    def test_load_env_file_parses_named_values_without_leaking_comments(self) -> None:
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "roblox api.txt"
            p.write_text(
                "\n".join(
                    [
                        "# comment",
                        "ROBLOX_OPEN_CLOUD_API_KEY_CLAWMACHINE=secret-value",
                        "ROBLOX_UNIVERSE_ID_CLAWMACHINE=101",
                        "ROBLOX_PLACE_ID_CLAWMACHINE=202",
                    ]
                ),
                encoding="utf-8",
            )

            data = load_env_file(p)

            self.assertEqual(data["ROBLOX_OPEN_CLOUD_API_KEY_CLAWMACHINE"], "secret-value")
            self.assertEqual(data["ROBLOX_UNIVERSE_ID_CLAWMACHINE"], "101")
            self.assertEqual(data["ROBLOX_PLACE_ID_CLAWMACHINE"], "202")
            self.assertNotIn("# comment", data)

    def test_redact_env_hides_secret_values_but_keeps_ids_visible(self) -> None:
        data = {
            "ROBLOX_OPEN_CLOUD_API_KEY_CLAWMACHINE": "secret-value",
            "ROBLOX_UNIVERSE_ID_CLAWMACHINE": "101",
            "ROBLOX_PLACE_ID_CLAWMACHINE": "202",
        }

        redacted = redact_env(data)

        self.assertEqual(redacted["ROBLOX_OPEN_CLOUD_API_KEY_CLAWMACHINE"], "***REDACTED***")
        self.assertEqual(redacted["ROBLOX_UNIVERSE_ID_CLAWMACHINE"], "101")
        self.assertEqual(redacted["ROBLOX_PLACE_ID_CLAWMACHINE"], "202")

    def test_normalize_path_translates_windows_drive_path_inside_wsl(self) -> None:
        self.assertEqual(
            normalize_path(r"D:\\Openclaw\\CLAWDIAS-CLAWMACHINE"),
            Path("/mnt/d/Openclaw/CLAWDIAS-CLAWMACHINE"),
        )


if __name__ == "__main__":
    unittest.main()
