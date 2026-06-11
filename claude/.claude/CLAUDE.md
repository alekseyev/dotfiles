## Technical Standards

- Use Python when possible
- Use the latest Python syntax (e.g. 3.12+)
- Implement proper error handling
- Use async/await for asynchronous operations
- Prefer basic / vanilla JavaScript over frameworks.
- Never put `#!/usr/bin/env python3` at the top of python scripts. We run our scripts with python out of virtual environments as `./venv/bin/python` or with `uv run`. For standalone scripts intended to be used separately, use `#!/usr/bin/env -S uv run --script` (and include inline dependencies)
- Prefer uuidv7 for generating ids
- Often the web server you are building for is already running. It also may have auto reload when changes are detected. Please assume it's already going before starting a new instance. 

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
