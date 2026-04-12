from __future__ import annotations

from dataclasses import dataclass


@dataclass(slots=True)
class ErrorResponse:
    status: str
    error_code: str
    message: str

    def to_dict(self) -> dict:
        return {
            "status": self.status,
            "error_code": self.error_code,
            "message": self.message,
        }
