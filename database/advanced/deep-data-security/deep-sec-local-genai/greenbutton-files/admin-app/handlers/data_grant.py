"""Configuration-driven Oracle data-grant SQL generation."""

from __future__ import annotations

from typing import Any, Mapping


def build_data_grant_sql(config: Mapping[str, Any], payload: Mapping[str, Any]) -> str:
    """Build a data grant from a lesson's allow-listed configuration.

    The browser supplies choices only. Object names, column names, predicates,
    and grant targets all come from checked-in lesson content.
    """

    if config.get("mode") == "all_except":
        return _build_all_except(config, payload)
    return _build_column_grant(config, payload)


def _build_column_grant(config: Mapping[str, Any], payload: Mapping[str, Any]) -> str:
    selected = _string_list(payload.get("columns", []), "columns")
    update_columns = _string_list(payload.get("update_columns", []), "update_columns")
    allow_delete = _bool(payload.get("allow_delete", False), "allow_delete")
    restrict_rows = _bool(payload.get("restrict_rows", False), "restrict_rows")

    if allow_delete and not config.get("allow_delete_option"):
        raise ValueError("DELETE is not available for this data-grant wizard.")

    required = _config_columns(config, "required_columns")
    optional = _config_columns(config, "optional_columns")
    updatable = _config_columns(config, "updatable_columns")
    all_columns = required + optional

    _reject_unknown(selected, optional, "Unknown column(s)")
    _reject_unknown(update_columns, updatable, "Unknown update column(s)")
    not_selected = set(update_columns) - set(selected)
    if not_selected:
        raise ValueError(
            "Column(s) must be selected before granting UPDATE: "
            f"{', '.join(sorted(not_selected))}"
        )

    ordered_select = [column for column in all_columns if column in required or column in selected]
    ordered_update = [column for column in all_columns if column in update_columns]
    privilege_clauses = [f"select ({', '.join(ordered_select)})"]
    if ordered_update:
        privilege_clauses.append(f"update ({', '.join(ordered_update)})")
    if allow_delete:
        privilege_clauses.append("delete")

    grant_name = _required_config_string(config, "grant_name")
    role = _required_config_string(config, "role")
    table = _required_config_string(config, "table")
    lines = [
        f"create or replace data grant {grant_name}",
        f"  as {', '.join(privilege_clauses)}",
        f"  on {table}",
    ]

    restriction = config.get("row_restriction", {})
    if not isinstance(restriction, Mapping):
        raise ValueError("row_restriction configuration must be a mapping")
    restriction_mode = restriction.get("mode", "none")
    if restriction_mode == "fixed" or (restriction_mode == "toggle" and restrict_rows):
        predicate = _required_config_string(restriction, "predicate")
        lines.append(f"  where {predicate}")
    elif restriction_mode not in {"none", "toggle", "fixed"}:
        raise ValueError(f"Unsupported row restriction mode: {restriction_mode!r}")
    lines.append(f"  to {role};")
    return "\n".join(lines)


def _build_all_except(config: Mapping[str, Any], payload: Mapping[str, Any]) -> str:
    excluded = _string_list(payload.get("excluded_columns", []), "excluded_columns")
    optional = _config_columns(config, "optional_columns")
    _reject_unknown(excluded, optional, "Unknown column(s)")
    ordered_exclude = [column for column in optional if column in excluded]
    select_clause = (
        f"select (all columns except {', '.join(ordered_exclude)})"
        if ordered_exclude
        else "select"
    )
    grant_name = _required_config_string(config, "grant_name")
    table = _required_config_string(config, "table")
    when_select = _required_config_string(config, "when_select")
    predicate = _required_config_string(config, "predicate")
    return (
        f"create or replace data grant {grant_name}\n"
        f"  as {select_clause}\n"
        f"  on {table}\n"
        f"  when select (customer_id) granted on {when_select}\n"
        f"  where {predicate};"
    )


def _config_columns(config: Mapping[str, Any], key: str) -> tuple[str, ...]:
    value = config.get(key)
    if not isinstance(value, list) or not all(isinstance(item, str) and item for item in value):
        raise ValueError(f"{key} configuration must be a non-empty list of column names")
    return tuple(value)


def _required_config_string(config: Mapping[str, Any], key: str) -> str:
    value = config.get(key)
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"{key} configuration must be a non-empty string")
    return value


def _string_list(value: Any, name: str) -> list[str]:
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise ValueError(f"Invalid {name} selection.")
    return value


def _bool(value: Any, name: str) -> bool:
    if not isinstance(value, bool):
        raise ValueError(f"Invalid {name} selection.")
    return value


def _reject_unknown(selected: list[str], allowed: tuple[str, ...], label: str) -> None:
    invalid = set(selected) - set(allowed)
    if invalid:
        raise ValueError(f"{label}: {', '.join(sorted(invalid))}")
