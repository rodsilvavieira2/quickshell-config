from __future__ import annotations

import datetime as dt
import os
import shutil
import subprocess
import threading
import time
import uuid


def utc_timestamp() -> str:
    return dt.datetime.now(dt.UTC).isoformat(timespec="seconds")


class AudioSessionController:
    ACTIVE_STATUSES = {"starting", "listening", "speech_detected", "transcribing", "translating"}

    def __init__(self, *, settings, discovery) -> None:
        self.settings = settings
        self.discovery = discovery
        self.pw_record_bin = shutil.which("pw-record")
        self._lock = threading.Lock()
        self._session = None
        self._process = None

    def _default_state(self) -> dict:
        return {
            "session_id": None,
            "status": "idle",
            "selected_source_id": str(self.settings.get("audio_selected_source_id", "") or ""),
            "selected_source_type": str(self.settings.get("audio_selected_source_type", "") or ""),
            "source_id": None,
            "source_name": str(self.settings.get("audio_selected_source_name", "") or ""),
            "source_type": None,
            "source_lang": str(self.settings.get("audio_source_lang", "auto") or "auto"),
            "target_lang": str(self.settings.get("audio_target_lang", "pt-br") or "pt-br"),
            "started_at": None,
            "updated_at": utc_timestamp(),
            "capture_path": "",
            "current_partial_transcript": "",
            "current_partial_translation": "",
            "asr_status": "unavailable",
            "last_error": None,
            "message": "Choose an audio source and start live translation.",
        }

    def _session_snapshot(self) -> dict:
        if not self._session:
            return self._default_state()
        return dict(self._session)

    def _read_process_error(self, process: subprocess.Popen | None) -> str:
        if not process or not process.stderr:
            return ""

        try:
            return process.stderr.read().strip()
        except Exception:
            return ""

    def _sync_process_state(self) -> None:
        if not self._process:
            return

        exit_code = self._process.poll()
        if exit_code is None:
            return

        error_text = self._read_process_error(self._process)
        if self._session and self._session.get("status") in self.ACTIVE_STATUSES:
            self._session["status"] = "stopped" if exit_code == 0 else "error"
            self._session["updated_at"] = utc_timestamp()
            self._session["last_error"] = None if exit_code == 0 else (error_text or "Live session disconnected unexpectedly.")
            self._session["message"] = (
                "Live capture stopped. Install a local ASR engine to stream transcript segments."
                if exit_code == 0
                else (error_text or "Live session disconnected unexpectedly.")
            )

        self._process = None

    def _active_sources(self) -> dict[str, dict]:
        return {source["id"]: source for source in self.discovery.list_audio_sources()}

    def _remember_selected_source(self, source: dict, *, source_lang: str | None = None, target_lang: str | None = None) -> None:
        self.settings.set("audio_selected_source_id", source["id"])
        self.settings.set("audio_selected_source_name", source["name"])
        self.settings.set("audio_selected_source_type", source["type"])
        if source_lang is not None:
            self.settings.set("audio_source_lang", source_lang)
        if target_lang is not None:
            self.settings.set("audio_target_lang", target_lang)

    def list_sources_payload(self) -> dict:
        return {"sources": self.discovery.list_audio_sources()}

    def session_payload(self) -> dict:
        with self._lock:
            self._sync_process_state()
            return self._session_snapshot()

    def start_session(self, request) -> dict:
        with self._lock:
            self._sync_process_state()

            if self._session and self._session.get("status") in self.ACTIVE_STATUSES:
                return {
                    "status": "error",
                    "error_code": "SESSION_ACTIVE",
                    "message": "A live audio session is already running.",
                }

            if not self.pw_record_bin:
                return {
                    "status": "error",
                    "error_code": "CAPTURE_UNAVAILABLE",
                    "message": "Audio capture is unavailable on this system.",
                }

            source_map = self._active_sources()
            source = source_map.get(request.source_id)
            if not source or not source.get("is_available", False):
                return {
                    "status": "error",
                    "error_code": "SOURCE_UNAVAILABLE",
                    "message": "Selected audio source is unavailable.",
                }

            runtime_dir = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
            session_id = str(uuid.uuid4())
            capture_path = os.path.join(runtime_dir, f"translate-live-{session_id}.wav")
            command = [self.pw_record_bin, "--target", request.source_id, capture_path]

            try:
                process = subprocess.Popen(
                    command,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.PIPE,
                    text=True,
                )
            except Exception:
                return {
                    "status": "error",
                    "error_code": "SESSION_START_FAILED",
                    "message": "Unable to start live audio translation.",
                }

            session = {
                "session_id": session_id,
                "status": "starting",
                "selected_source_id": request.source_id,
                "selected_source_type": source["type"],
                "source_id": request.source_id,
                "source_name": source["name"],
                "source_type": source["type"],
                "source_lang": request.source_lang,
                "target_lang": request.target_lang,
                "started_at": utc_timestamp(),
                "updated_at": utc_timestamp(),
                "capture_path": capture_path,
                "current_partial_transcript": "",
                "current_partial_translation": "",
                "asr_status": "unavailable",
                "last_error": None,
                "message": f"Listening on {source['name']}. Install a local ASR engine to stream transcript segments.",
            }

            time.sleep(0.15)
            if process.poll() is not None:
                error_text = self._read_process_error(process)
                return {
                    "status": "error",
                    "error_code": "SESSION_START_FAILED",
                    "message": error_text or "Unable to start live audio translation.",
                }

            session["status"] = "listening"
            session["updated_at"] = utc_timestamp()
            self._process = process
            self._session = session
            self._remember_selected_source(source, source_lang=request.source_lang, target_lang=request.target_lang)
            return self._session_snapshot()

    def stop_session(self, request) -> dict:
        with self._lock:
            self._sync_process_state()

            if not self._session or self._session.get("status") not in self.ACTIVE_STATUSES:
                return {
                    "status": "error",
                    "error_code": "SESSION_NOT_FOUND",
                    "message": "No active audio session found.",
                }

            if request.session_id and request.session_id != self._session.get("session_id"):
                return {
                    "status": "error",
                    "error_code": "SESSION_NOT_FOUND",
                    "message": "No active audio session found.",
                }

            process = self._process
            if process:
                try:
                    process.terminate()
                    process.wait(timeout=2)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=2)
                except Exception:
                    pass

            self._process = None
            self._session["status"] = "stopped"
            self._session["updated_at"] = utc_timestamp()
            self._session["last_error"] = None
            self._session["message"] = "Live capture stopped. Install a local ASR engine to stream transcript segments."
            return self._session_snapshot()
