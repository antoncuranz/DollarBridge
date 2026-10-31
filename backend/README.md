# Backend development

Python 3.12 and [uv](https://docs.astral.sh/uv/) are required. From this directory:

```sh
uv sync --locked
uv run --locked ruff check .
uv run --locked mypy statement_match
uv run --locked pytest -q
```

The tests start a PostgreSQL container, so Docker must be running. Runtime and development dependencies are declared in `pyproject.toml` and resolved in `uv.lock`. After changing dependencies, run `uv lock` and commit both files. The Docker image installs the locked runtime dependencies without the development group.

Mypy currently checks `statement_match`. The rest of the backend has existing type errors, particularly around SQLModel fields; expand the checked modules as those are corrected. Ruff checks application code and excludes migrations, generated OpenAPI models, and tests for now.
