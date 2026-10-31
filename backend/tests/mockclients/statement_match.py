from typing import Any, ClassVar

from statement_match.adapter.llm_client import LlmProviderError
from statement_match.adapter.pdf_extractor import PdfExtractionError


class MockPdfExtractor:
    text = "Statement text"
    error: ClassVar[Exception | None] = None
    contents: ClassVar[list[bytes]] = []

    @classmethod
    def reset(cls):
        cls.text = "Statement text"
        cls.error = None
        cls.contents = []

    def extract_text(self, content: bytes) -> str:
        type(self).contents.append(content)
        error = type(self).error
        if error is not None:
            raise error
        return type(self).text


class MockStatementMatchLlmClient:
    model = "mock-model"
    payload: ClassVar[dict[str, Any]] = {"results": []}
    error: ClassVar[Exception | None] = None
    prompts: ClassVar[list[str]] = []

    @classmethod
    def reset(cls):
        cls.model = "mock-model"
        cls.payload = {"results": []}
        cls.error = None
        cls.prompts = []

    def match_statement(self, prompt: str):
        type(self).prompts.append(prompt)
        error = type(self).error
        if error is not None:
            raise error
        return type(self).payload
