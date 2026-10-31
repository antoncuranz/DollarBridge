def require_persisted_id(value: int | None, entity: str) -> int:
    if value is None:
        raise ValueError(f"{entity} has no persisted ID")
    return value
