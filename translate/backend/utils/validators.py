from __future__ import annotations

from models.response_models import ErrorResponse


LANGUAGE_ALIASES = {
    "auto": "auto",
    "english": "en",
    "en": "en",
    "spanish": "es",
    "es": "es",
    "french": "fr",
    "fr": "fr",
    "german": "de",
    "de": "de",
    "portuguese": "pt",
    "pt": "pt",
    "portuguese (brazil)": "pt-br",
    "pt-br": "pt-br",
    "pt_br": "pt-br",
    "ptbr": "pt-br",
    "italian": "it",
    "it": "it",
    "japanese": "ja",
    "ja": "ja",
    "korean": "ko",
    "ko": "ko",
    "russian": "ru",
    "ru": "ru",
    "chinese": "zh",
    "zh": "zh",
}


def normalize_language_code(value: str) -> str:
    normalized = (value or "").strip().lower()
    return LANGUAGE_ALIASES.get(normalized, normalized)


def validate_translate_request(request, *, max_text_length: int):
    text = request.text.strip()
    if not text:
        return ErrorResponse(status="error", error_code="EMPTY_TEXT", message="Enter text to translate.")

    if len(request.text) > max_text_length:
        return ErrorResponse(status="error", error_code="TEXT_TOO_LONG", message="Text exceeds the maximum supported length.")

    if request.source_lang == "":
        return ErrorResponse(status="error", error_code="INVALID_SOURCE_LANG", message="A source language is required.")

    if request.target_lang == "":
        return ErrorResponse(status="error", error_code="INVALID_TARGET_LANG", message="A target language is required.")

    if request.source_lang != "auto" and request.source_lang == request.target_lang:
        return ErrorResponse(status="error", error_code="SAME_LANGUAGE", message="Source and target languages must be different.")

    return None


def validate_audio_live_start_request(request):
    if not request.source_id:
        return ErrorResponse(status="error", error_code="INVALID_SOURCE", message="Selected audio source is unavailable.")

    if request.source_lang == "":
        return ErrorResponse(status="error", error_code="INVALID_SOURCE_LANG", message="A source language is required.")

    if request.target_lang == "":
        return ErrorResponse(status="error", error_code="INVALID_TARGET_LANG", message="A target language is required.")

    if request.source_lang != "auto" and request.source_lang == request.target_lang:
        return ErrorResponse(status="error", error_code="SAME_LANGUAGE", message="Source and target languages must be different.")

    return None
