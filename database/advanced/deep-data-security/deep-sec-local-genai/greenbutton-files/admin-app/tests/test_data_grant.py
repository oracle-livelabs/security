"""Golden tests for the configuration-driven data-grant handler."""

from pathlib import Path
import unittest

from content_loader import load_lesson
from handlers.data_grant import build_data_grant_sql


ADMIN_APP_DIR = Path(__file__).resolve().parents[1]
MANIFEST = ADMIN_APP_DIR / "content" / "deep_data_security" / "lab.yaml"


class DataGrantHandlerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        lesson = load_lesson(MANIFEST)
        cls.employee = lesson.actions["customize_employee_grant"].config
        cls.manager = lesson.actions["customize_manager_grant"].config
        cls.order_history = lesson.actions["extend_manager_context"].config

    def test_employee_sql_matches_existing_builder(self) -> None:
        sql = build_data_grant_sql(
            self.employee,
            {
                "columns": [
                    "sensitive_identifier",
                    "customer_name",
                    "sales_rep",
                    "region",
                    "revenue",
                    "credit_limit",
                ],
                "update_columns": ["revenue", "customer_name"],
                "allow_delete": False,
                "restrict_rows": True,
            },
        )
        self.assertEqual(
            sql,
            "create or replace data grant APPLAB.employee_customer_access\n"
            "  as select (customer_id, sales_rep, customer_name, region, revenue, credit_limit, sensitive_identifier), update (customer_name, revenue)\n"
            "  on APPLAB.customers\n"
            "  where upper(sales_rep) = upper(ora_end_user_context.username)\n"
            "  to hol_datarole_employee_access;",
        )

    def test_manager_sql_matches_existing_builder(self) -> None:
        sql = build_data_grant_sql(
            self.manager,
            {
                "columns": [
                    "sensitive_identifier",
                    "credit_limit",
                    "revenue",
                    "sales_rep",
                    "region",
                    "customer_name",
                ],
                "update_columns": ["sales_rep", "customer_name", "region"],
                "allow_delete": False,
                "restrict_rows": False,
            },
        )
        self.assertEqual(
            sql,
            "create or replace data grant APPLAB.manager_customer_access\n"
            "  as select (customer_id, manager_id, customer_name, region, sales_rep, revenue, credit_limit, sensitive_identifier), update (customer_name, region, sales_rep)\n"
            "  on APPLAB.customers\n"
            "  where manager_id = ora_end_user_context.APPLAB.MGR_CTX.id\n"
            "  to hol_datarole_manager_access;",
        )

    def test_order_history_sql_matches_existing_builder(self) -> None:
        sql = build_data_grant_sql(
            self.order_history,
            {"excluded_columns": ["amount", "product_category"]},
        )
        self.assertEqual(
            sql,
            "create or replace data grant APPLAB.order_history_by_customer_access\n"
            "  as select (all columns except product_category, amount)\n"
            "  on APPLAB.order_history\n"
            "  when select (customer_id) granted on APPLAB.customers\n"
            "  where APPLAB.order_history.customer_id = APPLAB.customers.customer_id;",
        )

    def test_order_history_without_exclusions_uses_plain_select(self) -> None:
        sql = build_data_grant_sql(
            self.order_history,
            {"excluded_columns": []},
        )
        self.assertEqual(
            sql,
            "create or replace data grant APPLAB.order_history_by_customer_access\n"
            "  as select\n"
            "  on APPLAB.order_history\n"
            "  when select (customer_id) granted on APPLAB.customers\n"
            "  where APPLAB.order_history.customer_id = APPLAB.customers.customer_id;",
        )

    def test_update_requires_selected_column(self) -> None:
        with self.assertRaisesRegex(ValueError, "must be selected"):
            build_data_grant_sql(
                self.employee,
                {
                    "columns": ["customer_name"],
                    "update_columns": ["revenue"],
                    "allow_delete": False,
                    "restrict_rows": False,
                },
            )

    def test_browser_cannot_supply_an_unknown_column(self) -> None:
        with self.assertRaisesRegex(ValueError, "Unknown column"):
            build_data_grant_sql(
                self.employee,
                {
                    "columns": ["customer_name", "not_a_column"],
                    "update_columns": [],
                    "allow_delete": False,
                    "restrict_rows": False,
                },
            )

    def test_delete_must_be_exposed_by_lesson_configuration(self) -> None:
        config = dict(self.manager)
        config.pop("allow_delete_option")
        with self.assertRaisesRegex(ValueError, "DELETE is not available"):
            build_data_grant_sql(config, {"columns": ["customer_name"], "allow_delete": True})


if __name__ == "__main__":
    unittest.main()
