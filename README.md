# BusFlow

Aplicativo Flutter para gestão de transporte universitário, com perfis de aluno, motorista e administrador.

## Executar

```bash
flutter pub get
flutter run
```

Para executar no navegador:

```bash
flutter run -d chrome
```

## Supabase e contas entre dispositivos

Sem `SUPABASE_URL` e `SUPABASE_ANON_KEY`, o aplicativo fica em modo local e cada instalação mantém contas separadas. Não há projeto Supabase configurado neste repositório, portanto a conexão remota só fica ativa depois de fornecer as chaves públicas do seu projeto e aplicar as migrações.

1. No Supabase, habilite autenticação por e-mail e aplique todas as migrações do diretório `supabase/migrations`:

   ```bash
   supabase link --project-ref SEU_PROJECT_REF
   supabase db push
   ```

2. Execute o app ou gere o APK passando a URL e a chave **publishable/anon**:

   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://SEU_PROJECT_REF.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_PUBLICA
   ```

   ```bash
   flutter build apk --release \
     --dart-define=SUPABASE_URL=https://SEU_PROJECT_REF.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_PUBLICA
   ```

3. Use esse APK/configuração para todos os aparelhos. As contas e os dados básicos de perfil são gravados no Supabase; o login usa Supabase Auth e a sessão fica persistida no dispositivo. Nunca distribua `service_role`, chaves Resend ou outros segredos do servidor no app.

Alunos podem entrar após o cadastro e, se a confirmação de e-mail estiver habilitada, depois de confirmarem o endereço. Motoristas e administradores ficam pendentes de aprovação: um operador autorizado deve aprovar o perfil e atribuir o papel `driver` ou `admin` no banco. O valor informado pelo app é apenas uma solicitação e não concede privilégios. Para a primeira conta de administrador, use o painel seguro do Supabase para aprovar o perfil e preencher também a coluna `role`; as operações de gestão não devem aceitar a própria solicitação para obter privilégios. As solicitações de recuperação também precisam das migrações e da Edge Function indicadas abaixo.

## Recuperação de senha por e-mail

O fluxo de recuperação usa uma Supabase Edge Function e a API de e-mail Resend. O código tem 6 dígitos, expira em 15 minutos, é único entre códigos ativos e permite no máximo cinco tentativas de confirmação. Há um intervalo de 60 segundos entre solicitações para o mesmo e-mail e um limite por origem de rede.

Para habilitar o envio:

1. Crie um projeto Supabase e uma conta Resend; configure e verifique um domínio de envio no Resend.
2. Vincule o projeto Supabase e aplique a migração:

   ```bash
   supabase link --project-ref SEU_PROJECT_REF
   supabase db push
   ```

3. Configure os segredos da função no Supabase. Gere um `CODE_HASH_SECRET` aleatório e mantenha todos os segredos somente no servidor:

   ```bash
   supabase secrets set \
     CODE_HASH_SECRET="VALOR_ALEATORIO_COM_PELO_MENOS_32_BYTES" \
     RESEND_API_KEY="SUA_CHAVE_RESEND" \
     RESEND_FROM_EMAIL="BusFlow <no-reply@seu-dominio-verificado.com>"
   ```

   O Supabase fornece `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` ao ambiente da Edge Function. Nunca coloque a service-role key, a chave Resend ou `CODE_HASH_SECRET` no app.

4. Publique a função:

   ```bash
   supabase functions deploy password-recovery
   ```

5. Execute o app com a URL e a chave pública (anon/publishable) do projeto:

   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://SEU_PROJECT_REF.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_ANON_PUBLICA
   ```

   Para o APK:

   ```bash
   flutter build apk --release \
     --dart-define=SUPABASE_URL=https://SEU_PROJECT_REF.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_ANON_PUBLICA
   ```

Com Supabase configurado e as migrações atualizadas, a senha é redefinida na conta Supabase Auth e vale nos dispositivos. No modo local, as credenciais ficam apenas no aparelho e não podem ser recuperadas de outro dispositivo.

## Câmera, fotos e QR

Os cadastros e dados pessoais permitem escolher uma foto da galeria ou tirar uma foto. A foto permanece local ao aparelho. Com Supabase, os dados básicos da conta e o identificador QR individual do aluno são persistidos remotamente.

## Recursos implementados e sincronização

O app inclui tema escuro, configurações de segurança com autenticação biométrica do sistema, solicitação local de espera, calendário de rotas, achados e perdidos com foto, localização do aparelho no mapa e geração/compartilhamento/impressão do relatório PDF. O usuário pode ativar a biometria no cadastro ou em Perfil → Segurança. O aparelho solicita a autenticação local; o app não cadastra, lê nem envia a impressão digital. Com uma sessão Supabase ativa, a biometria protege o acesso ao app naquele aparelho.

Pedidos de espera, achados e perdidos, fotos de perfil, escalas e posição de ônibus ainda não estão sincronizados entre aparelhos; algumas telas continuam com horários e frota demonstrativos. A posição GPS do aluno é real no aparelho. Não use esses módulos como comunicação operacional até completar a integração de dados e notificações em tempo real.

A migração `supabase/migrations/202611110001_shared_mobility.sql` prepara tabelas e políticas RLS para dados de mobilidade; `202611120001_profiles_and_auth.sql` adiciona dados de perfil e suporte à redefinição de senha centralizada.

## Validar

```bash
flutter analyze
flutter test
```
