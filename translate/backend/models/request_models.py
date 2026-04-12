from __future__ import annotations

from dataclasses import dataclass


@dataclass(slots=True)
class TranslateTextRequest:
    text: str
    source_lang: str
    target_lang: str


@dataclass(slots=True)
class SelectModelRequest:
    model: str


@dataclass(slots=True)
class AudioLiveStartRequest:
    source_id: str
    source_lang: str
    target_lang: str


@dataclass(slots=True)
class AudioLiveStopRequest:
    session_id: str
