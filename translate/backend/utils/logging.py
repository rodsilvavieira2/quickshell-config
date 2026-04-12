from __future__ import annotations

import sys
import traceback


def log_info(message: str) -> None:
    sys.stderr.write(f"[translate-backend] {message}\n")
    sys.stderr.flush()


def log_exception(message: str, error: Exception) -> None:
    sys.stderr.write(f"[translate-backend] {message}: {error}\n")
    traceback.print_exc(file=sys.stderr)
    sys.stderr.flush()
