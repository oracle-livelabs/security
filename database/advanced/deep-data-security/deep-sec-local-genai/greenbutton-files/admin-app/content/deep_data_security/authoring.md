# Lesson content authoring

This directory contains the editable content for one lesson. The generic
Admin Console loads one lab.yaml file when it starts. The lesson manifest,
learner-display SQL, and executable SQL are kept together in this directory.

## Edit the lesson

Use lab.yaml for the lesson structure and learner-facing text:

- overview controls the landing-page introduction, architecture image text,
  stage table, and start button.
- pages controls navigation and page order.
- steps controls the step badge, label, title, actions, next hint, notes,
  and optional quiz.
- actions controls the action title, description, SQL scripts, prerequisites,
  button labels, confirmation behavior, and action type.
- tour controls the guided-tour selector, title, and explanation for each
  navigation item. Selectors must match the page links defined in pages.
- config contains settings for a named handler such as a wizard. The current
  data_grant handler uses allow-listed database names and columns from this
  section; the browser can submit selections, but it cannot submit SQL.

For a column-grant wizard, use mode omitted or column_grant-style settings:
required_columns, optional_columns, updatable_columns, grant_name, role,
table, and row_restriction. Use mode: all_except with optional_columns,
grant_name, table, when_select, and predicate for a cross-table grant.
The columns list controls the labels and defaults shown in the wizard.

Step badges are explicit. Use "1", "2", and so on for ordinary steps, and
letters such as V, D, or R for utility steps.

SQL files are never supplied by the browser. They are checked-in files named
by the action's scripts list. A matching <name>.display.sql file is shown
to learners when it exists; otherwise the executable SQL is displayed.

The actual SQL*Plus output is runtime state and does not belong in lab.yaml.
Use output_title for the heading shown above that output. Use the step notes,
description, or quiz explanation for teaching text about the expected result.

## Validate before publishing

From the admin-app directory, run:

    python3 validate_content.py

The validator checks the schema, duplicate IDs, page and action references,
action dependency cycles, handler requirements, and every configured SQL file.

Do not add Python imports, shell commands, passwords, wallet contents, or
inline SQL statements to the manifest. New interactive behavior must be added
as a reviewed handler in the application and then referenced by its registered
name. The handler registry is intentionally small and explicit: content can
select a reviewed capability, but cannot execute arbitrary code.

## Oracle references

The data-grant examples follow Oracle's `CREATE DATA GRANT` syntax, including
row predicates, column privileges, `ALL COLUMNS EXCEPT`, and cross-table
authorization:

- [CREATE DATA GRANT](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/create-data-grant.html)
- [Create Data Grants](https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/create-data-grants.html)
- [Configure Data Roles](https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/configure-data-roles-l.html)
