import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:busflow/screens/admin/admin_home_screen.dart';
import 'package:busflow/screens/admin/admin_main_screen.dart';
import 'package:busflow/screens/admin/admin_perfil_screen.dart';
import 'package:busflow/screens/dados_pessoais_screen.dart';
import 'package:busflow/screens/aluno/aluno_main_screen.dart';
import 'package:busflow/screens/aluno/carteirinha_screen.dart';
import 'package:busflow/screens/aluno/conta_aluno_screen.dart';
import 'package:busflow/screens/aluno/mapa_screen.dart';
import 'package:busflow/screens/aluno/notificacoes_screen.dart';
import 'package:busflow/screens/aluno/trips_screen.dart';
import 'package:busflow/screens/login_screen.dart';
import 'package:busflow/screens/password_recovery_screen.dart';
import 'package:busflow/screens/profile_selection_screen.dart';
import 'package:busflow/screens/registration/admin_registration_screen.dart';
import 'package:busflow/screens/registration/aluno_registration_screen.dart';
import 'package:busflow/screens/registration/motorista_registration_screen.dart';
import 'package:busflow/services/notification_store.dart';
import 'package:busflow/services/account_profile.dart';
import 'package:busflow/services/reservation_store.dart';
import 'package:busflow/services/student_storage.dart';

void main() {
  void setBigScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    ReservationStore.instance.reset();
    addTearDown(ReservationStore.instance.reset);
    NotificationStore.instance.reset();
    addTearDown(NotificationStore.instance.reset);
  }

  testWidgets('Tela de login renderiza corretamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Acesse o BusFlow.'), findsOneWidget);
    expect(find.text('Entrar no Aplicativo'), findsOneWidget);
    expect(find.text('E-mail ou CPF'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('PASSAPORTE ATIVO'), findsNothing);
    expect(find.text('Voltar'), findsNothing);
  });

  testWidgets('Tela de escolha de perfil renderiza corretamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileSelectionScreen()));

    expect(find.text('Escolha De Perfil'), findsOneWidget);
    expect(find.text('Selecione o seu perfil'), findsOneWidget);
    expect(
      find.textContaining('Passo 1 de 3', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Aluno Universitário'), findsOneWidget);
    expect(find.text('Motorista Operacional'), findsOneWidget);
    expect(find.text('Gestão Pública / ADM'), findsOneWidget);
    expect(find.text('Continuar Cadastro'), findsOneWidget);
  });

  testWidgets('Seleciona outro perfil ao tocar no card', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: ProfileSelectionScreen()));

    await tester.tap(find.text('Motorista Operacional'));
    await tester.pumpAndSettle();

    final motoristaCard = find.ancestor(
      of: find.text('Motorista Operacional'),
      matching: find.byType(AnimatedContainer),
    );
    expect(
      find.descendant(of: motoristaCard, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });

  testWidgets('Cadastro de Aluno renderiza corretamente', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AlunoRegistrationScreen()));

    expect(find.text('Cadastro De Aluno'), findsOneWidget);
    expect(find.text('Passe Estudantil Ativo'), findsOneWidget);
    expect(find.text('Dados Acadêmicos'), findsOneWidget);
    expect(find.text('Segurança de Acesso'), findsOneWidget);
    expect(find.text('Turno de Aulas Habitual'), findsOneWidget);
    expect(find.text('Cadastrar Aluno'), findsOneWidget);
  });

  testWidgets('Cadastro de Motorista renderiza corretamente', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(
      const MaterialApp(home: MotoristaRegistrationScreen()),
    );

    expect(find.text('Cadastro De Motorista'), findsOneWidget);
    expect(find.text('CADASTRO OPERACIONAL'), findsOneWidget);
    expect(find.text('Registro da CNH'), findsOneWidget);
    expect(find.text('Turno de Operação Principal'), findsOneWidget);
    expect(
      find.text('Validação de Segurança e Trafegabilidade'),
      findsOneWidget,
    );
    expect(find.text('Cadastrar Motorista'), findsOneWidget);
  });

  testWidgets('Cadastro de Administrador renderiza corretamente', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AdminRegistrationScreen()));

    expect(find.text('Cadastro De Administrador'), findsOneWidget);
    expect(find.text('Cadastro Institucional ADM'), findsOneWidget);
    expect(find.text('Dados do Gestor'), findsOneWidget);
    expect(find.text('Vínculo Municipal e Autorização'), findsOneWidget);
    expect(find.text('Credenciais de Autenticação Segura'), findsOneWidget);
    expect(find.text('Cadastrar Administrador'), findsOneWidget);
  });

  testWidgets('Fluxo login -> escolha de perfil -> cadastro aluno', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.text('Criar Conta'));
    await tester.pumpAndSettle();

    expect(find.text('Selecione o seu perfil'), findsOneWidget);

    await tester.tap(find.text('Continuar Cadastro'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastro De Aluno'), findsOneWidget);
  });

  testWidgets('Cadastro de aluno salva e entra na tela inicial', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 5200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: AlunoRegistrationScreen()));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Ana Beatriz Silva');
    await tester.enterText(fields.at(1), 'ana@universidade.edu.br');
    await tester.enterText(fields.at(2), '2024100849');
    await tester.enterText(fields.at(6), 'Senha@Forte123');
    await tester.enterText(fields.at(7), 'Senha@Forte123');

    await tester.tap(
      find.text('Concordo com os Termos de Transporte Universitário'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cadastrar Aluno'));
    await tester.pumpAndSettle();

    expect(find.byType(AlunoMainScreen), findsOneWidget);
    expect(
      find.text('Uma viagem mais segura começa no BusFlow.'),
      findsOneWidget,
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('aluno_registered'), true);
    expect(prefs.getString('aluno_nome'), 'Ana Beatriz Silva');
    expect(prefs.getString('aluno_email'), 'ana@universidade.edu.br');
    expect(prefs.getString('aluno_ra'), '2024100849');
  });

  testWidgets('Força da senha atualiza conforme o usuário digita', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AlunoRegistrationScreen()));

    final senha = find.byType(TextField).at(6);

    await tester.enterText(senha, 'abc');
    await tester.pumpAndSettle();
    expect(find.text('Fraca'), findsOneWidget);

    await tester.enterText(senha, 'Senha1234');
    await tester.pumpAndSettle();
    expect(find.text('Média'), findsOneWidget);

    await tester.enterText(senha, 'Senha@Forte123');
    await tester.pumpAndSettle();
    expect(find.text('Forte'), findsOneWidget);
  });

  testWidgets('Cadastro bloqueia senha fraca e confirmação divergente', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AlunoRegistrationScreen()));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Ana Beatriz Silva');
    await tester.enterText(fields.at(1), 'ana@universidade.edu.br');
    await tester.enterText(fields.at(6), '123');
    await tester.enterText(fields.at(7), '123');

    await tester.tap(
      find.text('Concordo com os Termos de Transporte Universitário'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cadastrar Aluno'));
    await tester.pumpAndSettle();
    expect(find.byType(AlunoMainScreen), findsNothing);
    expect(
      find.text('A senha precisa de pelo menos 8 caracteres.'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.enterText(fields.at(6), 'Senha@Forte123');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cadastrar Aluno'));
    await tester.pumpAndSettle();
    expect(find.byType(AlunoMainScreen), findsNothing);
    expect(find.text('As senhas digitadas não conferem.'), findsOneWidget);
  });

  testWidgets('Tela inicial do aluno renderiza corretamente', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AlunoMainScreen()));

    expect(find.text('Nenhuma viagem reservada'), findsOneWidget);
    expect(find.text('AÇÕES RÁPIDAS'), findsOneWidget);
    expect(find.text('Como funciona'), findsOneWidget);
    expect(find.text('MÉTRICAS DO PROGRAMA'), findsOneWidget);
  });

  testWidgets('Navega para a tela de viagens pela bottom nav', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AlunoMainScreen()));
    await tester.tap(find.text('Viagens'));
    await tester.pumpAndSettle();

    expect(find.byType(TripsScreen), findsOneWidget);
    expect(find.text('Rotas e Viagens'), findsOneWidget);
    expect(find.text('Próximas Partidas Noturnas'), findsOneWidget);
    expect(find.text('Nenhuma viagem reservada'), findsOneWidget);
    expect(find.text('Reservar Vaga'), findsWidgets);
  });

  testWidgets('Login sem conta cadastrada mostra aviso', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'aluno@universidade.edu.br');
    await tester.enterText(fields.at(1), 'senha123');

    await tester.tap(find.text('Entrar no Aplicativo'));
    await tester.pumpAndSettle();

    expect(
      find.text('Conta não encontrada. Crie sua conta para continuar.'),
      findsOneWidget,
    );
    expect(find.byType(AlunoMainScreen), findsNothing);
  });

  testWidgets('Login com cadastro salvo entra na tela do aluno', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'aluno_registered': true,
      'aluno_email': 'ana@universidade.edu.br',
      'aluno_senha': 'senha123',
    });
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'ana@universidade.edu.br');
    await tester.enterText(fields.at(1), 'senha123');

    await tester.tap(find.text('Entrar no Aplicativo'));
    await tester.pumpAndSettle();

    expect(find.byType(AlunoMainScreen), findsOneWidget);
    expect(
      find.text('Uma viagem mais segura começa no BusFlow.'),
      findsOneWidget,
    );
  });

  testWidgets('Login com senha incorreta mostra aviso', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'aluno_registered': true,
      'aluno_email': 'ana@universidade.edu.br',
      'aluno_senha': 'senha123',
    });
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'ana@universidade.edu.br');
    await tester.enterText(fields.at(1), 'outraSenha');

    await tester.tap(find.text('Entrar no Aplicativo'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Senha incorreta. Tente novamente'),
      findsOneWidget,
    );
    expect(find.byType(AlunoMainScreen), findsNothing);
  });

  testWidgets('Login com e-mail não cadastrado mostra aviso', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'aluno_registered': true,
      'aluno_email': 'ana@universidade.edu.br',
      'aluno_senha': 'senha123',
    });
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'outra@pessoa.edu.br');
    await tester.enterText(fields.at(1), 'senha123');

    await tester.tap(find.text('Entrar no Aplicativo'));
    await tester.pumpAndSettle();

    expect(
      find.text('Conta não encontrada. Crie sua conta para continuar.'),
      findsOneWidget,
    );
    expect(find.byType(AlunoMainScreen), findsNothing);
  });

  testWidgets('Abas e filtros da tela de viagens funcionam', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TripsScreen())),
    );

    await tester.tap(find.text('QUA'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manhã (07h-12h)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1.420 viagens validadas'), findsOneWidget);

    await tester.tap(find.text('Dias Úteis'));
    await tester.pumpAndSettle();

    expect(find.text('Próximas Partidas Noturnas'), findsOneWidget);
  });

  testWidgets('Calendário da tela de viagens mostra a semana corrente', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TripsScreen())),
    );

    for (final label in ['SEG', 'TER', 'QUA', 'QUI', 'SEX']) {
      expect(find.text(label), findsOneWidget);
    }

    final now = DateTime.now();
    final fimDeSemana = now.weekday >= DateTime.saturday;
    if (!fimDeSemana) {
      final hoje = now.day.toString().padLeft(2, '0');
      expect(find.text(hoje), findsOneWidget);
    }
  });

  testWidgets('Reservar e cancelar vaga atualizam o layout', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TripsScreen())),
    );

    expect(find.text('Nenhuma viagem reservada'), findsOneWidget);
    expect(find.text('VIAGEM AGENDADA • EM ROTA'), findsNothing);

    await tester.tap(find.text('Reservar Vaga').first);
    await tester.pumpAndSettle();

    expect(find.text('VIAGEM AGENDADA • EM ROTA'), findsOneWidget);
    expect(find.text('Cancelar Vaga'), findsOneWidget);
    expect(find.text('Cancelar Reserva'), findsOneWidget);
    expect(find.textContaining('Ocupação: 29 de 40'), findsOneWidget);

    await tester.tap(find.text('Cancelar Reserva'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma viagem reservada'), findsOneWidget);
    expect(find.text('VIAGEM AGENDADA • EM ROTA'), findsNothing);
    expect(find.text('Cancelar Vaga'), findsNothing);
    expect(find.textContaining('Ocupação: 28 de 40'), findsOneWidget);
  });

  testWidgets('Reserva na aba Viagens aparece na tela inicial', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AlunoMainScreen()));
    expect(find.text('Nenhuma viagem reservada'), findsOneWidget);

    await tester.tap(find.text('Viagens'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reservar Vaga').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Início').last);
    await tester.pumpAndSettle();

    expect(find.text('Embarque Confirmado'), findsOneWidget);
    expect(find.text('SEU PRÓXIMO TRAJETO'), findsOneWidget);
  });

  testWidgets('Carteirinha digital abre pela bottom nav', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AlunoMainScreen()));

    expect(find.byType(CarteirinhaScreen), findsNothing);

    await tester.tap(find.text('Carteirinha'));
    await tester.pumpAndSettle();

    expect(find.byType(CarteirinhaScreen), findsOneWidget);
    expect(find.text('CARTEIRINHA DIGITAL'), findsOneWidget);
    expect(
      find.text('Aproxime o QR Code do validador óptico ao embarcar'),
      findsOneWidget,
    );
    expect(find.text('ROTAS AUTORIZADAS'), findsOneWidget);
    expect(find.text('TOKEN: BF-9482-X8K1'), findsOneWidget);
    expect(find.text('ÚLTIMOS EMBARQUES'), findsOneWidget);

    await tester.tap(find.text('Bloqueada'));
    await tester.pumpAndSettle();

    expect(find.text('Credencial Bloqueada'), findsOneWidget);

    await tester.tap(find.text('Toque para testar'));
    await tester.pumpAndSettle();

    expect(find.text('Credencial Expirada'), findsOneWidget);
  });

  testWidgets('Tela de mapa mostra veículos e filtra por linha', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MapaScreen())),
    );

    expect(find.text('Mapa Ao Vivo'), findsOneWidget);
    expect(find.text('Veículos em Circulação'), findsOneWidget);
    expect(find.text('Radar GPS Ativo'), findsOneWidget);
    expect(find.text('Carlos Mendes'), findsOneWidget);
    expect(find.text('Marcos Souza'), findsOneWidget);
    expect(find.text('Roberto Lima'), findsOneWidget);
    expect(find.text('3 no raio de 1.2km'), findsOneWidget);

    await tester.tap(find.text('Linha 04 (Central)'));
    await tester.pumpAndSettle();

    expect(find.text('Carlos Mendes'), findsOneWidget);
    expect(find.text('Marcos Souza'), findsNothing);
    expect(find.text('1 no raio de 1.2km'), findsOneWidget);

    await tester.tap(find.text('Todas as Linhas'));
    await tester.pumpAndSettle();

    expect(find.text('Marcos Souza'), findsOneWidget);
    expect(find.text('3 no raio de 1.2km'), findsOneWidget);
  });

  testWidgets('Tela do aluno (Minha Conta) renderiza ações e solicitações', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    var historicoAberto = false;
    var carteirinhaAberta = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContaAlunoScreen(
            onOpenHistory: () => historicoAberto = true,
            onOpenCarteirinha: () => carteirinhaAberta = true,
          ),
        ),
      ),
    );

    expect(find.text('Minha Conta'), findsOneWidget);
    expect(find.text('Olá, Ana Costa!'), findsOneWidget);
    expect(find.text('LINHA UNIVERSITÁRIA #04'), findsOneWidget);
    expect(find.text('Campus → Centro'), findsOneWidget);
    expect(find.text('Ações do Estudante'), findsOneWidget);
    expect(find.text('Desistência de Vaga'), findsOneWidget);
    expect(find.text('Pedir Espera'), findsOneWidget);
    expect(find.text('Últimas Solicitações'), findsOneWidget);
    expect(find.text('Ausência Justificada'), findsOneWidget);
    expect(find.text('Em Atendimento'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.badge_outlined));
    await tester.pump();
    expect(carteirinhaAberta, isTrue);

    await tester.tap(find.text('Ver histórico de viagens'));
    await tester.pump();
    expect(historicoAberto, isTrue);

    await tester.tap(find.text('Pedir Espera'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Motivo da espera'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).first,
      'A aula terminou atrasada',
    );
    await tester.tap(find.text('Enviar pedido'));
    await tester.pumpAndSettle();
    expect(find.textContaining('depende da sincronização'), findsOneWidget);
  });

  testWidgets('Configurações da conta e logout voltam para o login', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'aluno_registered': true});
    setBigScreen(tester);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ContaAlunoScreen())),
    );

    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Dados Pessoais'), findsOneWidget);
    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Segurança'), findsOneWidget);
    expect(find.text('Ajuda e Suporte'), findsOneWidget);
    expect(find.text('Sobre o App'), findsOneWidget);
    expect(find.text('Sair da conta'), findsOneWidget);
    expect(find.text('Voltar para a tela de login'), findsOneWidget);

    final notificationSwitch = find.byKey(
      const ValueKey('config-notificacoes'),
    );
    await tester.ensureVisible(notificationSwitch);
    expect(tester.widget<Switch>(notificationSwitch).value, isTrue);

    await tester.tap(notificationSwitch);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(notificationSwitch).value, isFalse);
    expect(find.textContaining('Notificações desativadas'), findsOneWidget);

    await tester.ensureVisible(find.text('Sair da conta'));
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();

    expect(find.text('Sair da conta?'), findsOneWidget);
    expect(
      find.text(
        'Você voltará para a tela de login do BusFlow. '
        'Seus dados de passagem continuam salvos neste dispositivo.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(ContaAlunoScreen), findsOneWidget);

    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ContaAlunoScreen), findsNothing);
    expect(find.byType(AlunoMainScreen), findsNothing);
  });

  testWidgets('Máscaras de CPF/WhatsApp e instituições com sugestão', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AlunoRegistrationScreen()));

    final fields = find.byType(TextField);

    await tester.enterText(fields.at(3), '12345678901');
    await tester.pump();
    expect(find.text('123.456.789-01'), findsOneWidget);

    await tester.enterText(fields.at(4), '11912345678');
    await tester.pump();
    expect(find.text('(11) 91234-5678'), findsOneWidget);

    await tester.enterText(fields.at(4), '11');
    await tester.pump();
    expect(find.text('(11)'), findsOneWidget);

    await tester.enterText(fields.at(5), 'unicamp');
    await tester.pump();
    expect(
      find.text('Universidade Estadual de Campinas (UNICAMP)'),
      findsOneWidget,
    );

    await tester.enterText(fields.at(5), 'sao paulo');
    await tester.pump();
    expect(find.text('Universidade de São Paulo (USP)'), findsOneWidget);

    await tester.ensureVisible(find.text('Universidade de São Paulo (USP)'));
    await tester.tap(find.text('Universidade de São Paulo (USP)'));
    await tester.pump();

    expect(find.text('Universidade de São Paulo (USP)'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('Sino de notificações abre a lista e limpa o indicador', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AlunoMainScreen()));

    expect(find.byKey(const ValueKey('bell-dot')).first, findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bell-btn')).hitTestable());
    await tester.pumpAndSettle();

    // painel de notificações (popup) aparece
    expect(find.text('Embarque Confirmado'), findsOneWidget);
    expect(find.text('Ônibus em rota até você'), findsOneWidget);
    expect(find.text('Marcar todas como lidas'), findsOneWidget);

    // ir para a tela completa de notificações
    await tester.tap(find.byKey(const ValueKey('popup-ver-todas')));
    await tester.pumpAndSettle();

    expect(find.byType(NotificacoesScreen), findsOneWidget);
    expect(find.text('3 novas'), findsOneWidget);

    // voltar da tela de notificações
    await tester.tap(find.byKey(const ValueKey('notificacoes-voltar')));
    await tester.pumpAndSettle();

    expect(find.byType(NotificacoesScreen), findsNothing);
    expect(find.byKey(const ValueKey('bell-dot')), findsNothing);
  });

  testWidgets('Avatar abre o painel de configurações', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AlunoMainScreen()));

    expect(find.text('Dados Pessoais').hitTestable(), findsNothing);

    await tester.tap(find.byKey(const ValueKey('avatar-btn')).hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('Dados Pessoais').hitTestable(), findsOneWidget);
    expect(find.text('Sair da conta').hitTestable(), findsOneWidget);
    expect(find.text('Matrícula Ativa').hitTestable(), findsOneWidget);

    // alterna o switch dentro do painel
    await tester.tap(
      find.byKey(const ValueKey('config-notificacoes')).hitTestable(),
    );
    await tester.pumpAndSettle();

    // fechando o painel pelo botão X
    await tester.tap(find.byKey(const ValueKey('config-fechar')));
    await tester.pumpAndSettle();

    expect(find.text('Dados Pessoais').hitTestable(), findsNothing);
  });

  testWidgets('Cadastro de administrador salva e entra no painel CCO', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 6200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: AdminRegistrationScreen()));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Helena Vasconcelos');
    await tester.enterText(fields.at(1), 'helena@depar.gov.br');
    await tester.enterText(fields.at(2), '16316170440');
    await tester.pumpAndSettle();
    expect(find.text('163.161.704-40'), findsOneWidget);

    await tester.enterText(fields.at(3), 'vitoria');
    await tester.pumpAndSettle();
    expect(
      find.text('Prefeitura Municipal de Vitória de Santo Antão • PE'),
      findsOneWidget,
    );
    await tester.tap(
      find.text('Prefeitura Municipal de Vitória de Santo Antão • PE'),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Prefeitura Municipal de Vitória de Santo Antão • PE'),
      findsOneWidget,
    );

    await tester.enterText(fields.at(5), 'Senha@Forte123');
    await tester.enterText(fields.at(6), 'Senha@Forte123');

    await tester.tap(find.byKey(const ValueKey('chave-demo')));
    await tester.pumpAndSettle();
    expect(find.text('ADM-DEMO-0001-2026'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cargo-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supervisor de Frota'));
    await tester.pumpAndSettle();
    expect(find.text('Supervisor de Frota'), findsOneWidget);

    await tester.tap(find.text('Assinatura Termo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LGPD Municipal'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cadastrar Administrador'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminMainScreen), findsOneWidget);
    expect(find.text('AÇÕES DE GESTÃO'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('admin_registered'), true);
    expect(prefs.getString('admin_nome'), 'Helena Vasconcelos');
    expect(prefs.getString('admin_email'), 'helena@depar.gov.br');
    expect(prefs.getString('admin_cpf'), '163.161.704-40');
    expect(
      prefs.getString('admin_orgao'),
      'Prefeitura Municipal de Vitória de Santo Antão • PE',
    );
    expect(prefs.getString('admin_cargo'), 'Supervisor de Frota');
    expect(prefs.getString('admin_chave'), 'ADM-DEMO-0001-2026');
  });

  testWidgets('Painel admin navega entre as quatro abas', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'admin_registered': true});
    setBigScreen(tester);

    await tester.pumpWidget(const MaterialApp(home: AdminMainScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(AdminHomeScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('admin-nav-1')));
    await tester.pumpAndSettle();
    expect(find.text('Frota e Rotas'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('admin-nav-2')));
    await tester.pumpAndSettle();
    expect(find.text('Gerenciar Usuários'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('admin-nav-3')));
    await tester.pumpAndSettle();
    expect(find.byType(AdminPerfilScreen), findsOneWidget);
    expect(find.text('SUPER ADMIN CCO'), findsOneWidget);
  });

  testWidgets('Perfil do administrador encerra sessão com confirmação', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'admin_registered': true});
    setBigScreen(tester);

    await tester.pumpWidget(
      const MaterialApp(home: AdminMainScreen(initialIndex: 3)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('encerrar-sessao')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('encerrar-sessao')));
    await tester.pumpAndSettle();

    expect(find.text('Encerrar Sessão Segura?'), findsOneWidget);
    await tester.tap(find.text('Encerrar'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('admin_registered'), isNull);
  });

  testWidgets('Recuperação de senha abre a tela de e-mail pelo login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.text('Esqueceu a senha?'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.text('Recuperar senha'), findsOneWidget);
    expect(find.text('Enviar código'), findsOneWidget);
  });

  testWidgets('Dados pessoais podem ser editados e persistidos', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await StudentStorage.saveAluno(
      nome: 'Ana Costa',
      email: 'ana@example.com',
      ra: '2024.1.12345',
      cpf: '123.456.789-00',
      whatsapp: '(11) 99999-9999',
      instituicao: 'Universidade de São Paulo',
      turno: 'Manhã',
      senha: 'senha-antiga',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const DadosPessoaisScreen(profileKind: ProfileKind.aluno),
                ),
              ),
              child: const Text('Editar'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Ana Costa Silva');
    await tester.drag(find.byType(ListView), const Offset(0, -1800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    final aluno = await StudentStorage.getAluno();
    expect(aluno['nome'], 'Ana Costa Silva');
    expect(aluno['email'], 'ana@example.com');
  });

  testWidgets('Cadastro do aluno gera QR identificador próprio', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    Future<void> saveStudent(String nome) => StudentStorage.saveAluno(
      nome: nome,
      email: '$nome@example.com',
      ra: '2024.1.12345',
      cpf: '123.456.789-00',
      whatsapp: '(11) 99999-9999',
      instituicao: 'Universidade de São Paulo',
      turno: 'Manhã',
      senha: 'senha-antiga',
    );

    await saveStudent('Ana');
    final firstQrId = (await StudentStorage.getAluno())['qrId'];
    await saveStudent('Maria');
    final secondQrId = (await StudentStorage.getAluno())['qrId'];

    expect(firstQrId, matches(RegExp(r'^[a-f0-9-]{36}$')));
    expect(secondQrId, matches(RegExp(r'^[a-f0-9-]{36}$')));
    expect(secondQrId, isNot(firstQrId));
  });

  testWidgets('Foto do cadastro oferece galeria e câmera', (
    WidgetTester tester,
  ) async {
    setBigScreen(tester);
    await tester.pumpWidget(const MaterialApp(home: AlunoRegistrationScreen()));

    await tester.ensureVisible(find.text('Tirar foto ou escolher da galeria'));
    await tester.tap(find.text('Tirar foto ou escolher da galeria'));
    await tester.pumpAndSettle();

    expect(find.text('Escolher da galeria'), findsOneWidget);
    expect(find.text('Tirar foto com a câmera'), findsOneWidget);
  });
}
