"""Keep the LiveLabs GenAI assignment separate from the resource region."""

import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from admin_config import load_admin_settings

BASE_ENV = {'ADMIN_FLASK_SECRET_KEY': 'region-test-only', 'ADMIN_DB_DSN': 'unused-test-dsn', 'ORDER_HISTORY_BUCKET': 'test-bucket', 'ORDER_HISTORY_NAMESPACE': 'test-namespace', 'ORDER_HISTORY_READ_PAR_URL': 'https://example.invalid/read', 'ORDER_HISTORY_PREFIX': 'order_history/', 'ORDER_HISTORY_OBJECT_READ_PAR_URLS': '{"order_history/metadata/v1.metadata.json": "https://example.invalid/metadata"}'}


class RegionConfigurationTests(unittest.TestCase):
    def load(self, defaults, overrides=None):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "genai-defaults"
            path.write_text(defaults, encoding="utf-8")
            env = dict(BASE_ENV, GENAI_DEFAULTS_FILE=str(path))
            env.update(overrides or {})
            with patch.dict(os.environ, env, clear=True):
                return load_admin_settings()

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

    def test_object_storage_links_stay_in_resource_region(self):
        import io
        import importlib

        settings = self.load('OCI_REGION="us-ashburn-1"\nGENAI_REGION="us-chicago-1"\n')
        self.assertEqual(settings.oci_region, "us-ashburn-1")
        with patch.dict(os.environ, dict(BASE_ENV, GENAI_DEFAULTS_FILE="/nonexistent/region-test"), clear=True):
            application = importlib.import_module("admin_app")
        with patch.object(application, "settings", settings), \
             patch.dict(application.app.config, TESTING=True, LOGIN_DISABLED=True, WTF_CSRF_ENABLED=False), \
             patch.object(application, "_record_completed_action", return_value=[]), \
             patch.object(application, "_record_action_output"), \
             patch.object(application.urllib.request, "urlopen", return_value=io.BytesIO(b'{}')) as fetch:
            response = application.app.test_client().post("/api/actions/show_iceberg_files")
        self.assertEqual(response.status_code, 200)
        output = response.get_json()["output"]
        self.assertIn("https://objectstorage.us-ashburn-1.oraclecloud.com/", output)
        self.assertNotIn("objectstorage.us-chicago-1", output)
        fetch.assert_called_once_with("https://example.invalid/metadata", timeout=10)


if __name__ == "__main__":
    unittest.main()
