from typing import Protocol


class ModelWithOptionalId(Protocol):
    id: int | None


def require_persisted_id(model: ModelWithOptionalId) -> int:
    if model.id is None:
        raise ValueError(f"{type(model).__name__} has no persisted ID")
    return model.id
