-- Status of recording in the pipeline
create type public.recording_status as enum ('Uploading', 'Uploaded', 'Transcribing', 'Transcribed', 'Failed');

-- Audio captured during an appointment
create table public.recordings (
    id                      uuid primary key default gen_random_uuid(),
    clinic_id               uuid not null references public.appointments(id),
    appointment_id          uuid not null references public.appointments(id),
    recorded_by             uuid references public.staff(id) on delete set null,
    storage_path            text not null unique,
    duration_seconds        integer check (duration_seconds >= 0),
    status                  public.recording_status not null default now()
);

create index recordings_appointments_id_idx on public.recordings (appointment_id);

create type public.note_status as enum ('Draft', 'Signed');

create table public.notes (
    id                      uuid primary key default gen_random_uuid(),
    clinic_id               uuid not null references public.clinics(id) on delete cascade,
    appointment_id          uuid not null references public.appointments(id) on delete cascade,
    recording_id            uuid references public.recordings(id) on delete set null, 
    author_id               uuid references public.staff(id) on delete set null, 
    subjective              text,
    objective               text, 
    assessment              text,
    plan                    text,
    status                  public.note_status not null default 'Draft',
    signed_by               uuid references public.staff(id) on delete set null,
    singed_at               timestamptz,
    created_at              timestamptz not null default now(),
    updated_at              timestamptz not null default now(),

    check (status = 'Draft' or (signed_by is not null and signed_at is not null))
);

create index notes_appointment_id_idx on public.notes (appointment_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create trigger notes_set_updated_at
    before update on public.notes
    for each row execute function public.set_updated_at();