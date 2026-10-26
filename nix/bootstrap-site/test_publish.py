"""Non-destructive tests: no installer stages, downloads, or deployments."""

import hashlib
import json
import subprocess
import unittest
from unittest.mock import patch

import publish


class PublishTests(unittest.TestCase):
    def setUp(self):
        self.script = b"#!/usr/bin/env bash\nprintf 'fixture only\\n'\n"
        self.revision = "a" * 40
        self.files = publish.artifacts(self.script, self.revision)

    def test_only_allowlisted_public_files(self):
        self.assertEqual(
            set(self.files),
            {"dev-vm.sh", "version.json", "index.html", "404.html", "_headers"},
        )
        self.assertEqual(self.files["dev-vm.sh"], self.script)

    def test_metadata_matches_exact_script_and_commit(self):
        metadata = json.loads(self.files["version.json"])
        self.assertEqual(metadata["commit"], self.revision)
        self.assertEqual(metadata["sha256"], hashlib.sha256(self.script).hexdigest())
        self.assertIn(f"/{self.revision}/", metadata["source"])

    def test_rejects_invalid_revisions(self):
        for revision in ("", "main", "a" * 39, "<script>" + "a" * 40):
            with self.subTest(revision=revision), self.assertRaises(ValueError):
                publish.artifacts(self.script, revision)

    def test_revalidation_and_plain_text_script_headers(self):
        headers = self.files["_headers"].decode()
        self.assertIn("Cache-Control: public, max-age=0, must-revalidate", headers)
        self.assertIn("/dev-vm.sh\n  Content-Type: text/plain; charset=utf-8", headers)
        self.assertIn("X-Content-Type-Options: nosniff", headers)

    def test_metadata_mismatch_stops_before_writing(self):
        with (
            patch.dict(publish.os.environ, {"CF_PAGES_COMMIT_SHA": "b" * 40}),
            patch.object(publish.subprocess, "check_output", return_value=self.revision),
            patch.object(publish.subprocess, "run") as run,
            patch.object(publish.Path, "mkdir") as mkdir,
        ):
            with self.assertRaisesRegex(RuntimeError, "does not match"):
                publish.main()
            run.assert_not_called()
            mkdir.assert_not_called()

    def test_bootstrap_help_and_invalid_command_only(self):
        script = publish.REPOSITORY / "nix/bootstrap-dev-vm.sh"
        # Never call install or configure, even on a developer's NixOS machine.
        for argument, expected in (("--help", 0), ("not-a-command", 1)):
            with self.subTest(argument=argument):
                result = subprocess.run(
                    ["bash", str(script), argument],
                    capture_output=True,
                    text=True,
                    check=False,
                )
                self.assertEqual(result.returncode, expected)
                self.assertIn("Usage:", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
