create table if not exists public.password_reset_codes (
  email text primary key,
  code_hash text unique,
  expires_at timestamptz not null,
  attempts integer not null default 0,
  created_at timestamptz not null default now(),
  reset_token_hash text unique,
  reset_token_expires_at timestamptz
);

create table if not exists public.password_reset_ip_limits (
  ip_hash text primary key,
  window_started_at timestamptz not null default now(),
  request_count integer not null default 0
);

alter table public.password_reset_codes enable row level security;
alter table public.password_reset_ip_limits enable row level security;
revoke all on public.password_reset_codes from anon, authenticated;
revoke all on public.password_reset_ip_limits from anon, authenticated;
grant all on public.password_reset_codes to service_role;
grant all on public.password_reset_ip_limits to service_role;

create or replace function public.issue_password_reset_code(
  p_email text,
  p_code_hash text,
  p_ip_hash text
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_ip_request_count integer;
begin
  delete from public.password_reset_codes
  where expires_at <= now()
    and (reset_token_expires_at is null or reset_token_expires_at <= now());
  delete from public.password_reset_ip_limits
  where window_started_at <= now() - interval '24 hours';

  insert into public.password_reset_ip_limits as current_limit (
    ip_hash,
    window_started_at,
    request_count
  )
  values (p_ip_hash, now(), 1)
  on conflict (ip_hash) do update
  set window_started_at = case
        when current_limit.window_started_at <= now() - interval '15 minutes'
          then now()
        else current_limit.window_started_at
      end,
      request_count = case
        when current_limit.window_started_at <= now() - interval '15 minutes'
          then 1
        else current_limit.request_count + 1
      end
  returning current_limit.request_count into v_ip_request_count;

  if v_ip_request_count > 10 then
    return 'ip_rate_limited';
  end if;

  if exists (
    select 1
    from public.password_reset_codes
    where email = p_email and created_at > now() - interval '60 seconds'
  ) then
    return 'email_rate_limited';
  end if;

  delete from public.password_reset_codes where email = p_email;
  begin
    insert into public.password_reset_codes (email, code_hash, expires_at)
    values (p_email, p_code_hash, now() + interval '15 minutes');
  exception when unique_violation then
    return 'collision';
  end;
  return 'issued';
end;
$$;

create or replace function public.verify_password_reset_code(
  p_email text,
  p_code_hash text,
  p_reset_token_hash text
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  reset_row public.password_reset_codes%rowtype;
begin
  select * into reset_row
  from public.password_reset_codes
  where email = p_email
  for update;

  if not found or reset_row.code_hash is null then
    return 'invalid';
  end if;
  if reset_row.expires_at <= now() then
    delete from public.password_reset_codes where email = p_email;
    return 'expired';
  end if;
  if reset_row.attempts >= 5 then
    return 'locked';
  end if;
  if reset_row.code_hash <> p_code_hash then
    update public.password_reset_codes
    set attempts = attempts + 1
    where email = p_email;
    return 'invalid';
  end if;

  update public.password_reset_codes
  set code_hash = null,
      reset_token_hash = p_reset_token_hash,
      reset_token_expires_at = now() + interval '15 minutes'
  where email = p_email;
  return 'verified';
end;
$$;

create or replace function public.consume_password_reset_token(
  p_reset_token_hash text
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  reset_email text;
begin
  select email into reset_email
  from public.password_reset_codes
  where reset_token_hash = p_reset_token_hash
    and reset_token_expires_at > now()
  for update;

  if not found then
    return false;
  end if;
  delete from public.password_reset_codes where email = reset_email;
  return true;
end;
$$;

create or replace function public.invalidate_password_reset_code(p_email text)
returns void
language sql
security definer
set search_path = ''
as $$
  delete from public.password_reset_codes where email = p_email;
$$;

revoke all on function public.issue_password_reset_code(text, text, text) from public, anon, authenticated;
revoke all on function public.verify_password_reset_code(text, text, text) from public, anon, authenticated;
revoke all on function public.consume_password_reset_token(text) from public, anon, authenticated;
revoke all on function public.invalidate_password_reset_code(text) from public, anon, authenticated;
grant execute on function public.issue_password_reset_code(text, text, text) to service_role;
grant execute on function public.verify_password_reset_code(text, text, text) to service_role;
grant execute on function public.consume_password_reset_token(text) to service_role;
grant execute on function public.invalidate_password_reset_code(text) to service_role;
