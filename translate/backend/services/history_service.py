from __future__ import annotations

import sqlite3
import threading
from pathlib import Path


SCHEMA = """
CREATE TABLE IF NOT EXISTS translation_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id TEXT NOT NULL,
    source_text TEXT NOT NULL,
    translated_text TEXT NOT NULL,
    source_lang TEXT NOT NULL,
    detected_source_lang TEXT,
    target_lang TEXT NOT NULL,
    model TEXT NOT NULL,
    latency_ms INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
"""


class HistoryService:
    def __init__(self, path: str) -> None:
        self.path = path
        self._lock = threading.Lock()
        Path(path).parent.mkdir(parents=True, exist_ok=True)
        self._init_db()

    def _connect(self) -> sqlite3.Connection:
        return sqlite3.connect(self.path)

    def _init_db(self) -> None:
        with self._connect() as connection:
            connection.executescript(SCHEMA)
            connection.commit()

    def save_translation(
        self,
        *,
        job_id: str,
        source_text: str,
        translated_text: str,
        source_lang: str,
        detected_source_lang: str,
        target_lang: str,
        model: str,
        latency_ms: int,
    ) -> None:
        with self._lock, self._connect() as connection:
            connection.execute(
                """
                INSERT INTO translation_history (
                    job_id,
                    source_text,
                    translated_text,
                    source_lang,
                    detected_source_lang,
                    target_lang,
                    model,
                    latency_ms
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    job_id,
                    source_text,
                    translated_text,
                    source_lang,
                    detected_source_lang,
                    target_lang,
                    model,
                    latency_ms,
                ),
            )
            connection.commit()
