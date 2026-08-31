# UserFlow — Sistema de Usuários

Sistema web de autenticação e gerenciamento de usuários usando Supabase.

## Recursos

- Cadastro com nome, e-mail e senha
- Login e logout
- Recuperação de senha por e-mail
- Sessão persistente
- Perfil com nome e telefone
- Alteração de senha
- Controle de acesso por função (`user` / `admin`)
- Painel administrativo com listagem de perfis
- Row Level Security (RLS) no banco
- Interface responsiva

## Configuração do Supabase

1. Abra o SQL Editor do seu projeto Supabase.
2. Execute todo o arquivo `supabase/schema.sql`.
3. Em Authentication > URL Configuration, adicione a URL onde o site será publicado como Site URL/Redirect URL.
4. Publique os arquivos estáticos deste repositório (por exemplo, GitHub Pages).
5. Crie uma conta pelo próprio sistema.
6. Para transformar essa conta em administrador, copie o UUID do usuário e execute no SQL Editor:

```sql
update public.profiles
set role = 'admin'
where id = 'UUID_DO_USUARIO';
```

## Segurança

A aplicação usa somente a chave pública/publishable no navegador. **Nunca coloque uma secret/service-role key em `app.js`, HTML, CSS ou em qualquer arquivo público do repositório.** Se uma secret key foi compartilhada fora do ambiente seguro, ela deve ser rotacionada no painel do Supabase.

## Estrutura

```text
.
├── index.html
├── app.js
├── styles.css
├── supabase/
│   └── schema.sql
└── README.md
```
