"""Load and validate one lesson content pack.

This module is deliberately independent from Flask and the Oracle client.
It is the boundary between the generic lesson engine and a lesson's editable
content.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import re
from typing import Any, Mapping, Optional, Union

import yaml


SCHEMA_VERSION = 1
_ID_PATTERN = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_-]*$")
SUPPORTED_ACTION_TYPES = frozenset(
    {"sql", "wizard", "link", "mark_viewed", "explanation", "object_storage", "download"}
)
REGISTERED_HANDLER_NAMES = frozenset({"data_grant", "iceberg_files"})


class ContentValidationError(ValueError):
    """Raised when a lesson manifest cannot be safely loaded."""

    def __init__(self, errors: list[str]):
        self.errors = tuple(errors)
        super().__init__("\n".join(self.errors))


@dataclass(frozen=True)
class ScriptDefinition:
    """One executable script and the safe display source shown to learners."""

    name: str
    run_path: Path
    display_path: Path


@dataclass(frozen=True)
class ActionDefinition:
    """Normalized action metadata consumed by the future generic engine."""

    id: str
    title: str
    description: str
    type: str
    scripts: tuple[ScriptDefinition, ...] = ()
    destructive: bool = False
    needs_password: bool = False
    password_scripts: tuple[str, ...] = ()
    database_user: str = "ADMIN"
    requires: tuple[str, ...] = ()
    resets_setup: bool = False
    restored_actions: tuple[str, ...] = ()
    internal_secret_script: Optional[str] = None
    short_label: Optional[str] = None
    button_label: Optional[str] = None
    link_button_label: Optional[str] = None
    link_target: Optional[str] = None
    completion: Optional[str] = None
    handler: Optional[str] = None
    confirm_apply: bool = True
    output_title: Optional[str] = None
    config: Mapping[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class QuizDefinition:
    question: str
    options: tuple[Mapping[str, str], ...]
    correct_answer: str
    explanation: str


@dataclass(frozen=True)
class StepDefinition:
    id: str
    badge: str
    label: str
    title: str
    action_ids: tuple[str, ...]
    next_hint: Optional[str] = None
    notes: tuple[str, ...] = ()
    quiz: Optional[QuizDefinition] = None


@dataclass(frozen=True)
class PageDefinition:
    id: str
    path: str
    label: str
    step_ids: tuple[str, ...]
    renderer: Optional[str] = None
    ordered: bool = True


@dataclass(frozen=True)
class LessonDefinition:
    id: str
    title: str
    footer: str
    source_path: Path
    script_root: Path
    actions: Mapping[str, ActionDefinition]
    steps: tuple[StepDefinition, ...]
    pages: tuple[PageDefinition, ...]
    branding: Mapping[str, Any] = field(default_factory=dict)
    overview: Mapping[str, Any] = field(default_factory=dict)
    tour: tuple[Mapping[str, str], ...] = ()

    @property
    def step_by_id(self) -> Mapping[str, StepDefinition]:
        return {step.id: step for step in self.steps}


def load_lesson(manifest_path: Union[str, Path]) -> LessonDefinition:
    """Read, validate, and normalize a lesson manifest."""

    source_path = Path(manifest_path).expanduser().resolve()
    errors: list[str] = []
    if not source_path.is_file():
        raise ContentValidationError([f"{source_path}: manifest file does not exist"])

    try:
        raw = yaml.safe_load(source_path.read_text(encoding="utf-8"))
    except yaml.YAMLError as exc:
        raise ContentValidationError([f"{source_path}: invalid YAML: {exc}"]) from exc
    except OSError as exc:
        raise ContentValidationError([f"{source_path}: cannot read manifest: {exc}"]) from exc

    if not isinstance(raw, dict):
        raise ContentValidationError([f"{source_path}: the manifest root must be a mapping"])

    lesson = _normalize(raw, source_path, errors)
    if errors:
        raise ContentValidationError(errors)
    assert lesson is not None
    return lesson


def _normalize(raw: dict[str, Any], source_path: Path, errors: list[str]) -> Optional[LessonDefinition]:
    _check_keys(
        raw,
        {
            "schema_version",
            "id",
            "title",
            "branding",
            "script_root",
            "overview",
            "tour",
            "actions",
            "steps",
            "pages",
        },
        "manifest",
        errors,
    )
    _require(raw, "schema_version", "manifest", errors)
    _require(raw, "id", "manifest", errors)
    _require(raw, "title", "manifest", errors)
    _require(raw, "actions", "manifest", errors)
    _require(raw, "steps", "manifest", errors)
    _require(raw, "pages", "manifest", errors)

    if raw.get("schema_version") != SCHEMA_VERSION:
        errors.append(
            f"{source_path}: unsupported schema_version {raw.get('schema_version')!r}; "
            f"expected {SCHEMA_VERSION}"
        )
    lesson_id = _id(raw.get("id"), "manifest.id", errors)
    title = _string(raw.get("title"), "manifest.title", errors)

    branding = raw.get("branding", {})
    if not isinstance(branding, dict):
        errors.append("manifest.branding: expected a mapping")
        branding = {}
    else:
        _check_keys(branding, {"header", "footer"}, "manifest.branding", errors)
    footer = _string(
        branding.get("footer", f"{title} · Oracle Database is the authorization boundary"),
        "manifest.branding.footer",
        errors,
    )

    script_root_value = raw.get("script_root", "database")
    if not isinstance(script_root_value, str) or not script_root_value.strip():
        errors.append("manifest.script_root: expected a non-empty relative directory")
        script_root = source_path.parent / "database"
    elif Path(script_root_value).is_absolute():
        errors.append("manifest.script_root: absolute paths are not allowed")
        script_root = source_path.parent / "database"
    else:
        script_root = (source_path.parent / script_root_value).resolve()
    if not script_root.is_dir():
        errors.append(f"manifest.script_root: directory does not exist: {script_root}")

    actions = _normalize_actions(raw.get("actions"), script_root, errors)
    steps = _normalize_steps(raw.get("steps"), errors)
    pages = _normalize_pages(raw.get("pages"), errors)
    overview = _normalize_overview(raw.get("overview"), pages, errors)
    tour = _normalize_tour(raw.get("tour"), errors)
    _validate_references(actions, steps, pages, errors)

    if errors:
        return None
    return LessonDefinition(
        id=lesson_id or "",
        title=title or "",
        footer=footer or "",
        source_path=source_path,
        script_root=script_root,
        actions=actions,
        steps=tuple(steps),
        pages=tuple(pages),
        branding=branding,
        overview=overview,
        tour=tuple(tour),
    )


def _normalize_overview(
    raw_overview: Any, pages: list[PageDefinition], errors: list[str]
) -> dict[str, Any]:
    """Validate the editable copy used by the lesson landing page."""

    location = "manifest.overview"
    if raw_overview is None:
        return {}
    if not isinstance(raw_overview, dict):
        errors.append(f"{location}: expected a mapping")
        return {}
    _check_keys(
        raw_overview,
        {
            "introduction",
            "scenario_heading",
            "scenario",
            "architecture_alt",
            "architecture_caption",
            "heading",
            "stage_heading",
            "description_heading",
            "time_heading",
            "total_label",
            "stages",
            "note",
            "start_path",
            "start_label",
        },
        location,
        errors,
    )
    for required in (
        "introduction",
        "architecture_alt",
        "architecture_caption",
        "heading",
        "stage_heading",
        "description_heading",
        "time_heading",
        "total_label",
        "stages",
        "note",
        "start_path",
        "start_label",
    ):
        _require(raw_overview, required, location, errors)

    result: dict[str, Any] = {}
    for key in (
        "introduction",
        "scenario_heading",
        "scenario",
        "architecture_alt",
        "architecture_caption",
        "heading",
        "stage_heading",
        "description_heading",
        "time_heading",
        "total_label",
        "note",
        "start_label",
    ):
        if key in {"scenario_heading", "scenario"}:
            result[key] = _optional_string(raw_overview.get(key), f"{location}.{key}", errors) or ""
        else:
            result[key] = _string(raw_overview.get(key), f"{location}.{key}", errors) or ""

    start_path = _string(raw_overview.get("start_path"), f"{location}.start_path", errors) or ""
    if start_path and not start_path.startswith("/"):
        errors.append(f"{location}.start_path: must start with '/'")
    if start_path and pages and start_path not in {page.path for page in pages}:
        errors.append(f"{location}.start_path: unknown page path {start_path!r}")
    result["start_path"] = start_path

    stages_raw = raw_overview.get("stages")
    stages: list[dict[str, Any]] = []
    if not isinstance(stages_raw, list):
        errors.append(f"{location}.stages: expected a list")
    else:
        for index, stage in enumerate(stages_raw):
            stage_location = f"{location}.stages[{index}]"
            if not isinstance(stage, dict):
                errors.append(f"{stage_location}: expected a mapping")
                continue
            _check_keys(stage, {"label", "description", "estimated_minutes"}, stage_location, errors)
            _require(stage, "label", stage_location, errors)
            _require(stage, "description", stage_location, errors)
            _require(stage, "estimated_minutes", stage_location, errors)
            stages.append(
                {
                    "label": _string(stage.get("label"), f"{stage_location}.label", errors) or "",
                    "description": _string(
                        stage.get("description"), f"{stage_location}.description", errors
                    )
                    or "",
                    "estimated_minutes": _positive_integer(
                        stage.get("estimated_minutes"),
                        f"{stage_location}.estimated_minutes",
                        errors,
                    ),
                }
            )
    result["stages"] = tuple(stages)
    return result


def _normalize_tour(raw_tour: Any, errors: list[str]) -> list[Mapping[str, str]]:
    """Validate the editable guided-tour steps sent to the browser."""

    location = "manifest.tour"
    if raw_tour is None:
        return []
    if not isinstance(raw_tour, list):
        errors.append(f"{location}: expected a list")
        return []
    tour: list[Mapping[str, str]] = []
    for index, raw_step in enumerate(raw_tour):
        step_location = f"{location}[{index}]"
        if not isinstance(raw_step, dict):
            errors.append(f"{step_location}: expected a mapping")
            continue
        _check_keys(raw_step, {"selector", "title", "text"}, step_location, errors)
        for required in ("selector", "title", "text"):
            _require(raw_step, required, step_location, errors)
        tour.append(
            {
                "selector": _string(
                    raw_step.get("selector"), f"{step_location}.selector", errors
                )
                or "",
                "title": _string(raw_step.get("title"), f"{step_location}.title", errors) or "",
                "text": _string(raw_step.get("text"), f"{step_location}.text", errors) or "",
            }
        )
    return tour


def _normalize_actions(
    raw_actions: Any, script_root: Path, errors: list[str]
) -> dict[str, ActionDefinition]:
    if not isinstance(raw_actions, dict):
        errors.append("manifest.actions: expected a mapping keyed by action ID")
        return {}

    actions: dict[str, ActionDefinition] = {}
    allowed = {
        "title",
        "description",
        "type",
        "scripts",
        "destructive",
        "needs_password",
        "password_scripts",
        "database_user",
        "requires",
        "resets_setup",
        "restored_actions",
        "internal_secret_script",
        "short_label",
        "button_label",
        "link_button_label",
        "link_target",
        "completion",
        "handler",
        "confirm_apply",
        "output_title",
        "config",
    }
    for action_id, raw in raw_actions.items():
        location = f"actions.{action_id}"
        action_key = _id(action_id, f"{location} (key)", errors)
        if action_key is None:
            continue
        if not isinstance(raw, dict):
            errors.append(f"{location}: expected a mapping")
            continue
        _check_keys(raw, allowed, location, errors)
        _require(raw, "title", location, errors)
        _require(raw, "description", location, errors)
        _require(raw, "type", location, errors)
        title = _string(raw.get("title"), f"{location}.title", errors) or ""
        description = _string(raw.get("description"), f"{location}.description", errors) or ""
        action_type = _string(raw.get("type"), f"{location}.type", errors)
        if action_type and action_type not in SUPPORTED_ACTION_TYPES:
            errors.append(
                f"{location}.type: unsupported action type {action_type!r}; "
                f"choose one of {', '.join(sorted(SUPPORTED_ACTION_TYPES))}"
            )
        scripts = _normalize_scripts(raw.get("scripts", []), script_root, location, errors)
        requires = _string_list(raw.get("requires", []), f"{location}.requires", errors)
        restored_actions = _string_list(
            raw.get("restored_actions", []), f"{location}.restored_actions", errors
        )
        password_scripts = _string_list(
            raw.get("password_scripts", []), f"{location}.password_scripts", errors
        )
        database_user = _string(raw.get("database_user", "ADMIN"), f"{location}.database_user", errors)
        handler = _optional_string(raw.get("handler"), f"{location}.handler", errors)
        config = raw.get("config", {})
        if not isinstance(config, dict):
            errors.append(f"{location}.config: expected a mapping")
            config = {}
        internal_secret_script = _optional_string(
            raw.get("internal_secret_script"), f"{location}.internal_secret_script", errors
        )
        control_script_names = (*password_scripts, *([internal_secret_script] if internal_secret_script else []))
        for script_name in control_script_names:
            if script_name and script_name not in {script.name for script in scripts}:
                errors.append(f"{location}: script control references unknown script {script_name!r}")
        if action_type == "sql" and not scripts:
            errors.append(f"{location}: sql actions must list at least one script")
        if action_type == "wizard" and not handler:
            errors.append(f"{location}.handler: wizard actions must name a registered handler")
        if action_type == "wizard" and handler == "data_grant":
            required_config = (
                ("grant_name", "string"),
                ("table", "string"),
                ("optional_columns", "list"),
            )
            if config.get("mode") == "all_except":
                required_config += (("when_select", "string"), ("predicate", "string"))
            else:
                required_config += (
                    ("role", "string"),
                    ("required_columns", "list"),
                    ("updatable_columns", "list"),
                )
            for config_key, config_type in required_config:
                value = config.get(config_key)
                valid = (
                    isinstance(value, str) and bool(value.strip())
                    if config_type == "string"
                    else isinstance(value, list) and bool(value)
                )
                if not valid:
                    errors.append(
                        f"{location}.config.{config_key}: data_grant requires a non-empty {config_type}"
                    )
        if action_type in {"wizard", "object_storage"} and handler and handler not in REGISTERED_HANDLER_NAMES:
            errors.append(
                f"{location}.handler: unknown handler {handler!r}; "
                f"registered handlers are {', '.join(sorted(REGISTERED_HANDLER_NAMES))}"
            )
        if action_type == "object_storage" and not handler:
            errors.append(f"{location}.handler: object_storage actions must name a registered handler")
        if action_type == "link" and raw.get("link_target") is not None:
            _string(raw.get("link_target"), f"{location}.link_target", errors)
        actions[action_key] = ActionDefinition(
            id=action_key,
            title=title,
            description=description,
            type=action_type or "",
            scripts=tuple(scripts),
            destructive=_bool(raw.get("destructive", False), f"{location}.destructive", errors),
            needs_password=_bool(raw.get("needs_password", False), f"{location}.needs_password", errors),
            password_scripts=tuple(password_scripts),
            database_user=database_user or "ADMIN",
            requires=tuple(requires),
            resets_setup=_bool(raw.get("resets_setup", False), f"{location}.resets_setup", errors),
            restored_actions=tuple(restored_actions),
            internal_secret_script=internal_secret_script,
            short_label=_optional_string(raw.get("short_label"), f"{location}.short_label", errors),
            button_label=_optional_string(raw.get("button_label"), f"{location}.button_label", errors),
            link_button_label=_optional_string(
                raw.get("link_button_label"), f"{location}.link_button_label", errors
            ),
            link_target=_optional_string(raw.get("link_target"), f"{location}.link_target", errors),
            completion=_optional_string(raw.get("completion"), f"{location}.completion", errors),
            handler=handler,
            confirm_apply=_bool(raw.get("confirm_apply", True), f"{location}.confirm_apply", errors),
            output_title=_optional_string(raw.get("output_title"), f"{location}.output_title", errors),
            config=config,
        )
    return actions


def _normalize_scripts(
    raw_scripts: Any, script_root: Path, location: str, errors: list[str]
) -> list[ScriptDefinition]:
    if not isinstance(raw_scripts, list):
        errors.append(f"{location}.scripts: expected a list")
        return []
    scripts: list[ScriptDefinition] = []
    names: set[str] = set()
    for index, raw_script in enumerate(raw_scripts):
        script_location = f"{location}.scripts[{index}]"
        if isinstance(raw_script, str):
            run_name = raw_script
            display_name = None
        elif isinstance(raw_script, dict):
            _check_keys(raw_script, {"run", "display"}, script_location, errors)
            run_name = raw_script.get("run")
            display_name = raw_script.get("display")
        else:
            errors.append(f"{script_location}: expected a filename or mapping")
            continue
        run_name = _relative_file_name(run_name, f"{script_location}.run", errors)
        if run_name is None:
            continue
        if display_name is not None:
            display_name = _relative_file_name(display_name, f"{script_location}.display", errors)
        run_path = (script_root / run_name).resolve()
        display_path = (
            (script_root / display_name).resolve()
            if display_name
            else run_path.with_suffix(".display.sql")
        )
        if not run_path.is_file():
            errors.append(f"{script_location}: executable script does not exist: {run_path}")
        if not display_path.is_file():
            display_path = run_path
        if run_name in names:
            errors.append(f"{location}: duplicate script {run_name!r}")
        names.add(run_name)
        scripts.append(ScriptDefinition(run_name, run_path, display_path))
    return scripts


def _normalize_steps(raw_steps: Any, errors: list[str]) -> list[StepDefinition]:
    if not isinstance(raw_steps, list):
        errors.append("manifest.steps: expected a list")
        return []
    steps: list[StepDefinition] = []
    seen: set[str] = set()
    allowed = {"id", "badge", "label", "title", "action_ids", "next_hint", "notes", "quiz"}
    for index, raw in enumerate(raw_steps):
        location = f"steps[{index}]"
        if not isinstance(raw, dict):
            errors.append(f"{location}: expected a mapping")
            continue
        _check_keys(raw, allowed, location, errors)
        for required in ("id", "badge", "label", "title", "action_ids"):
            _require(raw, required, location, errors)
        step_id = _id(raw.get("id"), f"{location}.id", errors)
        if step_id is None:
            continue
        if step_id in seen:
            errors.append(f"{location}.id: duplicate step ID {step_id!r}")
        seen.add(step_id)
        badge = _string(raw.get("badge"), f"{location}.badge", errors) or ""
        label = _string(raw.get("label"), f"{location}.label", errors) or ""
        title = _string(raw.get("title"), f"{location}.title", errors) or ""
        action_ids = _string_list(raw.get("action_ids"), f"{location}.action_ids", errors)
        notes = _string_list(raw.get("notes", []), f"{location}.notes", errors)
        quiz = _normalize_quiz(raw.get("quiz"), location, errors)
        steps.append(
            StepDefinition(
                id=step_id,
                badge=badge,
                label=label,
                title=title,
                action_ids=tuple(action_ids),
                next_hint=_optional_string(raw.get("next_hint"), f"{location}.next_hint", errors),
                notes=tuple(notes),
                quiz=quiz,
            )
        )
    return steps


def _normalize_quiz(raw: Any, location: str, errors: list[str]) -> Optional[QuizDefinition]:
    if raw is None:
        return None
    quiz_location = f"{location}.quiz"
    if not isinstance(raw, dict):
        errors.append(f"{quiz_location}: expected a mapping")
        return None
    _check_keys(raw, {"question", "options", "correct_answer", "explanation"}, quiz_location, errors)
    for required in ("question", "options", "correct_answer", "explanation"):
        _require(raw, required, quiz_location, errors)
    question = _string(raw.get("question"), f"{quiz_location}.question", errors) or ""
    correct_answer = _string(
        raw.get("correct_answer"), f"{quiz_location}.correct_answer", errors
    ) or ""
    explanation = _string(raw.get("explanation"), f"{quiz_location}.explanation", errors) or ""
    options_raw = raw.get("options")
    options: list[Mapping[str, str]] = []
    option_keys: set[str] = set()
    if not isinstance(options_raw, list):
        errors.append(f"{quiz_location}.options: expected a list")
    else:
        for index, option in enumerate(options_raw):
            option_location = f"{quiz_location}.options[{index}]"
            if not isinstance(option, dict):
                errors.append(f"{option_location}: expected a mapping")
                continue
            _check_keys(option, {"key", "label"}, option_location, errors)
            key = _id(option.get("key"), f"{option_location}.key", errors)
            label = _string(option.get("label"), f"{option_location}.label", errors)
            if key:
                if key in option_keys:
                    errors.append(f"{option_location}.key: duplicate quiz option {key!r}")
                option_keys.add(key)
                options.append({"key": key, "label": label or ""})
    if correct_answer and correct_answer not in option_keys:
        errors.append(f"{quiz_location}.correct_answer: no option has key {correct_answer!r}")
    return QuizDefinition(question, tuple(options), correct_answer, explanation)


def _normalize_pages(raw_pages: Any, errors: list[str]) -> list[PageDefinition]:
    if not isinstance(raw_pages, list):
        errors.append("manifest.pages: expected a list")
        return []
    pages: list[PageDefinition] = []
    seen_ids: set[str] = set()
    seen_paths: set[str] = set()
    allowed = {"id", "path", "label", "step_ids", "renderer", "ordered"}
    for index, raw in enumerate(raw_pages):
        location = f"pages[{index}]"
        if not isinstance(raw, dict):
            errors.append(f"{location}: expected a mapping")
            continue
        _check_keys(raw, allowed, location, errors)
        for required in ("id", "path", "label", "step_ids"):
            _require(raw, required, location, errors)
        page_id = _id(raw.get("id"), f"{location}.id", errors)
        path = _string(raw.get("path"), f"{location}.path", errors)
        label = _string(raw.get("label"), f"{location}.label", errors)
        step_ids = _string_list(raw.get("step_ids"), f"{location}.step_ids", errors)
        if page_id:
            if page_id in seen_ids:
                errors.append(f"{location}.id: duplicate page ID {page_id!r}")
            seen_ids.add(page_id)
        if path:
            if not path.startswith("/"):
                errors.append(f"{location}.path: must start with '/'")
            if path in seen_paths:
                errors.append(f"{location}.path: duplicate page path {path!r}")
            seen_paths.add(path)
        pages.append(
            PageDefinition(
                page_id or "",
                path or "",
                label or "",
                tuple(step_ids),
                _optional_string(raw.get("renderer"), f"{location}.renderer", errors),
                _bool(raw.get("ordered", True), f"{location}.ordered", errors),
            )
        )
    return pages


def _validate_references(
    actions: Mapping[str, ActionDefinition],
    steps: list[StepDefinition],
    pages: list[PageDefinition],
    errors: list[str],
) -> None:
    step_ids = {step.id for step in steps}
    for action in actions.values():
        for required in action.requires:
            if required not in actions:
                errors.append(f"actions.{action.id}.requires: unknown action {required!r}")
        for restored in action.restored_actions:
            if restored not in actions:
                errors.append(f"actions.{action.id}.restored_actions: unknown action {restored!r}")
    for step in steps:
        for action_id in step.action_ids:
            if action_id not in actions:
                errors.append(f"steps.{step.id}.action_ids: unknown action {action_id!r}")
    for page in pages:
        for step_id in page.step_ids:
            if step_id not in step_ids:
                errors.append(f"pages.{page.id}.step_ids: unknown step {step_id!r}")
    _validate_dependency_cycles(actions, errors)


def _validate_dependency_cycles(
    actions: Mapping[str, ActionDefinition], errors: list[str]
) -> None:
    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(action_id: str, trail: tuple[str, ...]) -> None:
        if action_id in visiting:
            cycle = " -> ".join((*trail, action_id))
            errors.append(f"action dependency cycle: {cycle}")
            return
        if action_id in visited:
            return
        visiting.add(action_id)
        for required in actions[action_id].requires:
            if required in actions:
                visit(required, (*trail, action_id))
        visiting.remove(action_id)
        visited.add(action_id)

    for action_id in actions:
        visit(action_id, ())


def _check_keys(raw: Mapping[str, Any], allowed: set[str], location: str, errors: list[str]) -> None:
    for key in raw:
        if key not in allowed:
            errors.append(f"{location}: unknown field {key!r}")


def _require(raw: Mapping[str, Any], key: str, location: str, errors: list[str]) -> None:
    if key not in raw:
        errors.append(f"{location}: missing required field {key!r}")


def _string(value: Any, location: str, errors: list[str]) -> Optional[str]:
    if not isinstance(value, str) or not value.strip():
        errors.append(f"{location}: expected a non-empty string")
        return None
    return value


def _optional_string(value: Any, location: str, errors: list[str]) -> Optional[str]:
    if value is None:
        return None
    return _string(value, location, errors)


def _id(value: Any, location: str, errors: list[str]) -> Optional[str]:
    result = _string(value, location, errors)
    if result and not _ID_PATTERN.fullmatch(result):
        errors.append(f"{location}: invalid ID {result!r}; use letters, numbers, '_' or '-'")
        return None
    return result


def _string_list(value: Any, location: str, errors: list[str]) -> list[str]:
    if not isinstance(value, list):
        errors.append(f"{location}: expected a list")
        return []
    result: list[str] = []
    for index, item in enumerate(value):
        item_value = _string(item, f"{location}[{index}]", errors)
        if item_value is not None:
            result.append(item_value)
    return result


def _bool(value: Any, location: str, errors: list[str]) -> bool:
    if not isinstance(value, bool):
        errors.append(f"{location}: expected true or false")
        return False
    return value


def _positive_integer(value: Any, location: str, errors: list[str]) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        errors.append(f"{location}: expected a non-negative integer")
        return 0
    return value


def _relative_file_name(value: Any, location: str, errors: list[str]) -> Optional[str]:
    result = _string(value, location, errors)
    if result is None:
        return None
    path = Path(result)
    if path.is_absolute() or ".." in path.parts:
        errors.append(f"{location}: path must be relative and cannot contain '..'")
        return None
    return result
