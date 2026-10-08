# Vibe App Editor (archived)

The original Vibe Coding page, which used the `vibe_agent` CLI to patch the
live Customer Sales application's files directly, backup/restore included.
Archived on 2026-08-21 in favor of VibeQL, a one-shot script generator that
doesn't touch app files at all.

The `vibe_agent` CLI itself is unchanged and still installed normally; this
only archives the admin console's page and routes that called it.

To restore: copy `vibe.html` back to `admin-app/templates/`, copy the
functions in `admin_app_vibe.py` back into `admin_app.py`, and re-add the
`vibe` entry to `PAGES`.
