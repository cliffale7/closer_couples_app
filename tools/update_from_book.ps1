# Sync the latest approved book into this Android project.
# A timestamp in book_inbox is not approval. Use --baseline only for the v0.1 inventory.

$ErrorActionPreference = "Stop"
$Repo = Split-Path -Parent $PSScriptRoot
$Python = Get-Command python -ErrorAction Stop
& $Python.Source (Join-Path $Repo "tools\book_ingest\sync_latest_book.py") @args
exit $LASTEXITCODE
