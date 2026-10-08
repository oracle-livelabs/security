"""Archived reference only; this module is deliberately not imported.

The string below preserves the former ``admin_app.py`` Vibe constants,
helpers, and Flask views.  It depended on that module's ``app``, ``settings``,
``_completed_actions``, and login helpers when it was live.
"""

ADMIN_APP_VIBE_REFERENCE = r'''
VIBE_TIMEOUT_SECONDS = 360
VIBE_PROMPTS = {
    "customer_search": {
        "title": "Add customer search",
        "description": "Add a search box that asks for every customer, not just Marvin's sales team.",
        "prompt": "Add a customer search box to the application. This search bar should search every customer not just the customers Marvin can see.",
    },
    "all_customers": {
        "title": "Try an all-customer page",
        "description": "Add a page that tries to display every customer and every customer field.",
        "prompt": "Add an admin-style page that tries to display every customer and every customer field.",
    },
}


def _parse_vibe_output(output: str) -> dict:
    """Extract the stable, learner-facing fields emitted by the Vibe CLI."""
    def _match(label: str) -> str:
        match = re.search(rf"^{re.escape(label)}\s*:\s*(.+)$", output, re.MULTILINE)
        return match.group(1).strip() if match else ""

    summary_match = re.search(r"OCI GenAI summary:\s*\n\n(.*?)\n\nGenAI calls:", output, re.DOTALL)
    files_match = re.search(r"Applied:\s*\n(.*?)(?:\n\nUse 'vibe|\Z)", output, re.DOTALL)
    files = [line.strip() for line in files_match.group(1).splitlines() if line.strip()] if files_match else []
    return {
        "target_project": _match("Project"),
        "model": _match("Model"),
        "region": _match("Region"),
        "genai_summary": summary_match.group(1).strip() if summary_match else "",
        "files_changed": files,
    }


def _run_vibe(prompt: str) -> dict:
    """Run Vibe only against the live, Terraform-installed customer application."""
    if not settings.vibe_executable.is_file() or not os.access(settings.vibe_executable, os.X_OK):
        raise RuntimeError("Vibe is not installed yet. Check the Deep Sec bootstrap log.")
    if not settings.vibe_project_root.is_dir():
        raise RuntimeError("The Deep Sec Customer Sales application directory is unavailable.")

    result = subprocess.run(
        [str(settings.vibe_executable), "--project", str(settings.vibe_project_root), "run", "-y", prompt],
        cwd=settings.vibe_project_root,
        text=True,
        capture_output=True,
        timeout=VIBE_TIMEOUT_SECONDS,
        env={**os.environ, "HOME": "/home/opc"},
        check=False,
    )
    output = (result.stdout + result.stderr).strip() or "Vibe completed without additional output."
    return {
        "exit_code": result.returncode,
        "output": output,
        "applied": result.returncode == 0 and "Applied:" in output,
        **_parse_vibe_output(output),
    }


def _run_vibe_reset() -> dict:
    """Reset the live Customer Sales application to its original copy."""
    if not settings.vibe_executable.is_file() or not os.access(settings.vibe_executable, os.X_OK):
        raise RuntimeError("Vibe is not installed yet. Check the Deep Sec bootstrap log.")
    if not settings.vibe_project_root.is_dir():
        raise RuntimeError("The Deep Sec Customer Sales application directory is unavailable.")

    result = subprocess.run(
        [str(settings.vibe_executable), "--project", str(settings.vibe_project_root), "reset", "-y"],
        cwd=settings.vibe_project_root,
        text=True,
        capture_output=True,
        timeout=VIBE_TIMEOUT_SECONDS,
        env={**os.environ, "HOME": "/home/opc"},
        check=False,
    )
    output = (result.stdout + result.stderr).strip() or "Vibe reset completed without additional output."
    return {"exit_code": result.returncode, "output": output, **_parse_vibe_output(output)}


def _reload_customer_sales() -> dict:
    """Reload the live application after Vibe modifies its checked-in source."""
    result = subprocess.run(
        ["/usr/bin/sudo", "-n", "/usr/bin/systemctl", "reload", "deep-sec-customer-sales.service"],
        text=True,
        capture_output=True,
        timeout=30,
        check=False,
    )
    output = (result.stdout + result.stderr).strip() or "Customer Sales application reloaded."
    return {"exit_code": result.returncode, "output": output}


@app.get("/vibe")
@login_required
def vibe():
    completed_actions = _completed_actions() | _database_completed_actions()
    return render_template(
        "vibe.html",
        prompts=VIBE_PROMPTS,
        ready="create_end_users" in completed_actions,
        pages=PAGES,
        current_page_key="vibe",
    )


@app.post("/api/vibe/reset")
@login_required
def reset_vibe():
    if "create_end_users" not in (_completed_actions() | _database_completed_actions()):
        return jsonify(error="Complete Create MARVIN before using Vibe Coding."), 409
    if not _vibe_lock.acquire(blocking=False):
        return jsonify(error="Another Vibe request is already running. Wait for it to finish."), 409
    try:
        result = _run_vibe_reset()
        if result["exit_code"] != 0:
            return jsonify(**result), 502
        try:
            reload_result = _reload_customer_sales()
        except subprocess.TimeoutExpired:
            reload_result = {"exit_code": 1, "output": "The reset was applied, but the Customer Sales reload timed out."}
        if reload_result["exit_code"] != 0:
            return jsonify(reload=reload_result, **result), 502
        return jsonify(reload=reload_result, **result)
    except subprocess.TimeoutExpired:
        return jsonify(error="Reset did not complete within six minutes."), 504
    except Exception as exc:
        app.logger.exception("Vibe reset could not start: %s", exc)
        return jsonify(error=str(exc)), 502
    finally:
        _vibe_lock.release()


@app.post("/api/vibe/<prompt_key>")
@login_required
def run_vibe(prompt_key: str):
    if "create_end_users" not in (_completed_actions() | _database_completed_actions()):
        return jsonify(error="Complete Create MARVIN before using Vibe Coding."), 409

    if prompt_key == "custom":
        prompt = str((request.get_json(silent=True) or {}).get("prompt", "")).strip()
        if not prompt:
            return jsonify(error="Enter a custom Vibe request."), 400
        if len(prompt) > 4000 or "\x00" in prompt:
            return jsonify(error="The custom Vibe request must be plain text of 4,000 characters or fewer."), 400
    else:
        selected_prompt = VIBE_PROMPTS.get(prompt_key)
        if not selected_prompt:
            return jsonify(error="Unknown Vibe request."), 404
        prompt = selected_prompt["prompt"]

    if not _vibe_lock.acquire(blocking=False):
        return jsonify(error="Another Vibe request is already running. Wait for it to finish."), 409
    try:
        result = _run_vibe(prompt)
        if result["exit_code"] != 0:
            return jsonify(prompt=prompt, **result), 502
        reload_result = None
        if result["applied"]:
            try:
                reload_result = _reload_customer_sales()
            except subprocess.TimeoutExpired:
                reload_result = {"exit_code": 1, "output": "The change was applied, but the Customer Sales reload timed out."}
            if reload_result["exit_code"] != 0:
                return jsonify(prompt=prompt, reload=reload_result, **result), 502
        return jsonify(prompt=prompt, reload=reload_result, **result)
    except subprocess.TimeoutExpired:
        return jsonify(error="Vibe did not complete within six minutes."), 504
    except Exception as exc:
        app.logger.exception("Vibe Coding could not start: %s", exc)
        return jsonify(error=str(exc)), 502
    finally:
        _vibe_lock.release()
'''
