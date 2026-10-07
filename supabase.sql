-- Recovery Workspace - banco completo
-- Execute no SQL Editor de um projeto Supabase novo.

create extension if not exists pgcrypto;

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  clinica text not null check (length(trim(clinica)) > 0),
  origem text not null default 'Outra',
  link_crm text,
  etapa text not null default 'Não iniciado' check (etapa in ('Não iniciado','Dia 1','Dia 2','Dia 3','Dia 4','Conectado','Ganho','Perdido')),
  resultado text,
  valor_recuperado numeric(14,2) not null default 0 check (valor_recuperado >= 0),
  ultima_atividade date,
  trabalhado_em date,
  conectado boolean not null default false,
  observacoes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.acoes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  lead_id uuid not null references public.leads(id) on delete cascade,
  data_acao date not null default current_date,
  tipo text not null check (tipo in ('Ligação','WhatsApp','E-mail','Reunião','Outro')),
  descricao text not null check (length(trim(descricao)) > 0),
  created_at timestamptz not null default now()
);

create index if not exists leads_user_etapa_idx on public.leads(user_id, etapa);
create index if not exists leads_user_ultima_atividade_idx on public.leads(user_id, ultima_atividade);
create index if not exists acoes_user_lead_idx on public.acoes(user_id, lead_id);

create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists trg_leads_updated_at on public.leads;
create trigger trg_leads_updated_at before update on public.leads
for each row execute function public.set_updated_at();

-- Segurança: ninguém anônimo recebe privilégios de dados.
revoke all on table public.leads from anon;
revoke all on table public.acoes from anon;

-- O usuário autenticado recebe operações; o RLS restringe cada linha ao dono.
grant select, insert, update, delete on table public.leads to authenticated;
grant select, insert, update, delete on table public.acoes to authenticated;

alter table public.leads enable row level security;
alter table public.acoes enable row level security;
alter table public.leads force row level security;
alter table public.acoes force row level security;

drop policy if exists leads_select_own on public.leads;
drop policy if exists leads_insert_own on public.leads;
drop policy if exists leads_update_own on public.leads;
drop policy if exists leads_delete_own on public.leads;
create policy leads_select_own on public.leads for select to authenticated using ((select auth.uid()) = user_id);
create policy leads_insert_own on public.leads for insert to authenticated with check ((select auth.uid()) = user_id);
create policy leads_update_own on public.leads for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy leads_delete_own on public.leads for delete to authenticated using ((select auth.uid()) = user_id);

drop policy if exists acoes_select_own on public.acoes;
drop policy if exists acoes_insert_own on public.acoes;
drop policy if exists acoes_update_own on public.acoes;
drop policy if exists acoes_delete_own on public.acoes;
create policy acoes_select_own on public.acoes for select to authenticated using ((select auth.uid()) = user_id);
create policy acoes_insert_own on public.acoes for insert to authenticated
with check ((select auth.uid()) = user_id and exists (select 1 from public.leads l where l.id = lead_id and l.user_id = (select auth.uid())));
create policy acoes_update_own on public.acoes for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy acoes_delete_own on public.acoes for delete to authenticated using ((select auth.uid()) = user_id);

-- Auditoria simples para confirmar que o RLS está ativo.
select schemaname, tablename, rowsecurity
from pg_tables
where schemaname = 'public' and tablename in ('leads','acoes')
order by tablename;
