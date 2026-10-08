"""Regression tests for the standalone lesson content boundary."""

from pathlib import Path
import tempfile
import unittest

from content_loader import ContentValidationError, load_lesson
from content_runtime import build_runtime_content


ADMIN_APP_DIR = Path(__file__).resolve().parents[1]
MANIFEST = ADMIN_APP_DIR / "content" / "deep_data_security" / "lab.yaml"


class ContentLoaderTests(unittest.TestCase):
    def test_deep_sec_manifest_loads_with_complete_shape(self) -> None:
        lesson = load_lesson(MANIFEST)
        self.assertEqual(lesson.id, "deep_data_security")
        self.assertEqual(len(lesson.pages), 10)
        self.assertEqual(len(lesson.steps), 41)
        self.assertEqual(len(lesson.actions), 42)
        self.assertEqual(len(lesson.overview["stages"]), 8)
        self.assertEqual(lesson.overview["start_path"], "/db-setup")
        self.assertEqual(lesson.overview["scenario_heading"], "The scenario")
        self.assertIn("Marvin is a salesperson", lesson.overview["scenario"])
        self.assertEqual(len(lesson.tour), 9)
        self.assertEqual(lesson.tour[0]["title"], "DB Setup")
        self.assertEqual(
            sum(len(action.scripts) for action in lesson.actions.values()),
            33,
        )
        self.assertEqual(
            lesson.actions["customize_manager_grant"].handler,
            "data_grant",
        )
        self.assertFalse(lesson.actions["customize_manager_grant"].confirm_apply)
        self.assertFalse(lesson.actions["extend_manager_context"].confirm_apply)
        self.assertFalse(lesson.actions["restore_db_setup"].config["scripts_open"])
        self.assertFalse(lesson.actions["restore_deep_sec_setup"].config["scripts_open"])
        self.assertEqual(lesson.pages[-4].id, "exercises")
        self.assertEqual(lesson.pages[-3].id, "best_practices")
        self.assertEqual(lesson.pages[-2].id, "what_you_proved")
        self.assertEqual(lesson.pages[4].label, "Context")
        self.assertEqual(len(lesson.pages[-3].step_ids), 6)
        self.assertEqual(
            [lesson.step_by_id[step_id].title for step_id in lesson.pages[-3].step_ids],
            [
                "Authorization Mode",
                "End User Context",
                "Application Connections",
                "Least Privilege",
                "Privilege Elevation",
                "Audit Policies",
            ],
        )
        self.assertEqual(
            lesson.actions["best_practice_trusted_identity"].config["asset"],
            "best-practice-trusted-identity.svg",
        )
        identity_examples = lesson.actions["best_practice_trusted_identity"].config["examples"]
        self.assertEqual(len(identity_examples), 3)
        self.assertIn("DROP END USER marvin;", identity_examples[0]["code"])
        self.assertEqual(
            lesson.actions["best_practice_minimal_connections"].config["examples"][0]["language"],
            "SQL",
        )
        self.assertIn(
            "ORA_END_USER_CONTEXT.username",
            lesson.actions["best_practice_least_privilege"].config["examples"][0]["code"],
        )
        audit_examples = lesson.actions["best_practice_policy_lifecycle"].config["examples"]
        self.assertIn("CREATE DATA ROLE", audit_examples[2]["code"])
        self.assertIn("CREATE DATA GRANT", audit_examples[2]["code"])
        self.assertIn("UNIFIED_AUDIT_TRAIL", audit_examples[3]["code"].upper())
        self.assertIn("DBA_DATA_ROLE_GRANTS", audit_examples[3]["code"].upper())
        self.assertNotIn("vibe-coding", {page.id for page in lesson.pages})
        self.assertEqual(lesson.actions["exercise_reset"].completion, "mark_viewed")
        self.assertEqual(
            [stage["estimated_minutes"] for stage in lesson.overview["stages"]],
            [5, 10, 5, 10, 10, 10, 5, 5],
        )
        self.assertEqual(lesson.actions["what_you_proved"].config["result_sets"][2]["description"], "9 rows after the employee and manager grants union together.")

    def test_runtime_content_preserves_configured_pages_and_wizards(self) -> None:
        lesson = load_lesson(MANIFEST)
        actions, steps, pages = build_runtime_content(lesson)
        self.assertEqual(actions["customize_employee_grant"]["type"], "wizard")
        self.assertEqual(actions["extend_manager_context"]["grant_wizard"]["style"], "all_except")
        self.assertFalse(actions["restore_db_setup"]["config"]["scripts_open"])
        self.assertFalse(actions["restore_deep_sec_setup"]["config"]["scripts_open"])
        self.assertEqual(pages[-4]["key"], "exercises")
        self.assertEqual(pages[-3]["key"], "best_practices")
        self.assertEqual(pages[-2]["key"], "what_you_proved")
        self.assertEqual(len(pages[-3]["step_keys"]), 6)
        self.assertFalse(pages[-1]["ordered"])
        self.assertEqual(len(steps), 41)

    def test_unknown_action_reference_is_reported(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "lab.yaml").write_text(
                """
schema_version: 1
id: example
title: Example
script_root: database
actions:
  one:
    type: mark_viewed
    title: One
    description: One
steps:
  - id: first
    badge: "1"
    label: First
    title: First
    action_ids: [missing]
pages:
  - id: page
    path: /page
    label: Page
    step_ids: [first]
""",
                encoding="utf-8",
            )
            (root / "database").mkdir()
            with self.assertRaisesRegex(ContentValidationError, "unknown action 'missing'"):
                load_lesson(root / "lab.yaml")

    def test_dependency_cycle_is_reported(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "database").mkdir()
            (root / "database" / "one.sql").write_text("select 1 from dual;\n", encoding="utf-8")
            (root / "lab.yaml").write_text(
                """
schema_version: 1
id: example
title: Example
script_root: database
actions:
  one:
    type: sql
    title: One
    description: One
    scripts: [one.sql]
    requires: [two]
  two:
    type: mark_viewed
    title: Two
    description: Two
    requires: [one]
steps:
  - id: first
    badge: "1"
    label: First
    title: First
    action_ids: [one]
pages:
  - id: page
    path: /page
    label: Page
    step_ids: [first]
""",
                encoding="utf-8",
            )
            with self.assertRaisesRegex(ContentValidationError, "action dependency cycle"):
                load_lesson(root / "lab.yaml")


if __name__ == "__main__":
    unittest.main()
