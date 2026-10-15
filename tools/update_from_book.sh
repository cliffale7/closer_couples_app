#!/usr/bin/env sh
# Sync the latest approved book. A filesystem timestamp is not approval.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
python "$ROOT/tools/book_ingest/sync_latest_book.py" "$@"
