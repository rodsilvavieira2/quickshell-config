from __future__ import annotations


LANGUAGE_NAMES = {
    "auto": "Auto",
    "en": "English",
    "es": "Spanish",
    "fr": "French",
    "de": "German",
    "pt": "Portuguese",
    "pt-br": "Portuguese (Brazil)",
    "it": "Italian",
    "ja": "Japanese",
    "ko": "Korean",
    "ru": "Russian",
    "zh": "Chinese",
}


class PromptBuilder:
    def build(self, *, text: str, source_lang: str, target_lang: str, detected_source_lang: str | None) -> str:
        source_name = LANGUAGE_NAMES.get(source_lang, source_lang)
        target_name = LANGUAGE_NAMES.get(target_lang, target_lang)
        detected_name = LANGUAGE_NAMES.get(detected_source_lang or "", detected_source_lang or "")

        if source_lang == "auto" and detected_source_lang:
            translation_line = f"Translate the following text from the detected source language ({detected_name}) to {target_name}."
        else:
            translation_line = f"Translate the following text from {source_name} to {target_name}."

        return "\n".join([
            "You are a translation engine.",
            "",
            translation_line,
            "",
            "Rules:",
            "- Return only the translated text.",
            "- Do not explain anything.",
            "- Preserve meaning and tone.",
            "- Preserve line breaks.",
            "- Preserve URLs, emails, placeholders, variable names, and code-like tokens.",
            "- Do not add quotation marks unless they already exist.",
            "",
            "Text:",
            text,
        ])
