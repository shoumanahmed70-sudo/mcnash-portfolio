-- Run once in the Supabase SQL editor.
create table public.admins(user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.admins enable row level security;
create policy "Read own admin membership" on public.admins for select to authenticated using(user_id=auth.uid());
create function public.is_portfolio_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.admins where user_id=auth.uid()) $$;
revoke all on function public.is_portfolio_admin() from public;
grant execute on function public.is_portfolio_admin() to anon,authenticated;
create table public.settings(id integer primary key check(id=1),intro text not null,bio text not null,portrait text not null default '');
create table public.works(id uuid primary key default gen_random_uuid(),title text not null,category text not null,kind text not null check(kind in ('image','video')),url text not null,cover_url text not null,created_at timestamptz not null default now());
alter table public.settings enable row level security;
alter table public.works enable row level security;
create policy "Public settings" on public.settings for select to anon,authenticated using(true);
create policy "Admin settings" on public.settings for all to authenticated using(public.is_portfolio_admin()) with check(public.is_portfolio_admin());
create policy "Public works" on public.works for select to anon,authenticated using(true);
create policy "Admin works" on public.works for all to authenticated using(public.is_portfolio_admin()) with check(public.is_portfolio_admin());
grant select on public.settings,public.works to anon,authenticated;
grant insert,update,delete on public.settings,public.works to authenticated;
grant select on public.admins to authenticated;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('portfolio','portfolio',true,41943040,array['image/jpeg','image/png','image/webp','video/mp4']);
create policy "Admin upload" on storage.objects for insert to authenticated with check(bucket_id='portfolio' and public.is_portfolio_admin());
create policy "Admin delete" on storage.objects for delete to authenticated using(bucket_id='portfolio' and public.is_portfolio_admin());
-- After creating your user in Authentication > Users, run separately:
-- insert into public.admins(user_id) values ('YOUR-USER-UUID');
