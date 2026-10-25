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

## Current consumers

- Desktop sync pushes confirmed and manually saved `vocabulary_entries`,
  `senses`, `examples`, `tags`, and `entry_tags`. It inserts `study_state`
  once with ignore-duplicates and pulls confirmed vocabulary on launch.
- Active recall reads confirmed `vocabulary_entries` and `senses` for the 9:00
  `Asia/Singapore` Telegram message. It does not write.
- `lessons`, `transcript_segments`, `observations`, and `review_events` have
  no writer yet.

## Excluded tables

These desktop-only SQLite tables are excluded from Supabase:

- `outbox`
- `settings`
- `request_usage`
