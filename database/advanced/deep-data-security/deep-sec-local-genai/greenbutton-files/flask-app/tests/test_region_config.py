"""Keep the LiveLabs GenAI assignment separate from the resource region."""

import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from config import load_settings

BASE_ENV = {'FLASK_SECRET_KEY': 'region-test-only', 'DB_DSN': 'unused-test-dsn'}


class RegionConfigurationTests(unittest.TestCase):
    def load(self, defaults, overrides=None):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "genai-defaults"
            path.write_text(defaults, encoding="utf-8")
            env = dict(BASE_ENV, GENAI_DEFAULTS_FILE=str(path))
            env.update(overrides or {})
            with patch.dict(os.environ, env, clear=True):
                return load_settings()

    def test_region_precedence_and_legacy_compatibility(self):
        assigned = 'OCI_REGION="us-ashburn-1"\nGENAI_REGION="us-chicago-1"\n'
        for defaults, overrides, expected in [
            (assigned, {}, "us-chicago-1"),
            (assigned, {"OCI_REGION": "us-phoenix-1"}, "us-chicago-1"),
            (assigned, {"GENAI_REGION": "eu-frankfurt-1"}, "eu-frankfurt-1"),
            (assigned, {"GENAI_REGION": "  "}, "us-chicago-1"),
            ('OCI_REGION="us-ashburn-1"\n', {}, "us-ashburn-1"),
            ('OCI_REGION="us-ashburn-1"\n', {"OCI_REGION": "us-phoenix-1"}, "us-phoenix-1"),
            ('OCI_REGION="us-ashburn-1"\nGENAI_REGION=""\n', {"GENAI_REGION": ""}, "us-ashburn-1"),
            ("", {}, ""),
        ]:
            with self.subTest(defaults=defaults, overrides=overrides):
                self.assertEqual(self.load(defaults, overrides).genai_region, expected)


if __name__ == "__main__":
    unittest.main()
