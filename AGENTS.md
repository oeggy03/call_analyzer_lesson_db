# Agent guide

This repository contains the Supabase Postgres migrations and ownership
documentation for the shared Mandarin lesson database. Read
`docs/ownership.md` before changing the schema.

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
