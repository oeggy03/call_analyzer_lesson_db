# Shared lesson schema reference

## Tables

The shared schema contains:

- `lessons`
- `transcript_segments`
- `vocabulary_entries`
- `senses`
- `examples`
- `observations`
- `tags`
- `entry_tags`
- `study_state`
- `review_events`

## SQLite-to-Postgres type mapping

- Text UUID values become `uuid`.
- Integer Unix-millisecond timestamps become `timestamptz`.
- Integer `0`/`1` flags become `boolean`.
- The `final_cost` real money value becomes `numeric(12, 6)`.
- Other real values become `double precision`.

## Excluded tables

These desktop-only SQLite tables are excluded from Supabase:

- `outbox`
- `settings`
- `request_usage`
