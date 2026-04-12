from __future__ import annotations

import re


PREFIX_PATTERN = re.compile(r"^(translation|translated text|result)\s*:\s*", re.IGNORECASE)


class ResultPostProcessor:
    def clean(self, text: str) -> str:
        cleaned = (text or "").strip()

        if cleaned.startswith("```") and cleaned.endswith("```"):
            cleaned = cleaned[3:-3].strip()

        cleaned = PREFIX_PATTERN.sub("", cleaned)

        if len(cleaned) >= 2 and cleaned[0] == cleaned[-1] and cleaned[0] in {'"', "'"}:
            inner = cleaned[1:-1].strip()
            if inner:
                cleaned = inner

        return cleaned.strip()
