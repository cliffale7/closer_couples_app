"""Book intake, stable-ID diff, and journal-safe content activation.

The v0.1 catalog is a scope baseline. This package must not mark it as a
finished book.
"""

CONTENT_SCHEMA_VERSION = "1.0.0"
SUPPORTED_SCHEMA_MAJOR = 1
JOURNAL_SCHEMA_VERSION = "1"

__all__ = [
    "CONTENT_SCHEMA_VERSION",
    "JOURNAL_SCHEMA_VERSION",
    "SUPPORTED_SCHEMA_MAJOR",
]
