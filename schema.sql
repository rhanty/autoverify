-- AutoVerify – databázová schéma pre Supabase (SQL Editor -> Run)
create table public.records (
  id           bigint generated always as identity primary key,
  vin          text    not null check (vin ~ '^[A-HJ-NPR-Z0-9]{17}$'),
  km           integer not null check (km between 0 and 3000000),
  description  text    not null check (char_length(description) between 3 and 1000),
  service_date date    not null default current_date,   -- dátum sa dopĺňa automaticky na serveri
  created_at   timestamptz not null default now()
);
create index records_vin_idx on public.records (vin);

-- Tabuľka je zamknutá: priamy prístup cez verejný kľúč nie je možný (zabráni stiahnutiu všetkých VIN).
alter table public.records enable row level security;

create or replace function public.add_record(p_vin text, p_km int, p_text text)
returns json language plpgsql security definer set search_path = public as $$
declare n int;
begin
  p_vin := upper(trim(p_vin));
  insert into records (vin, km, description) values (p_vin, p_km, trim(p_text));
  select count(*) into n from records where vin = p_vin;
  return json_build_object('count', n, 'date', current_date);
end $$;

create or replace function public.get_history(p_vin text)
returns table (service_date date, km int, description text)
language sql security definer set search_path = public stable as $$
  select r.service_date, r.km, r.description
  from records r where r.vin = upper(trim(p_vin))
  order by r.service_date, r.km;
$$;

revoke all on function public.add_record(text,int,text) from public;
revoke all on function public.get_history(text) from public;
grant execute on function public.add_record(text,int,text) to anon;
grant execute on function public.get_history(text) to anon;
