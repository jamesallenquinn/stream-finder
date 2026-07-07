-- ============================================================================
-- StreamFind — shared "Recents" sync across devices.
--
-- ONE-TIME SETUP: paste this whole file into the Supabase dashboard
--   → SQL Editor → New query → Run.
-- Safe to re-run (IF NOT EXISTS / drop-then-create policies).
--
-- One row per household sync code; every device with the same code
-- reads and writes that row. The code is the only secret (the data is
-- just a list of TV shows/movies — not sensitive).
-- ============================================================================

create table if not exists public.streamfind_recents (
  code       text primary key,
  data       jsonb       not null default '{}'::jsonb,  -- { items: [...], deleted: {...} }
  updated_at timestamptz not null default now()
);

alter table public.streamfind_recents enable row level security;

drop policy if exists "streamfind read"   on public.streamfind_recents;
drop policy if exists "streamfind insert" on public.streamfind_recents;
drop policy if exists "streamfind update" on public.streamfind_recents;

create policy "streamfind read"   on public.streamfind_recents for select using (true);
create policy "streamfind insert" on public.streamfind_recents for insert with check (true);
create policy "streamfind update" on public.streamfind_recents for update using (true) with check (true);

-- This project has hardened defaults (no automatic grants), so the anon role
-- needs explicit table privileges on top of the RLS policies.
grant select, insert, update on public.streamfind_recents to anon;
