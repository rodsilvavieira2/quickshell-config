from __future__ import annotations

import json
import shutil
import subprocess


class AudioDeviceDiscoveryService:
    def __init__(self) -> None:
        self.pactl_bin = shutil.which("pactl")

    def _run_json(self, *args: str):
        if not self.pactl_bin:
            return None

        try:
            result = subprocess.run(
                [self.pactl_bin, "-f", "json", *args],
                capture_output=True,
                text=True,
                timeout=8,
                check=False,
            )
        except Exception:
            return None

        if result.returncode != 0:
            return None

        try:
            return json.loads(result.stdout)
        except json.JSONDecodeError:
            return None

    def _is_playback_monitor(self, source: dict) -> bool:
        name = str(source.get("name", "") or "")
        properties = source.get("properties", {}) if isinstance(source.get("properties"), dict) else {}
        device_class = str(properties.get("device.class", "") or "")
        monitor_source = str(source.get("monitor_source", "") or "")
        media_class = str(properties.get("media.class", "") or "")

        return bool(
            monitor_source
            or device_class == "monitor"
            or name.endswith(".monitor")
            or media_class == "Audio/Sink"
        )

    def _is_available(self, source: dict) -> bool:
        ports = source.get("ports", []) if isinstance(source.get("ports"), list) else []
        if not ports:
            return True

        available_ports = [port for port in ports if str(port.get("availability", "unknown")) != "not available"]
        return len(available_ports) > 0

    def _normalize_name(self, source: dict) -> str:
        description = str(source.get("description", "") or "").strip()
        name = str(source.get("name", "") or "").strip()

        if description.startswith("Monitor of "):
            return description[len("Monitor of "):].strip() + " Monitor"

        if description:
            return description

        if name.endswith(".monitor"):
            return name.removesuffix(".monitor") + " Monitor"

        return name

    def _build_source_payload(self, source: dict, *, default_input: str, default_playback_monitor: str) -> dict | None:
        source_id = str(source.get("name", "") or "").strip()
        if not source_id:
            return None

        source_type = "playback_monitor" if self._is_playback_monitor(source) else "input"
        is_available = self._is_available(source)
        if not is_available:
            return None

        return {
            "id": source_id,
            "name": self._normalize_name(source),
            "type": source_type,
            "backend": "pipewire",
            "is_default": source_id == (default_playback_monitor if source_type == "playback_monitor" else default_input),
            "is_available": True,
        }

    def list_audio_sources(self) -> list[dict]:
        info = self._run_json("info")
        raw_sources = self._run_json("list", "sources")
        if not isinstance(info, dict) or not isinstance(raw_sources, list):
            return []

        default_input = str(info.get("default_source_name", "") or "")
        default_sink = str(info.get("default_sink_name", "") or "")
        default_playback_monitor = default_sink + ".monitor" if default_sink else ""

        sources = []
        for raw_source in raw_sources:
            if not isinstance(raw_source, dict):
                continue

            payload = self._build_source_payload(
                raw_source,
                default_input=default_input,
                default_playback_monitor=default_playback_monitor,
            )
            if payload:
                sources.append(payload)

        order = {"input": 0, "playback_monitor": 1}
        sources.sort(key=lambda item: (order.get(item["type"], 99), 0 if item["is_default"] else 1, item["name"].lower()))
        return sources

    def get_default_input(self) -> dict | None:
        for source in self.list_audio_sources():
            if source["type"] == "input" and source["is_default"]:
                return source
        return None

    def get_default_playback_monitor(self) -> dict | None:
        for source in self.list_audio_sources():
            if source["type"] == "playback_monitor" and source["is_default"]:
                return source
        return None

    def refresh_sources(self) -> list[dict]:
        return self.list_audio_sources()
