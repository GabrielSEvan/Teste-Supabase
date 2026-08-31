create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  phone text,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;
drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin" on public.profiles for select using (id=auth.uid() or public.is_admin());
drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles for insert with check (id=auth.uid() and role='user');
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update using (id=auth.uid()) with check (id=auth.uid() and (role='user' or public.is_admin()));
grant select, insert, update on public.profiles to authenticated;

create table if not exists public.pets (
  id text primary key,
  name text not null,
  species text not null check (species in ('Cachorro','Gato','Outro')),
  breed text,
  sex text,
  age text,
  size text,
  city text,
  state text,
  organization text,
  image_url text,
  adoption_url text,
  source_url text not null,
  source text not null default 'ILY',
  available boolean not null default true,
  synced_at timestamptz not null default now()
);

alter table public.pets enable row level security;
drop policy if exists "pets_public_read" on public.pets;
create policy "pets_public_read" on public.pets for select using (available = true);
grant select on public.pets to anon, authenticated;

insert into public.pets (id,name,species,breed,sex,age,size,city,state,organization,image_url,adoption_url,source_url) values
('ily-o-projeto-chico-princesa','Princesa','Gato','SRD (Vira-lata)','Fêmea','10 anos','Pequeno','Belo Horizonte','MG','O Projeto CHICO',null,'https://ily.pet/ongs/o-projeto-chico','https://ily.pet/ongs/o-projeto-chico'),
('ily-o-projeto-chico-meimei','Meimei','Gato','SRD (Vira-lata)','Fêmea','2 anos','Pequeno','Belo Horizonte','MG','O Projeto CHICO',null,'https://ily.pet/ongs/o-projeto-chico','https://ily.pet/ongs/o-projeto-chico'),
('ily-o-projeto-chico-mirna','Mirna','Gato','SRD (Vira-lata)','Fêmea','4 anos','Pequeno','Belo Horizonte','MG','O Projeto CHICO',null,'https://ily.pet/ongs/o-projeto-chico','https://ily.pet/ongs/o-projeto-chico'),
('ily-projeto-amora-dara','Dara','Cachorro','SRD (Vira-lata)','Fêmea','3 anos e 7 meses','Médio','Juquitiba','SP','Projeto Amora',null,'https://ily.pet/ongs/amora','https://ily.pet/ongs/amora'),
('ily-projeto-amora-ebony','Ebony','Cachorro','SRD (Vira-lata)','Fêmea','1 ano e 7 meses','Médio','Juquitiba','SP','Projeto Amora',null,'https://ily.pet/ongs/amora','https://ily.pet/ongs/amora'),
('ily-projeto-amora-belchior','Belchior','Gato','SRD (Vira-lata)','Macho','2 anos e 7 meses','Pequeno','Juquitiba','SP','Projeto Amora',null,'https://ily.pet/ongs/amora','https://ily.pet/ongs/amora')
on conflict (id) do update set available=excluded.available, synced_at=now();

-- Para sincronização automática em produção, habilite o catálogo/API do ILY para o domínio da aplicação.
