create table if not exists public.user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  display_name text not null default '',
  role text not null default 'student'
    check (role in ('student', 'driver', 'admin')),
  requested_role text not null default 'student'
    check (requested_role in ('student', 'driver', 'admin')),
  status text not null default 'active'
    check (status in ('active', 'pending', 'blocked')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.current_profile_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.user_profiles where id = auth.uid()
$$;

create or replace function public.is_busflow_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_profile_role() = 'admin', false)
$$;

create or replace function public.is_busflow_driver()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_profile_role() = 'driver', false)
$$;

create or replace function public.create_busflow_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_profiles (id, email, display_name, requested_role)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'display_name', ''),
    case
      when new.raw_user_meta_data ->> 'requested_role' in ('student', 'driver', 'admin')
        then new.raw_user_meta_data ->> 'requested_role'
      else 'student'
    end
  )
  on conflict (id) do update
    set email = excluded.email,
        display_name = excluded.display_name,
        updated_at = now();
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_busflow on auth.users;
create trigger on_auth_user_created_busflow
  after insert on auth.users
  for each row execute function public.create_busflow_profile();

create table if not exists public.buses (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  model text not null,
  plate text not null unique,
  capacity integer not null check (capacity > 0),
  status text not null default 'operational'
    check (status in ('operational', 'maintenance', 'inactive')),
  created_at timestamptz not null default now()
);

create table if not exists public.routes (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  origin text not null,
  destination text not null,
  schedule jsonb not null default '[]'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  route_id uuid not null references public.routes(id),
  bus_id uuid not null references public.buses(id),
  driver_id uuid not null references public.user_profiles(id),
  status text not null default 'scheduled'
    check (status in ('scheduled', 'in_progress', 'completed', 'cancelled')),
  starts_at timestamptz not null,
  ends_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.driver_shifts (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references public.user_profiles(id) on delete cascade,
  route_id uuid references public.routes(id),
  shift text not null check (shift in ('morning', 'afternoon', 'night')),
  starts_on date not null,
  ends_on date,
  created_at timestamptz not null default now()
);

create table if not exists public.shift_change_requests (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references public.user_profiles(id) on delete cascade,
  requested_shift text not null check (requested_shift in ('morning', 'afternoon', 'night')),
  reason text not null,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now()
);

create table if not exists public.wait_requests (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.user_profiles(id) on delete cascade,
  trip_id uuid not null references public.trips(id) on delete cascade,
  reason text not null,
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'rejected', 'completed')),
  created_at timestamptz not null default now()
);

create table if not exists public.lost_found_items (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.user_profiles(id) on delete cascade,
  item_type text not null check (item_type in ('lost', 'found')),
  description text not null,
  bus_label text not null,
  photo_path text not null,
  status text not null default 'open'
    check (status in ('open', 'resolved')),
  created_at timestamptz not null default now()
);

create table if not exists public.vehicle_locations (
  bus_id uuid primary key references public.buses(id) on delete cascade,
  driver_id uuid not null references public.user_profiles(id) on delete cascade,
  trip_id uuid references public.trips(id) on delete set null,
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  heading double precision,
  recorded_at timestamptz not null default now()
);

alter table public.user_profiles enable row level security;
alter table public.buses enable row level security;
alter table public.routes enable row level security;
alter table public.trips enable row level security;
alter table public.driver_shifts enable row level security;
alter table public.shift_change_requests enable row level security;
alter table public.wait_requests enable row level security;
alter table public.lost_found_items enable row level security;
alter table public.vehicle_locations enable row level security;

revoke all on public.user_profiles from anon, authenticated;
grant select on public.user_profiles to authenticated;
grant update (display_name) on public.user_profiles to authenticated;

create policy "profiles are visible to their owner and admins"
  on public.user_profiles for select to authenticated
  using (id = auth.uid() or public.is_busflow_admin());
create policy "users can update their display name"
  on public.user_profiles for update to authenticated
  using (id = auth.uid() or public.is_busflow_admin())
  with check (id = auth.uid() or public.is_busflow_admin());

grant select, insert, update, delete on public.buses to authenticated;
create policy "authenticated users can view buses"
  on public.buses for select to authenticated using (true);
create policy "admins manage buses"
  on public.buses for all to authenticated
  using (public.is_busflow_admin()) with check (public.is_busflow_admin());

grant select, insert, update, delete on public.routes to authenticated;
create policy "authenticated users can view active routes"
  on public.routes for select to authenticated using (active or public.is_busflow_admin());
create policy "admins manage routes"
  on public.routes for all to authenticated
  using (public.is_busflow_admin()) with check (public.is_busflow_admin());

grant select, insert, update, delete on public.trips to authenticated;
create policy "users can view relevant trips"
  on public.trips for select to authenticated
  using (true);
create policy "admins manage trips"
  on public.trips for all to authenticated
  using (public.is_busflow_admin()) with check (public.is_busflow_admin());

grant select, insert, update, delete on public.driver_shifts to authenticated;
create policy "drivers and admins view shifts"
  on public.driver_shifts for select to authenticated
  using (driver_id = auth.uid() or public.is_busflow_admin());
create policy "admins manage shifts"
  on public.driver_shifts for all to authenticated
  using (public.is_busflow_admin()) with check (public.is_busflow_admin());

grant select, insert, update, delete on public.shift_change_requests to authenticated;
create policy "drivers view and request own shift changes"
  on public.shift_change_requests for select to authenticated
  using (driver_id = auth.uid() or public.is_busflow_admin());
create policy "drivers create own shift requests"
  on public.shift_change_requests for insert to authenticated
  with check (driver_id = auth.uid() and public.is_busflow_driver());
create policy "admins process shift requests"
  on public.shift_change_requests for update to authenticated
  using (public.is_busflow_admin()) with check (public.is_busflow_admin());

grant select, insert, update on public.wait_requests to authenticated;
create policy "students and assigned drivers view wait requests"
  on public.wait_requests for select to authenticated
  using (
    student_id = auth.uid()
    or public.is_busflow_admin()
    or exists (
      select 1 from public.trips t
      where t.id = wait_requests.trip_id and t.driver_id = auth.uid()
    )
  );
create policy "students request a wait"
  on public.wait_requests for insert to authenticated
  with check (
    student_id = auth.uid()
    and public.current_profile_role() = 'student'
  );
create policy "assigned drivers and admins update wait requests"
  on public.wait_requests for update to authenticated
  using (
    public.is_busflow_admin()
    or exists (
      select 1 from public.trips t
      where t.id = wait_requests.trip_id and t.driver_id = auth.uid()
    )
  )
  with check (
    public.is_busflow_admin()
    or exists (
      select 1 from public.trips t
      where t.id = wait_requests.trip_id and t.driver_id = auth.uid()
    )
  );

grant select, insert, update, delete on public.lost_found_items to authenticated;
create policy "authenticated users view lost and found items"
  on public.lost_found_items for select to authenticated using (true);
create policy "authenticated users create own lost and found items"
  on public.lost_found_items for insert to authenticated
  with check (owner_id = auth.uid());
create policy "owners and admins manage lost and found items"
  on public.lost_found_items for update to authenticated
  using (owner_id = auth.uid() or public.is_busflow_admin())
  with check (owner_id = auth.uid() or public.is_busflow_admin());
create policy "owners and admins delete lost and found items"
  on public.lost_found_items for delete to authenticated
  using (owner_id = auth.uid() or public.is_busflow_admin());

grant select, insert, update on public.vehicle_locations to authenticated;
create policy "authenticated users view vehicle locations"
  on public.vehicle_locations for select to authenticated using (true);
create policy "drivers publish their assigned vehicle location"
  on public.vehicle_locations for insert to authenticated
  with check (
    driver_id = auth.uid()
    and public.is_busflow_driver()
    and exists (
      select 1 from public.trips t
      where t.id = vehicle_locations.trip_id
        and t.driver_id = auth.uid()
        and t.bus_id = vehicle_locations.bus_id
        and t.status = 'in_progress'
    )
  );
create policy "drivers update their assigned vehicle location"
  on public.vehicle_locations for update to authenticated
  using (driver_id = auth.uid() and public.is_busflow_driver())
  with check (
    driver_id = auth.uid()
    and public.is_busflow_driver()
    and exists (
      select 1 from public.trips t
      where t.id = vehicle_locations.trip_id
        and t.driver_id = auth.uid()
        and t.bus_id = vehicle_locations.bus_id
        and t.status = 'in_progress'
    )
  );

create index if not exists trips_driver_status_idx
  on public.trips (driver_id, status, starts_at);
create index if not exists wait_requests_trip_status_idx
  on public.wait_requests (trip_id, status, created_at);
create index if not exists lost_found_items_status_created_idx
  on public.lost_found_items (status, created_at desc);
