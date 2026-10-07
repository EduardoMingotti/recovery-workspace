# Recovery Workspace

PWA pessoal para importar listas do HubSpot, trabalhar uma cadência em Kanban e gerar relatório executivo em formato de lista.

## 1. Criar o banco

1. Crie um projeto no Supabase.
2. Abra **SQL Editor**.
3. Execute todo o arquivo `supabase.sql`.

## 2. Proteger o acesso

No Supabase:

1. Vá em **Authentication > Providers > Email**.
2. Mantenha **Email** habilitado.
3. Desative novos cadastros públicos, usando a opção de permitir cadastro apenas por convite ou desabilitando signups.
4. Crie ou convide somente o seu usuário.
5. Não coloque `service_role` nem chave secreta no app.
6. Use somente a chave `sb_publishable_...`.
7. Mantenha o RLS do SQL ativo.

O SQL remove privilégios do papel anônimo e restringe cada registro ao `user_id` autenticado.

## 3. Obter a URL e a chave

No projeto Supabase, abra **Connect**. Copie:

- **Project URL**, no formato `https://SEU-PROJETO.supabase.co`
- **Publishable key**, no formato `sb_publishable_...`

Na primeira abertura do app, cole esses dois valores. Eles ficam salvos no navegador.

## 4. Publicar no GitHub Pages

1. Crie um repositório no GitHub.
2. Envie o conteúdo desta pasta para a raiz do repositório.
3. Abra **Settings > Pages**.
4. Em **Build and deployment**, escolha **Deploy from a branch**.
5. Selecione `main` e `/ (root)` e salve.

A rota publicada normalmente será exibida pelo próprio GitHub na página **Settings > Pages**.

## 5. Configurar a rota no Supabase

No Supabase, abra **Authentication > URL Configuration**:

- **Site URL**: cole a URL final do GitHub Pages.
- **Redirect URLs**: adicione a mesma URL, de preferência exatamente como publicada, incluindo a barra final quando houver.

O app atual usa login por e-mail e senha, mas essa configuração também deixa confirmações e recuperações de senha apontadas para a página correta.

## 6. Importar CSV

Clique em **Importar CSV** e associe as colunas. O único campo obrigatório é Clínica/Lead. Registros novos entram em **Não iniciado**.

## 7. Gerar PDF

Clique em **Relatório**, informe o período e abra o relatório. Na nova aba, clique em **Salvar como PDF** e selecione a impressora PDF do navegador.

## Segurança essencial

- A chave publicável pode estar no navegador; ela não substitui login e RLS.
- A chave secreta nunca deve ser publicada.
- Desative cadastro público se somente você deve entrar.
- Não remova RLS nem as políticas por `user_id`.
- Para dados corporativos, valide a hospedagem e o uso do Supabase com a governança da empresa antes de inserir informações reais.
