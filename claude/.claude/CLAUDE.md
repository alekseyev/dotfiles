## Technical Standards

- Use Python when possible
- Use the latest Python syntax (e.g. 3.12+)
- Use async/await for asynchronous operations
- Prefer basic / vanilla JavaScript over frameworks
- No `#!/usr/bin/env python3` shebang — scripts run as `./venv/bin/python` or via `uv run`. Standalone scripts meant to be run on their own get `#!/usr/bin/env -S uv run --script` with inline dependencies.
- Assume the project's web server and other workers are already running, usually with auto-reload. Check before starting a new instance.
- If you do need to start a dev web server, use port 10000 or higher.

## Code Style

- Follow PEP8 and Ruff's formatting guidelines.
- Use guarding clauses with if + early returns rather than nested code.
- Use builtin types in annotations: `list[int]`, not `typing.List[int]`.
- Comments explain what isn't obvious to someone reading the file fresh. Keep them short, and skip them entirely when the code already says it.
- Never comment about the change itself — no "changed X to Y", no "now uses the new helper", no references to earlier versions or to what we discussed. That context is invisible to the reader and often describes code that was never committed.

### When using Python 3.14

- [PEP 758](https://peps.python.org/pep-0758/): `except` and `except*` accept comma-separated exception types without parens, e.g. `except socket.herror, socket.gaierror:`. Valid despite looking like a Python 2 holdover — don't wrap it in parens or flag it as a bug. Parens are still required when binding with `as`: `except (socket.herror, socket.gaierror) as e:`.
- Prefer UUIDv7 (`uuid.uuid7()`) over `uuid4()` for new ids.

## Project Structure

- Activate the workspace virtualenv (`venv` or `.venv`) before running python; some projects use poetry instead.
- Prefer functions in modules over OOP; classes when they genuinely fit.
- Put pytest config in a standalone pytest.ini, even when pyproject.toml exists.
- Keep raw storage clients out of view code. Routes, page handlers, CLI commands, and background-job handlers must not touch DB sessions, ORM/search-index clients, Redis/queue clients, or object-storage SDKs directly. Every query, command, and key layout belongs in the project's data-access module (`data_access/`, `data_layer/`, `dal/`, `db/`, `storage/` — whatever it's called); if the method doesn't exist yet, add it there rather than inlining at the call site. Enqueueing background jobs is the usual exception.

## Tools

- Use uv (`uv add`) for dependency management, unless the project uses poetry.
- Format and lint with `ruff format` and `ruff check`, honoring ruff.toml if present.
- Test with pytest.

## Changes

- After major changes or new features, give a concise summary of the change and the files involved (group them if there are many).
