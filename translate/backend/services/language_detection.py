from __future__ import annotations

import re


SCRIPT_PATTERNS = {
    "ja": re.compile(r"[\u3040-\u30ff]"),
    "ko": re.compile(r"[\uac00-\ud7af]"),
    "ru": re.compile(r"[\u0400-\u04ff]"),
    "zh": re.compile(r"[\u4e00-\u9fff]"),
}

LANGUAGE_HINTS = {
    "es": {" el ", " la ", " para ", " por ", " una ", " gracias ", " hola ", " necesito "},
    "fr": {" le ", " la ", " pour ", " une ", " bonjour ", " merci ", " près ", " fenêtre "},
    "de": {" der ", " die ", " das ", " und ", " bitte ", " ich ", " nicht "},
    "pt": {" para ", " uma ", " por ", " olá ", " obrigado ", " preciso ", " janela "},
    "it": {" il ", " la ", " per ", " una ", " grazie ", " ciao ", " vicino "},
    "en": {" the ", " and ", " for ", " please ", " need ", " hello ", " near ", " window "},
}


class LanguageDetectionService:
    def detect(self, text: str) -> dict:
        sample = f" {text.strip().lower()} "

        for code, pattern in SCRIPT_PATTERNS.items():
            if pattern.search(text):
                return {"language": code, "confidence": 0.99}

        best_code = "en"
        best_score = 0
        for code, hints in LANGUAGE_HINTS.items():
            score = sum(1 for hint in hints if hint in sample)
            if score > best_score:
                best_code = code
                best_score = score

        confidence = 0.55 if best_score == 0 else min(0.95, 0.55 + best_score * 0.1)
        return {"language": best_code, "confidence": confidence}
