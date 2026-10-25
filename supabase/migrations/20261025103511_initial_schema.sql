-- Shared Postgres schema for the Mandarin lesson ecosystem.
-- The desktop app keeps its own SQLite database and supplies these ids.
-- Timestamps are timestamptz. SQLite integer milliseconds are not reused.
-- SQLite 0/1 flags are booleans. final_cost is numeric because it is money.
-- outbox, settings, and request_usage stay on the device and are not created here.

create table public.lessons (
  id uuid primary key,
  title text not null default '',
  started_at timestamptz not null,
  ended_at timestamptz,
  created_at timestamptz not null,
  consent_recorded boolean not null default false,
  target text not null default '',
  stt_model text not null default '',
  analyzer_model text not null default '',
  retention_policy text not null default '',
  final_cost numeric(12, 6) not null default 0,
  lesson_tags text not null default ''
);

create table public.transcript_segments (
  id uuid primary key,
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  start_ms integer not null,
  end_ms integer not null,
  text text not null,
  simplified_text text not null default '',
  traditional_text text not null default '',
  reading text not null default '',
  source text not null default '',
  confidence double precision not null default 0,
  created_at timestamptz not null,
  constraint transcript_segments_time_order check (end_ms >= start_ms)
);

create index transcript_segments_lesson_time_idx
  on public.transcript_segments (lesson_id, start_ms, end_ms);

create table public.vocabulary_entries (
  id uuid primary key,
  simplified text not null,
  traditional text not null,
  reading text not null,
  marked_pinyin text not null default '',
  status text not null,
  provenance text not null,
  confidence double precision not null default 0,
  teaching_cue double precision not null default 0,
  manual boolean not null default false,
  priority text not null default '',
  merged_into_id uuid references public.vocabulary_entries (id) on delete set null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  constraint vocabulary_entries_status_check check (
    status in ('candidate', 'confirmed', 'rejected', 'merged')
  ),
  constraint vocabulary_entries_dedup unique (simplified, traditional, reading)
);

create index vocabulary_entries_status_updated_idx
  on public.vocabulary_entries (status, updated_at desc);

create index vocabulary_entries_merged_into_idx
  on public.vocabulary_entries (merged_into_id);

create table public.senses (
  id uuid primary key,
  entry_id uuid not null references public.vocabulary_entries (id) on delete cascade,
  gloss text not null,
  part_of_speech text not null default '',
  classifier text not null default '',
  sort_order integer not null default 0
);

create index senses_entry_id_idx on public.senses (entry_id);

create table public.examples (
  id uuid primary key,
  entry_id uuid not null references public.vocabulary_entries (id) on delete cascade,
  simplified text not null,
  traditional text not null default '',
  reading text not null default '',
  translation text not null default '',
  provenance text not null,
  generated boolean not null default false
);

create index examples_entry_id_idx on public.examples (entry_id);

create table public.observations (
  id uuid primary key,
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  segment_id uuid references public.transcript_segments (id) on delete set null,
  entry_id uuid not null references public.vocabulary_entries (id) on delete cascade,
  evidence_text text not null,
  start_ms integer not null default 0,
  end_ms integer not null default 0,
  confidence double precision not null default 0,
  created_at timestamptz not null
);

create index observations_lesson_created_idx
  on public.observations (lesson_id, created_at);

create index observations_entry_created_idx
  on public.observations (entry_id, created_at);

create index observations_segment_id_idx
  on public.observations (segment_id);

create table public.tags (
  id uuid primary key,
  name text not null,
  constraint tags_name_unique unique (name)
);

create table public.entry_tags (
  entry_id uuid not null references public.vocabulary_entries (id) on delete cascade,
  tag_id uuid not null references public.tags (id) on delete cascade,
  primary key (entry_id, tag_id)
);

create index entry_tags_tag_id_idx on public.entry_tags (tag_id);

create table public.study_state (
  entry_id uuid primary key references public.vocabulary_entries (id) on delete cascade,
  due_at timestamptz,
  interval_days double precision not null default 0,
  ease double precision not null default 2.5,
  repetitions integer not null default 0,
  lapses integer not null default 0,
  last_reviewed_at timestamptz
);

create index study_state_due_idx
  on public.study_state (due_at)
  where due_at is not null;

create table public.review_events (
  id uuid primary key,
  entry_id uuid not null references public.vocabulary_entries (id) on delete cascade,
  rating integer not null,
  reviewed_at timestamptz not null,
  metadata text not null default '',
  constraint review_events_rating_check check (rating >= 0 and rating <= 5)
);

create index review_events_entry_reviewed_idx
  on public.review_events (entry_id, reviewed_at);

alter default privileges in schema public
  revoke all on tables from public, anon, authenticated;

do $$
declare
  locked_table text;
begin
  foreach locked_table in array array[
    'lessons',
    'transcript_segments',
    'vocabulary_entries',
    'senses',
    'examples',
    'observations',
    'tags',
    'entry_tags',
    'study_state',
    'review_events'
  ]
  loop
    execute format('alter table public.%I enable row level security', locked_table);
    execute format('alter table public.%I force row level security', locked_table);
    execute format(
      'revoke all on table public.%I from public, anon, authenticated',
      locked_table
    );
  end loop;
end $$;
