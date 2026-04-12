from __future__ import annotations

import json
import os
import threading


DEFAULT_SETTINGS = {
    "active_model": "gemma4:e2b",
    "model_status": "ready",
    "allow_user_override": True,
    "max_text_length": 5000,
    "history_enabled": True,
    "translation_temperature": 0.15,
    "translation_top_p": 0.9,
    "request_timeout_seconds": 60,
}


class SettingsService:
    def __init__(self, path: str) -> None:
        self.path = path
        self._lock = threading.Lock()
        self._settings = self._load()

    def _load(self) -> dict:
        if not os.path.exists(self.path):
            self._write(DEFAULT_SETTINGS)
            return dict(DEFAULT_SETTINGS)

        try:
            with open(self.path, "r", encoding="utf-8") as handle:
                loaded = json.load(handle)
        except Exception:
            loaded = {}

        merged = dict(DEFAULT_SETTINGS)
        merged.update(loaded if isinstance(loaded, dict) else {})
        self._write(merged)
        return merged

    def _write(self, data: dict) -> None:
        os.makedirs(os.path.dirname(self.path), exist_ok=True)
        with open(self.path, "w", encoding="utf-8") as handle:
            json.dump(data, handle, indent=2, sort_keys=True)

    def get(self, key: str, default=None):
        with self._lock:
            return self._settings.get(key, default)

    def set(self, key: str, value) -> None:
        with self._lock:
            self._settings[key] = value
            self._write(self._settings)

    def snapshot(self) -> dict:
        with self._lock:
            return dict(self._settings)
