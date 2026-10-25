---
name: postgres-migration
description: Add the next Supabase Postgres migration for the shared lesson schema.
---

# Postgres migration

## Workflow

1. Inspect `supabase/migrations`.
2. Run `supabase migration new <name>` from the repository root.
3. Append the SQL to the generated migration.
4. Do not edit older migration files.
5. Index new foreign keys.
6. Enable and force Row Level Security and revoke `public`, `anon`, and
   `authenticated` on every new table.
7. Update `docs/ownership.md` if ownership changes.

Do not assume Docker is available. Do not apply the migration to the hosted
project unless the user has provided a scoped token and asked for the push.
