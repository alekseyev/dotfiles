## Technical Standards

- Use Python when possible
- Use the latest Python syntax (e.g. 3.12+)
- Implement proper error handling
- Use async/await for asynchronous operations
- Prefer basic / vanilla JavaScript over frameworks.
- Never put `#!/usr/bin/env python3` at the top of python scripts. We run our scripts with python out of virtual environments as `./venv/bin/python` or with `uv run`. For standalone scripts intended to be used separately, use `#!/usr/bin/env -S uv run --script` (and include inline dependencies)
- Often the web server you are building for is already running. It also may have auto reload when changes are detected. Please assume it's already going before starting a new instance. 
- Prefer UUIDv7 (`uuid.uuid7()`, Python 3.14+) over UUIDv4 when generating new ids. Fall back to `uuid4()` only on older Pythons where `uuid7` isn't available.

## Code Style

- Follow PEP8 and Ruff's formatting guidelines.
- Use guarding clauses with if + early returns rather than nested code.
- When specifying type information, please use builtin types if possible. An example is use `list[int]` over `typing.List[int]`.

## Project Structure
- Always check for a virtual environment in the workspace and activate it when running python. It may be called venv or .venv. Some of my projects use poetry.
- Keep components, functions, etc small and focused.
- Use proper file naming conventions.
- Follow the established folder structure.
- Prefer functions in modules rather than object-oriented programming though classes are fine when they make sense.
- Prefer a stand-alone pytest.ini configuration rather than embedding these details within a pyproject.toml, even if the pyproject.toml file exists.
- Keep raw storage clients out of view code. View / handler / route code (HTTP endpoints, page handlers, CLI commands) and background-job handlers must not call DB sessions, ORM/search-index clients, Redis/queue clients, or object-storage SDKs directly to build ad-hoc queries, commands, or key layouts. Wrap every query / command / key in a data-access module — whatever the project calls it (`data_access/`, `data_layer/`, `dal/`, `db/`, `storage/`) — and have the view/worker call that. If the right method doesn't exist yet, add it there; don't inline the query at the call site. The common allowed escape hatch is enqueueing background jobs, which usually already goes through a thin helper.

## Tools

- Prefer uv for dependency management (via uv add command), unless project is using poetry
- Please use the rules in ruff.toml for formatting if found.
- Use ruff format and ruff check for formatting and linting.
- pytest is our preferred testing framework.

## Changes

- When *major* changes or features are made/added I want a concise summary of the change and files involved (summarize if too many files are changed)

## Config

- When running web apps for development (e.g. FastAPI/Django/etc), always choose a port 10000 or higher.

### Python 3.14 syntax notes

- [PEP 758](https://peps.python.org/pep-0758/): `except` and `except*` accept a comma-separated list of exception types *without* parentheses, e.g. `except socket.herror, socket.gaierror:`. This looks like a Python 2 holdover but is valid here — do not "fix" it by wrapping in parens or flagging it as a bug.
