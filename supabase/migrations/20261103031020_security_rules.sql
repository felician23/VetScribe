create or replace function public.current_clinic_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
        select clinic_id from public.staff
        where user_id = (select auth.uid()) and is_active
$$;

create or replace function public.is_clinic_admin()
returns boolean
language sql
stable 
security definer
set search_path = ''
as $$
        select exists (
            select 1 from public.staff
            where user_id = (select auth.uid()) and is_active and role = 'Admin'
        )
$$;

alter table public.clinics      enable row level security;
alter table public.staff        enable row level security;
alter table public.owners       enable row level security;
alter table public.pets         enable row level security;
alter table public.appointments enable row level security;
alter table public.recordings   enable row level security;
alter table public.notes        enable row level security;

-- Clinics
create policy "clinic members can view their clinic" on public.clinics for select to authenticated using (id = public.current_clinic_id());
create policy "admins can update their clinic" on public.clinics for update to authenticated using (id = public.current_clinic_id() and public.is_clinic_admin());

-- Staff
create policy "staff can view coworkers" on public.staff for select to authenticated using ()
