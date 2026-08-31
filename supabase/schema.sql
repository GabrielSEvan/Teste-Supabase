create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  phone text,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;

drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin" on public.profiles for select using (id=auth.uid() or public.is_admin());
drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles for insert with check (id=auth.uid() and role='user');
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update using (id=auth.uid()) with check (id=auth.uid() and (role='user' or public.is_admin()));

grant select, insert, update on public.profiles to authenticated;

-- Após criar uma conta, o app cria automaticamente o perfil.
-- Para promover um usuário a administrador, execute no SQL Editor:
-- update public.profiles set role='admin' where id='UUID_DO_USUARIO';
