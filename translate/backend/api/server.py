#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import signal
import sys
import threading
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

from services.audio_device_discovery import AudioDeviceDiscoveryService
from services.audio_session_controller import AudioSessionController
from services.history_service import HistoryService
from services.ollama_gateway import OllamaGateway
from services.settings_service import SettingsService
from services.translation_controller import TranslationController
from utils.logging import log_exception, log_info


HOST = os.environ.get("QS_TRANSLATE_HOST", "127.0.0.1")
PORT = int(os.environ.get("QS_TRANSLATE_PORT", "18456"))


def build_controller() -> TranslationController:
    base_dir = os.path.dirname(os.path.dirname(__file__))
    data_dir = os.path.join(base_dir, "storage")
    os.makedirs(data_dir, exist_ok=True)

    settings = SettingsService(os.path.join(data_dir, "settings.json"))
    history = HistoryService(os.path.join(data_dir, "history.sqlite3"))
    gateway = OllamaGateway(settings)
    audio_discovery = AudioDeviceDiscoveryService()
    audio_session = AudioSessionController(settings=settings, discovery=audio_discovery)
    return TranslationController(
        settings=settings,
        gateway=gateway,
        history=history,
        audio_discovery=audio_discovery,
        audio_session=audio_session,
    )


CONTROLLER = build_controller()


class ReusableThreadingHTTPServer(ThreadingHTTPServer):
    allow_reuse_address = True


class TranslateRequestHandler(BaseHTTPRequestHandler):
    server_version = "QuickshellTranslateBackend/0.1"

    def log_message(self, format: str, *args) -> None:
        log_info(format % args)

    def do_GET(self) -> None:
        try:
            if self.path == "/health":
                self.respond(HTTPStatus.OK, CONTROLLER.health_payload())
                return

            if self.path == "/models":
                self.respond(HTTPStatus.OK, CONTROLLER.list_models_payload())
                return

            if self.path == "/models/current":
                self.respond(HTTPStatus.OK, CONTROLLER.current_model_payload())
                return

            if self.path == "/audio/sources":
                self.respond(HTTPStatus.OK, CONTROLLER.list_audio_sources_payload())
                return

            if self.path == "/audio/live/session":
                self.respond(HTTPStatus.OK, CONTROLLER.current_audio_session_payload())
                return

            self.respond(HTTPStatus.NOT_FOUND, {
                "status": "error",
                "error_code": "NOT_FOUND",
                "message": "Endpoint not found.",
            })
        except Exception as error:
            log_exception("GET request failed", error)
            self.respond(HTTPStatus.INTERNAL_SERVER_ERROR, {
                "status": "error",
                "error_code": "INTERNAL_ERROR",
                "message": "The backend failed to process the request.",
            })

    def do_POST(self) -> None:
        try:
            payload = self.read_json_body()

            if self.path == "/translate/text":
                result = CONTROLLER.translate_text(payload)
                status = HTTPStatus.OK if result.get("status") != "error" else HTTPStatus.BAD_REQUEST
                self.respond(status, result)
                return

            if self.path == "/models/select":
                result = CONTROLLER.select_model(payload)
                status = HTTPStatus.OK if result.get("status") != "error" else HTTPStatus.BAD_REQUEST
                self.respond(status, result)
                return

            if self.path == "/audio/live/start":
                result = CONTROLLER.start_audio_session(payload)
                status = HTTPStatus.OK if result.get("status") != "error" else HTTPStatus.BAD_REQUEST
                self.respond(status, result)
                return

            if self.path == "/audio/live/stop":
                result = CONTROLLER.stop_audio_session(payload)
                status = HTTPStatus.OK if result.get("status") != "error" else HTTPStatus.BAD_REQUEST
                self.respond(status, result)
                return

            self.respond(HTTPStatus.NOT_FOUND, {
                "status": "error",
                "error_code": "NOT_FOUND",
                "message": "Endpoint not found.",
            })
        except ValueError as error:
            self.respond(HTTPStatus.BAD_REQUEST, {
                "status": "error",
                "error_code": "INVALID_JSON",
                "message": str(error),
            })
        except Exception as error:
            log_exception("POST request failed", error)
            self.respond(HTTPStatus.INTERNAL_SERVER_ERROR, {
                "status": "error",
                "error_code": "INTERNAL_ERROR",
                "message": "The backend failed to process the request.",
            })

    def do_OPTIONS(self) -> None:
        self.send_response(HTTPStatus.NO_CONTENT)
        self.send_common_headers()
        self.end_headers()

    def read_json_body(self) -> dict:
        content_length = int(self.headers.get("Content-Length", "0") or "0")
        if content_length <= 0:
            return {}

        raw_body = self.rfile.read(content_length)
        try:
            parsed = json.loads(raw_body.decode("utf-8"))
        except json.JSONDecodeError as error:
            raise ValueError("Request body must be valid JSON.") from error

        if not isinstance(parsed, dict):
            raise ValueError("Request body must be a JSON object.")

        return parsed

    def send_common_headers(self) -> None:
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def respond(self, status: HTTPStatus, payload: dict) -> None:
        body = json.dumps(payload, ensure_ascii=True, separators=(",", ":")).encode("utf-8")
        try:
            self.send_response(status)
            self.send_common_headers()
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        except BrokenPipeError:
            log_info("Client disconnected before response body could be written")


def run_server() -> None:
    server = ReusableThreadingHTTPServer((HOST, PORT), TranslateRequestHandler)
    log_info(f"Translate backend listening on http://{HOST}:{PORT}")

    def shutdown(*_args: object) -> None:
        log_info("Translate backend shutting down")
        threading.Thread(target=server.shutdown, daemon=True).start()

    signal.signal(signal.SIGTERM, shutdown)
    signal.signal(signal.SIGINT, shutdown)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
        log_info("Translate backend stopped")
