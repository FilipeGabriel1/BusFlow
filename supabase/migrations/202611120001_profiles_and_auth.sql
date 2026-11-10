alter table public.user_profiles
  add column if not exists profile_data jsonb not null default '{}'::jsonb;

create or replace function public.create_busflow_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  requested_role_value text;
begin
  requested_role_value := case
    when new.raw_user_meta_data ->> 'requested_role' in ('student', 'driver', 'admin')
      then new.raw_user_meta_data ->> 'requested_role'
    else 'student'
  end;
  insert into public.user_profiles (
    id,
    email,
    display_name,
    requested_role,
    profile_data,
    status
  )
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'display_name', ''),
    requested_role_value,
    coalesce(new.raw_user_meta_data -> 'profile_data', '{}'::jsonb),
    case when requested_role_value = 'student' then 'active' else 'pending' end
  )
  on conflict (id) do update
    set email = excluded.email,
        display_name = excluded.display_name,
        requested_role = excluded.requested_role,
        profile_data = excluded.profile_data,
        updated_at = now();
  return new;
end;
$$;

create or replace function public.sync_busflow_profile_email()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.email is distinct from old.email then
    update public.user_profiles
    set email = coalesce(new.email, ''),
        updated_at = now()
    where id = new.id;
  end if;
  return new;
end;
$$;

drop trigger if exists on_auth_user_email_updated_busflow on auth.users;
create trigger on_auth_user_email_updated_busflow
  after update of email on auth.users
  for each row execute function public.sync_busflow_profile_email();

revoke all on public.user_profiles from anon, authenticated;
grant select on public.user_profiles to authenticated;
grant update (display_name, profile_data) on public.user_profiles to authenticated;

create or replace function public.consume_password_reset_token_email(
  p_reset_token_hash text
)
returns text
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
    return null;
  end if;
  delete from public.password_reset_codes where email = reset_email;
  return reset_email;
end;
$$;

revoke all on function public.consume_password_reset_token_email(text)
  from public, anon, authenticated;
grant execute on function public.consume_password_reset_token_email(text)
  to service_role;
