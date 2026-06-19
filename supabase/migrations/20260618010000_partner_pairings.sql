-- Phase 6a: partner connection — pairings + shared connection events.
-- Secured by RLS keyed on the anonymous auth.uid() so ONLY the two paired souls
-- can ever read or write their own pairing's data. Created 2026-06-18.

-- ── pairings ────────────────────────────────────────────────────────────────
create table if not exists public.pairings (
  id          uuid primary key default gen_random_uuid(),
  invite_code text not null unique,
  creator_id  uuid not null default auth.uid(),
  partner_id  uuid,
  status      text not null default 'pending' check (status in ('pending','active')),
  created_at  timestamptz not null default now()
);

alter table public.pairings enable row level security;

-- Only the two members can see their pairing.
create policy "pairings_select_members" on public.pairings
  for select using (auth.uid() = creator_id or auth.uid() = partner_id);

-- A signed-in soul can create a pairing they own (creator defaults to auth.uid()).
create policy "pairings_insert_own" on public.pairings
  for insert with check (auth.uid() = creator_id);

-- NO client UPDATE policy on purpose: a member-update policy without a column
-- guard would let a member rewrite creator_id / invite_code (ownership/hijack).
-- The only mutation — partner-linking — goes through accept_pairing() below
-- (security definer). Any future change (e.g. unpair) gets its own RPC.

-- ── connection_events (shared timeline / thoughts / streak) ──────────────────
create table if not exists public.connection_events (
  id         uuid primary key default gen_random_uuid(),
  pairing_id uuid not null references public.pairings(id) on delete cascade,
  author_id  uuid not null default auth.uid(),
  kind       text not null check (kind in ('timeline','thought','streak')),
  body       text,
  created_at timestamptz not null default now()
);

create index if not exists connection_events_pairing_time
  on public.connection_events (pairing_id, created_at desc);

alter table public.connection_events enable row level security;

-- Security-definer membership check (bypasses pairings RLS to avoid recursion).
create or replace function public.is_pairing_member(p_pairing uuid)
returns boolean language sql security definer stable set search_path = public as $$
  select exists (
    select 1 from public.pairings
    where id = p_pairing and (creator_id = auth.uid() or partner_id = auth.uid())
  );
$$;

-- Members read their pairing's events.
create policy "events_select_members" on public.connection_events
  for select using (public.is_pairing_member(pairing_id));

-- A member may post an event authored by themselves into their own pairing.
create policy "events_insert_member_author" on public.connection_events
  for insert with check (author_id = auth.uid() and public.is_pairing_member(pairing_id));

-- ── accept_pairing(code) ─────────────────────────────────────────────────────
-- The accepter is not yet a member, so a plain UPDATE would be blocked by RLS.
-- This security-definer RPC links them iff the pairing is open and not their own.
create or replace function public.accept_pairing(p_code text)
returns public.pairings language plpgsql security definer set search_path = public as $$
declare
  result public.pairings;
begin
  update public.pairings
     set partner_id = auth.uid(), status = 'active'
   where invite_code = p_code
     and partner_id is null
     and creator_id <> auth.uid()
  returning * into result;

  if not found then
    raise exception 'invalid_or_taken_code' using errcode = 'P0001';
  end if;
  return result;
end;
$$;
