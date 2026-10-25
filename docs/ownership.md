# Shared lesson database ownership

## Ecosystem

`call_analyzer` is the macOS desktop app at `../call_analyzer`. It stores
lessons locally in SQLite. `call-analyzer-active-recall` does not exist yet. It
will be a Cloud Run service that sends due vocabulary to Telegram and writes
review results.

This repository owns the Supabase Postgres migrations and the meaning of the
shared tables. It does not own the desktop app, the Telegram service, or the
sync goroutine.

## Table ownership

The desktop app writes:

- `lessons`
- `transcript_segments`
- `vocabulary_entries`
- `senses`
- `examples`
- `observations`
- `tags`
- `entry_tags`

The future recall service appends `review_events` and updates `study_state`.
The desktop pulls those two tables and does not push them back over a newer
cloud row.

These SQLite tables are local-only and must never be added here:

- `outbox`
- `settings`
- `request_usage`

## Schema changes

Add a new migration in this repository, apply it to Supabase, and then update
the consumer that uses the column. Do not edit a migration after it has been
applied.

IDs are client-supplied UUID values because the desktop app already generates
them. Do not replace them with identity columns.

Row Level Security is enabled and forced. There are no policies. `anon` and
`authenticated` have no grants. Do not expose these tables to the Data API and
do not add an `auth.uid()` policy until a user ID exists.

## Secrets

Database passwords, access tokens, service-role keys, and connection strings
with passwords stay out of git.
