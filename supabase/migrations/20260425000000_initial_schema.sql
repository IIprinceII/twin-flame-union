-- Twin Flame Union — initial schema
-- Enables RLS on all tables; users can only access their own rows.
-- Idempotent: safe to re-run. Uses core gen_random_uuid() (no extension dependency).

-- ─── Profiles ─────────────────────────────────────────────────────────────────
create table if not exists profiles (
    id           uuid primary key references auth.users on delete cascade,
    name         text,
    sun_sign     text,
    moon_sign    text,
    tf_stage     text,
    partner_sun  text,
    created_at   timestamptz default now()
);
alter table profiles enable row level security;
drop policy if exists "own profile" on profiles;
create policy "own profile" on profiles for all using (auth.uid() = id);

-- ─── Ritual Completions ───────────────────────────────────────────────────────
create table if not exists ritual_completions (
    id           uuid primary key default gen_random_uuid(),
    user_id      uuid references auth.users on delete cascade not null,
    completed_at date not null default current_date,
    unique (user_id, completed_at)
);
alter table ritual_completions enable row level security;
drop policy if exists "own rituals" on ritual_completions;
create policy "own rituals" on ritual_completions for all using (auth.uid() = user_id);

-- ─── Intentions ───────────────────────────────────────────────────────────────
create table if not exists intentions (
    id           uuid primary key default gen_random_uuid(),
    user_id      uuid references auth.users on delete cascade not null,
    body         text not null,
    created_at   timestamptz default now()
);
alter table intentions enable row level security;
drop policy if exists "own intentions" on intentions;
create policy "own intentions" on intentions for all using (auth.uid() = user_id);

-- ─── Gratitude Entries ────────────────────────────────────────────────────────
create table if not exists gratitude_entries (
    id           uuid primary key default gen_random_uuid(),
    user_id      uuid references auth.users on delete cascade not null,
    entry_1      text,
    entry_2      text,
    entry_3      text,
    created_at   timestamptz default now()
);
alter table gratitude_entries enable row level security;
drop policy if exists "own gratitude" on gratitude_entries;
create policy "own gratitude" on gratitude_entries for all using (auth.uid() = user_id);

-- ─── Journal Entries ──────────────────────────────────────────────────────────
create table if not exists journal_entries (
    id           uuid primary key default gen_random_uuid(),
    user_id      uuid references auth.users on delete cascade not null,
    prompt       text,
    body         text not null,
    source       text default 'seraphina',   -- 'seraphina' | 'free' | 'soul'
    created_at   timestamptz default now()
);
alter table journal_entries enable row level security;
drop policy if exists "own journals" on journal_entries;
create policy "own journals" on journal_entries for all using (auth.uid() = user_id);

-- ─── Oracle Pulls ─────────────────────────────────────────────────────────────
create table if not exists oracle_pulls (
    id           uuid primary key default gen_random_uuid(),
    user_id      uuid references auth.users on delete cascade not null,
    deity_name   text not null,
    invocation   text,
    created_at   timestamptz default now()
);
alter table oracle_pulls enable row level security;
drop policy if exists "own oracle" on oracle_pulls;
create policy "own oracle" on oracle_pulls for all using (auth.uid() = user_id);
