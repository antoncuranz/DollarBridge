FROM python:3.12-slim
COPY --from=ghcr.io/astral-sh/uv:0.9.10 /uv /uvx /bin/
WORKDIR /app
ENV UV_NO_DEV=1
ENV PATH="/app/.venv/bin:$PATH"
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project
COPY . ./
CMD ["fastapi", "run", "main.py", "--port", "80", "--proxy-headers"]
