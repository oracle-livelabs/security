"""Action handlers used by the lesson engine."""

from .data_grant import build_data_grant_sql


HANDLERS = {
    "data_grant": build_data_grant_sql,
}
