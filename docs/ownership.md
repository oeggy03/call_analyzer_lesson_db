# Shared lesson database ownership

## Ecosystem

`call_analyzer` is the macOS desktop app at `../call_analyzer`. It stores
lessons locally in SQLite and runs the vocabulary sync goroutine.
`call-analyzer-active-recall` is the live Cloud Run service in GCP project
`call-analyzer-512714`, region `asia-southeast1`. It reads confirmed
vocabulary and sends up to ten words to Telegram at 9:00 `Asia/Singapore`.
It does not write `study_state` or `review_events` yet.

This repository owns the Supabase Postgres migrations and the meaning of the
shared tables. The hosted project ref is `zoiwsytnyrdifggwleru`. Migration
`20261025103511_initial_schema.sql` is applied. It does not own the desktop
app, the Telegram service, or the sync goroutine.

## Table ownership

The schema includes `lessons`, `transcript_segments`, `vocabulary_entries`,
`senses`, `examples`, `observations`, `tags`, `entry_tags`, `study_state`,
and `review_events`.

What the running apps do now:

- The desktop runner pushes the current SQLite row for confirmed and manually
  saved vocabulary, including senses, examples, tags, and entry tags. A merged
  candidate is not pushed. When its target is confirmed, that target is pushed
  again so the moved child rows are included.
- The first confirmed or manual publish inserts `study_state` with
  ignore-duplicates. Later study updates are not pushed.
- On launch the desktop pulls confirmed vocabulary. A newer local `updated_at`
  wins. `SyncNow` uploads and does not pull.
- The recall service reads confirmed `vocabulary_entries` and their senses. It
  does not write.

`lessons`, `transcript_segments`, `observations`, and `review_events` are in
the schema and are not written by either app yet. Quiz replies are the
intended later writer of `review_events` and `study_state` updates.

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
