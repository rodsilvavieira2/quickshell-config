from __future__ import annotations

import json
import shutil
import subprocess
import urllib.error
import urllib.request


class OllamaGateway:
    def __init__(self, settings) -> None:
        self.settings = settings
        self.base_url = "http://127.0.0.1:11434"

    def _request_json(self, path: str, payload: dict | None = None, timeout: int | None = None) -> dict:
        body = None if payload is None else json.dumps(payload).encode("utf-8")
        request = urllib.request.Request(
            self.base_url + path,
            data=body,
            headers={"Content-Type": "application/json"},
            method="GET" if body is None else "POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=timeout or self.settings.get("request_timeout_seconds", 60)) as response:
                return json.loads(response.read().decode("utf-8"))
        except TimeoutError:
            raise
        except urllib.error.URLError as error:
            if isinstance(getattr(error, "reason", None), TimeoutError):
                raise TimeoutError() from error
            raise

    def health_check(self) -> bool:
        try:
            self._request_json("/api/tags", timeout=5)
            return True
        except Exception:
            return False

    def list_models(self) -> list[str]:
        try:
            payload = self._request_json("/api/tags", timeout=8)
            models = payload.get("models", []) if isinstance(payload, dict) else []
            names = [model.get("name", "") for model in models if isinstance(model, dict)]
            names = [name for name in names if name]
            if names:
                return names
        except Exception:
            pass

        ollama_bin = shutil.which("ollama")
        if not ollama_bin:
            return []

        try:
            proc = subprocess.run(
                [ollama_bin, "list"],
                capture_output=True,
                text=True,
                timeout=10,
                check=False,
            )
        except Exception:
            return []

        if proc.returncode != 0:
            return []

        lines = proc.stdout.strip().splitlines()
        models = []
        for line in lines[1:]:
            columns = line.split()
            if columns:
                models.append(columns[0])
        return models

    def current_model(self) -> str:
        return str(self.settings.get("active_model", "") or "")

    def set_model(self, model_name: str) -> dict:
        if model_name not in self.list_models():
            return {
                "status": "error",
                "error_code": "MODEL_UNAVAILABLE",
                "message": "The selected Ollama model is not available.",
            }

        self.settings.set("active_model", model_name)
        self.settings.set("model_status", "warming")

        try:
            self.translate(
                model_name=model_name,
                prompt="Reply with the single word ready.",
                num_predict=1,
            )
            self.settings.set("model_status", "ready")
        except Exception:
            self.settings.set("model_status", "warming")

        return {
            "status": self.settings.get("model_status", "warming"),
            "model": model_name,
        }

    def translate(self, *, model_name: str, prompt: str, num_predict: int | None = None) -> dict:
        payload = {
            "model": model_name,
            "prompt": prompt,
            "stream": False,
            "keep_alive": "10m",
            "options": {
                "temperature": self.settings.get("translation_temperature", 0.15),
                "top_p": self.settings.get("translation_top_p", 0.9),
            },
        }
        if num_predict is not None:
            payload["options"]["num_predict"] = num_predict

        return self._request_json("/api/generate", payload=payload)
