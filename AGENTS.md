# Agent guide

This repository contains the Supabase Postgres migrations and ownership
documentation for the shared Mandarin lesson database. Read
`docs/ownership.md` before changing the schema.

## Ecosystem

`../call_analyzer` is the desktop app. Its sync goroutine pushes confirmed and
manually saved vocabulary, pulls confirmed vocabulary on launch, and uses this
Mac's own `SUPABASE_SECRET_KEY`. `../call-analyzer-active-recall` is deployed
as Cloud Run service `active-recall` in GCP project `call-analyzer-512714`,
region `asia-southeast1`. Cloud Scheduler job `daily-vocabulary` calls
`POST /daily` at 9:00 `Asia/Singapore`. That service reads confirmed
vocabulary with a separate Supabase secret and does not write reviews yet.

The hosted project ref is `zoiwsytnyrdifggwleru`. Migration
`20261025103511_initial_schema.sql` is already applied. Do not edit it. A new
shared column is a new migration here, then an update in each consumer that
uses the column.

## Working rules

- Read `supabase/migrations` before adding a file.
- Create the next migration from this repository root with
  `supabase migration new <name>`.
- Never invent a migration filename.
- Never edit an applied migration.
- Do not put sync worker code here.
- Do not open or edit `../call_analyzer` unless the user opened that workspace.
- Keep SQL identifiers lowercase and unquoted.
- Index every foreign key. A primary key or a composite index whose first
  column is the foreign key counts.
- Money stays `numeric`.
- Timestamps stay `timestamptz`.
- Do not commit `.env`.

The Supabase CLI version used for this repository is 2.122.0. Local
`supabase db reset` needs Docker, which was not available when this repository
was created.

Hosted apply is:

```sh
supabase link --project-ref <ref>
supabase db push --linked
```

Run those commands only after the user has supplied a scoped token and the
database password. Do not run `supabase login`, because it creates a
full-account token.
