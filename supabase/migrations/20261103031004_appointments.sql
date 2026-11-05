create type public.appointment_status as enum ('Scheduled', 'Checked In', 'In Progress', 'Completed', 'Cancelled', 'No Show');

create table public.appointments (
    id  uuid primary key default gen_random_uuid(),
    clinic_id   uuid not null references public.clinics(id) on delete cascade,
    pet_id  uuid not null references public.pets(id) on delete cascade,
    vet_id  uuid references public.staff(id) on delete set null,
    scheduled_at    timestamptz not null,
    reason  text,
    status  public.appointment_status not null default 'Scheduled',
    pims_id text,
    created_at  timestamptz not null default now(),
    unique  (clinic_id, pims_id)
);

create index appointments_clinic_scheduled_idx on public.appointments (clinic_id, scheduled_at);
create index appointments_pet_id_idx on public.appointments (pet_id);
create index appointments_vet_id_idx on public.appointments (vet_id);