# Call Analyzer Lesson Database

This repository contains the Supabase Postgres migrations for the shared
Mandarin lesson ecosystem. The desktop app supplies client-generated UUIDs;
this repository defines the shared tables and their meaning.

## Sibling layout

```text
../
├── call_analyzer/                  # macOS desktop app and local SQLite database
├── call-analyzer-lesson-db/        # this repository
└── call-analyzer-active-recall/    # live Cloud Run Telegram recall service
```

## Ownership

The desktop runner currently pushes confirmed and manually saved vocabulary,
including senses, examples, and tags, and pulls confirmed vocabulary on
launch. The recall service reads those confirmed rows for the 9:00 Telegram
message and does not write reviews yet. Lessons, transcripts, observations,
and review events are in the schema and are not written by either app yet.
The desktop-only `outbox`, `settings`, and `request_usage` tables are not
part of this schema.

See [`docs/ownership.md`](docs/ownership.md) for the canonical ownership note,
schema-change order, RLS posture, and secret-handling rules.

## Hosted setup

The project name is `call-analyzer-lesson-db`. When creating the project, use
the default region `ap-southeast-1` and the free-plan default instance size.
Do not pass `--size` or `--high-availability`.

Create an access token in the Supabase access-token settings. Prefer a scoped
token with the `sbp_fc` prefix over `supabase login`. If an organization ID is
not passed, the token needs `Projects` read. Creating a project requires
`Organization Projects` read-write. Linking requires `Project Settings` read,
`API Keys` read, and `API Key Secrets` read.

After the project and credentials are available, run:

```sh
supabase link --project-ref <ref>
supabase db push --linked
```

The push needs the database password through `SUPABASE_DB_PASSWORD` or
`--password`. If the CLI applies migrations through the API, the token also
needs `Migrations` read-write.

Do not store the access token, database password, service-role key, or a
credential-bearing connection string in git.

## Initial local state

Docker was unavailable when this repository was created, so the migration was
not applied to a local database in the initial commit.
