-- Run once in the SQL Editor of a new Supabase project.
create table public."Users" (
  id bigint generated always as identity primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  username text not null check (length(trim(username)) > 0),
  password text not null check (password ~ '^[0-9a-f]{64}$')
);

alter table public."Users" enable row level security;
grant select, insert on public."Users" to authenticated;
grant usage, select on sequence public."Users_id_seq" to authenticated;

create policy "Read own demo records" on public."Users"
  for select to authenticated using ((select auth.uid()) = owner_id);
create policy "Insert own demo records" on public."Users"
  for insert to authenticated with check ((select auth.uid()) = owner_id);

alter publication supabase_realtime add table public."Users";
