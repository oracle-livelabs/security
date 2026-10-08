"""Adapt validated lesson content to the Admin Console view model.

The loader owns the typed, validated content boundary. This adapter keeps the
existing templates and SQL runner simple while the application remains
lesson-agnostic.
"""

from __future__ import annotations

from typing import Any

from content_loader import ActionDefinition, LessonDefinition


def build_runtime_content(lesson: LessonDefinition) -> tuple[dict[str, dict], tuple[dict, ...], tuple[dict, ...]]:
    actions = {
        action_id: _runtime_action(action)
        for action_id, action in lesson.actions.items()
    }
    for action in actions.values():
        action["required_titles"] = [
            actions[key]["title"] for key in action["requires"]
        ]

    steps = tuple(_runtime_step(step) for step in lesson.steps)
    pages = tuple(
        {
            "key": page.id,
            "path": page.path,
            "nav_label": page.label,
            "step_keys": page.step_ids,
            "renderer": page.renderer,
            "ordered": page.ordered,
        }
        for page in lesson.pages
    )
    return actions, steps, pages


def _runtime_action(action: ActionDefinition) -> dict[str, Any]:
    scripts = []
    for script in action.scripts:
        scripts.append(
            {
                "name": script.name,
                "path": script.run_path,
                "sql": script.display_path.read_text(encoding="utf-8"),
            }
        )
    is_link_like = action.type in {"link", "mark_viewed", "explanation"}
    return {
        "key": action.id,
        "title": action.title,
        "description": action.description,
        "scripts": scripts,
        "destructive": action.destructive,
        "needs_password": action.needs_password,
        "password_scripts": action.password_scripts,
        "database_user": action.database_user,
        "requires": action.requires,
        "resets_setup": action.resets_setup,
        "restored_actions": action.restored_actions,
        "link_step": is_link_like,
        "explain_step": action.type == "explanation",
        "custom_grant_step": action.type == "wizard",
        "grant_wizard": dict(action.config) if action.type == "wizard" else None,
        "internal_secret_script": action.internal_secret_script,
        "link_url": None,
        "link_button_label": action.link_button_label,
        "button_label": action.button_label,
        "short_label": action.short_label or action.title,
        "link_target": action.link_target,
        "completion": action.completion,
        "handler": action.handler,
        "confirm_apply": action.confirm_apply,
        "output_title": action.output_title,
        "type": action.type,
        "config": dict(action.config),
    }


def _runtime_step(step) -> dict[str, Any]:
    quiz = None
    if step.quiz:
        quiz = {
            "question": step.quiz.question,
            "options": tuple(dict(option) for option in step.quiz.options),
            "correct_answer": step.quiz.correct_answer,
            "explanation": step.quiz.explanation,
        }
    return {
        "key": step.id,
        "badge": step.badge,
        "label": step.label,
        "title": step.title,
        "action_keys": step.action_ids,
        "next_hint": step.next_hint,
        "notes": step.notes,
        "quiz": quiz,
    }
