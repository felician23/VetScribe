-- Clinics Each practice that uses the app
create table public.clinics (
    id  uuid primary key default gen_random_uuid(),
    name    text not null,
    phone   text not null,
    address text not null,
    timezone text not null default 'America/Chicago',
    pims_name text,
    created_at timestamptz not null default now()
);
-- Staff utilizing the app
create type public.staff_role as enum ('Vet','Vet Tech', 'CSR', 'Admin');

-- Staff: Users each belonging to one clinic
create table public.staff (
    id  uuid primary key default gen_random_uuid(),
    clinic_id   uuid not null references public.clinics(id) on delete cascade,
    user_id uuid    unique references auth.users(id) on delete set null,
    full_name   text not null,
    display_name    text not null,
    role    public.staff_role not null default 'Vet',
    email   text,
    is_active   boolean not null default true,
    created_at  timestamptz not null default now()
);

--Index to speed up searching for everyone at the clinic
create index staff_clinic_id_idx on public.staff (clinic_id);