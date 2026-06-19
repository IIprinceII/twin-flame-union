-- Global daily ceiling for the claude-proxy edge function — a hard backstop that
-- protects the paid Anthropic budget even if the public anon key is extracted and
-- abused from many IPs. The per-IP check_proxy_rate already RECORDS each hit; this
-- function only READS the global count over the last day, so it does not double-count.
-- Created 2026-06-18 (stabilize pass).

create or replace function public.check_proxy_under_global_cap(
  p_max_per_day int default 5000
)
returns boolean
language sql
security definer
set search_path = public
as $$
  select count(*) < p_max_per_day
  from public.proxy_usage
  where created_at > now() - interval '1 day';
$$;
