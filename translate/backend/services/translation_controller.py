from __future__ import annotations

import time
import uuid

from models.request_models import AudioLiveStartRequest, AudioLiveStopRequest, SelectModelRequest, TranslateTextRequest
from models.response_models import ErrorResponse
from services.language_detection import LanguageDetectionService
from services.prompt_builder import PromptBuilder
from services.result_postprocessor import ResultPostProcessor
from utils.validators import normalize_language_code, validate_audio_live_start_request, validate_translate_request


class TranslationController:
    def __init__(self, *, settings, gateway, history, audio_discovery, audio_session) -> None:
        self.settings = settings
        self.gateway = gateway
        self.history = history
        self.audio_discovery = audio_discovery
        self.audio_session = audio_session
        self.language_detection = LanguageDetectionService()
        self.prompt_builder = PromptBuilder()
        self.result_postprocessor = ResultPostProcessor()

    def _error(self, code: str, message: str) -> dict:
        return ErrorResponse(status="error", error_code=code, message=message).to_dict()

    def list_models_payload(self) -> dict:
        return {"models": self.gateway.list_models()}

    def current_model_payload(self) -> dict:
        return {
            "model": self.gateway.current_model(),
            "status": self.settings.get("model_status", "ready"),
        }

    def health_payload(self) -> dict:
        return {
            "backend": "ok",
            "ollama": "ok" if self.gateway.health_check() else "offline",
            "active_model": self.gateway.current_model(),
            "audio_capture": "ok" if self.audio_session.pw_record_bin else "missing",
            "audio_discovery": "ok" if self.audio_discovery.pactl_bin else "missing",
            "asr": "unavailable",
        }

    def list_audio_sources_payload(self) -> dict:
        return self.audio_session.list_sources_payload()

    def current_audio_session_payload(self) -> dict:
        return self.audio_session.session_payload()

    def start_audio_session(self, payload: dict) -> dict:
        request = AudioLiveStartRequest(
            source_id=str(payload.get("source_id", "")).strip(),
            source_lang=normalize_language_code(str(payload.get("source_lang", ""))),
            target_lang=normalize_language_code(str(payload.get("target_lang", ""))),
        )

        validation_error = validate_audio_live_start_request(request)
        if validation_error:
            return validation_error.to_dict()

        return self.audio_session.start_session(request)

    def stop_audio_session(self, payload: dict) -> dict:
        request = AudioLiveStopRequest(session_id=str(payload.get("session_id", "")).strip())
        return self.audio_session.stop_session(request)

    def select_model(self, payload: dict) -> dict:
        request = SelectModelRequest(model=str(payload.get("model", "")).strip())
        if not request.model:
            return self._error("INVALID_MODEL", "A model name is required.")
        return self.gateway.set_model(request.model)

    def translate_text(self, payload: dict) -> dict:
        request = TranslateTextRequest(
            text=str(payload.get("text", "")),
            source_lang=normalize_language_code(str(payload.get("source_lang", ""))),
            target_lang=normalize_language_code(str(payload.get("target_lang", ""))),
        )

        validation_error = validate_translate_request(request, max_text_length=self.settings.get("max_text_length", 5000))
        if validation_error:
            return validation_error.to_dict()

        model_name = self.gateway.current_model()
        if not model_name:
            return self._error("MODEL_UNAVAILABLE", "The selected Ollama model is not available.")

        models = self.gateway.list_models()
        if model_name not in models:
            return self._error("MODEL_UNAVAILABLE", "The selected Ollama model is not available.")

        if not self.gateway.health_check():
            return self._error("OLLAMA_OFFLINE", "Ollama is not running.")

        job_id = str(uuid.uuid4())
        detected_source_lang = None

        if request.source_lang == "auto":
            detected_source_lang = self.language_detection.detect(request.text).get("language", "en")

        prompt = self.prompt_builder.build(
            text=request.text,
            source_lang=request.source_lang,
            target_lang=request.target_lang,
            detected_source_lang=detected_source_lang,
        )

        started = time.perf_counter()
        try:
            raw_result = self.gateway.translate(model_name=model_name, prompt=prompt)
        except TimeoutError:
            return self._error("TIMEOUT", "Translation took too long. Try again or switch models.")
        except Exception:
            return self._error("INVALID_BACKEND_RESPONSE", "Translation failed due to an invalid response.")

        translated_text = self.result_postprocessor.clean(str(raw_result.get("response", "")))
        if not translated_text:
            return self._error("INVALID_BACKEND_RESPONSE", "Translation failed due to an invalid response.")

        latency_ms = int((time.perf_counter() - started) * 1000)
        resolved_source_lang = detected_source_lang or request.source_lang

        if self.settings.get("history_enabled", True):
            self.history.save_translation(
                job_id=job_id,
                source_text=request.text,
                translated_text=translated_text,
                source_lang=request.source_lang,
                detected_source_lang=detected_source_lang or resolved_source_lang,
                target_lang=request.target_lang,
                model=model_name,
                latency_ms=latency_ms,
            )

        self.settings.set("model_status", "ready")

        return {
            "job_id": job_id,
            "status": "done",
            "source_lang": request.source_lang,
            "detected_source_lang": resolved_source_lang,
            "target_lang": request.target_lang,
            "model": model_name,
            "translated_text": translated_text,
            "latency_ms": latency_ms,
        }
