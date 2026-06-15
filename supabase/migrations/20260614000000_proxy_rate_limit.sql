-- Per-IP rate limiting for the claude-proxy edge function.
-- Created 2026-06-14 (Phase 0 security hardening).

create table if not exists public.proxy_usage (
  id bigserial primary key,
  ip text not null,
  created_at timestamptz not null default now()
);

create index if not exists proxy_usage_ip_time
  on public.proxy_usage (ip, created_at desc);

-- Lock the table down: only the service role (used by the edge function) may touch it.
alter table public.proxy_usage enable row level security;

-- Returns true if the IP is UNDER the limit (and records the hit), false if over.
-- Defaults: 20 requests/minute, 300/day per IP.
create or replace function public.check_proxy_rate(
  p_ip text,
  p_per_min int default 20,
  p_per_day int default 300
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  min_count int;
  day_count int;
begin
  select count(*) into min_count from public.proxy_usage
    where ip = p_ip and created_at > now() - interval '1 minute';
  select count(*) into day_count from public.proxy_usage
    where ip = p_ip and created_at > now() - interval '1 day';

  if min_count >= p_per_min or day_count >= p_per_day then
    return false;
  end if;

  insert into public.proxy_usage (ip) values (p_ip);
  return true;
end;
$$;

-- Optional housekeeping: drop usage rows older than 2 days to keep the table small.
-- (Run manually or via a scheduled job; not required for correctness.)
-- delete from public.proxy_usage where created_at < now() - interval '2 days';
