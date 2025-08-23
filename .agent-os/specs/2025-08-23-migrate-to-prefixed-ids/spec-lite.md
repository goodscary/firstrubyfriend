# Spec Summary (Lite)

Replace ULID primary keys with standard integer IDs and implement the prefixed_ids gem for secure, readable public identifiers. This migration simplifies database operations while maintaining security through non-sequential public IDs with model-specific prefixes like `usr_` and `mnt_`.