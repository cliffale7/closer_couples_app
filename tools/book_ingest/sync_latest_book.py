#!/usr/bin/env python3
"""One-command book sync. See docs/BOOK_UPDATE_PLAYBOOK.md."""

from __future__ import annotations

import sys
from pathlib import Path

_TOOLS = Path(__file__).resolve().parents[1]
if str(_TOOLS) not in sys.path:
    sys.path.insert(0, str(_TOOLS))

from book_ingest.cli import main

if __name__ == "__main__":
    raise SystemExit(main())
