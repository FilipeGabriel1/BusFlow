import 'package:flutter/material.dart';

import 'admin_storage.dart';

class SolicitacaoPendente {
  SolicitacaoPendente({
    required this.iniciais,
    required this.nome,
    required this.detalhe,
    required this.hora,
    required this.cor,
  });

  final String iniciais;
  final String nome;
  final String detalhe;
  final String hora;
  final Color cor;
}

class UsuarioAdmin {
  UsuarioAdmin({
    required this.iniciais,
    required this.nome,
    required this.categoria,
    required this.detalhe1,
    required this.detalhe2,
    required this.cor,
    this.badge,
    this.emRota = false,
    this.bloqueado = false,
    this.motivoBloqueio = '',
  });

  final String iniciais;
  final String nome;
  final String categoria; // 'Aluno' | 'Motorista' | 'Admin'
  final String detalhe1;
  final String detalhe2;
  final Color cor;
  final String? badge;
  final bool emRota;
  bool bloqueado;
  String motivoBloqueio;
}

class VeiculoFrota {
  VeiculoFrota({
    required this.id,
    required this.modelo,
    required this.placa,
    required this.status,
    required this.motorista,
    required this.motoristaDetalhe,
    required this.linha,
    required this.lote,
    required this.ocupacao,
    required this.capacidade,
    required this.acaoSecundaria,
  });

  final String id;
  final String modelo;
  final String placa;
  String status; // 'Em Rota' | 'Parado' | 'Manutenção' | 'Sem motorista'
  String motorista;
  String motoristaDetalhe;
  String linha;
  String lote;
  int ocupacao;
  final int capacidade;
  String acaoSecundaria;
}

class RotaAtivaAdmin {
  const RotaAtivaAdmin({
    required this.codigo,
    required this.origem,
    required this.destino,
    required this.status,
    required this.horarios,
    required this.passageiros,
  });

  final String codigo;
  final String origem;
  final String destino;
  final String status;
  final String horarios;
  final String passageiros;
}

class AlertaAdmin {
  AlertaAdmin({
    required this.titulo,
    required this.categoria,
    required this.mensagem,
    required this.hora,
    required this.acao,
    required this.icone,
    required this.iconeCor,
    required this.tituloCor,
  });

  final String titulo;
  final String categoria;
  final String mensagem;
  final String hora;
  final String acao;
  final IconData icone;
  final Color iconeCor;
  final Color tituloCor;
  bool resolvido = false;
}

/// Fonte única de dados do administrador: perfil vindo do [AdminStorage]
/// e estado do sistema (frota, usuários, alertas) com ações que o
/// próprio gestor executa.
class AdminDataStore extends ChangeNotifier {
  AdminDataStore._();

  static final AdminDataStore instance = AdminDataStore._();

  // ── Perfil (preenchido pelo cadastro) ──────────────────────────────
  String nome = '';
  String email = '';
  String cpf = '';
  String orgao = '';
  String cargo = '';
  String chave = '';

  // ── Métricas do sistema ───────────────────────────────────────────
  int alunosCadastrados = 4820;
  int alunosNovos = 128;
  int motoristasAtivos = 38;
  int motoristasTotal = 42;
  int onibusOperacionais = 24;
  int onibusTotal = 28;
  int onibusManual = 4;
  int viagensEmCurso = 14;
  int viagensEmbarque = 3;
  final List<int> viagensSemana = [84, 92, 98, 104, 88, 32];
  static const diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  int solicitacoesPendentesBase = 12;
  int usuariosBloqueadosBase = 5;

  // ── Listas operacionais ───────────────────────────────────────────
  final List<AlertaAdmin> alertas = [
    AlertaAdmin(
      titulo: 'Ônibus #402 • Lotação 100%',
      categoria: 'Crítico',
      mensagem: 'Campus Central • Linha L02\nCapacidade: 44/44 • 6 na fila',
      hora: 'há 3 minutos',
      acao: 'Designar Veículo',
      icone: Icons.directions_bus_filled,
      iconeCor: const Color(0xFFDC2626),
      tituloCor: const Color(0xFFDC2626),
    ),
    AlertaAdmin(
      titulo: 'Viagem Atrasada (+18 min)',
      categoria: 'Trânsito',
      mensagem: 'Linha L02 • Terminal Lesle\nLentidão no Corredor Norte',
      hora: 'há 7 minutos',
      acao: 'Notificar Alunos',
      icone: Icons.schedule,
      iconeCor: const Color(0xFFF59E0B),
      tituloCor: const Color(0xFFB45309),
    ),
    AlertaAdmin(
      titulo: 'Motorista Indisponível',
      categoria: 'Escala',
      mensagem: 'Carlos Eduardo • Turno Noite\nAtendimento registrado',
      hora: 'há 22 minutos',
      acao: 'Escalar Substituto',
      icone: Icons.person_off_outlined,
      iconeCor: const Color(0xFF17457F),
      tituloCor: const Color(0xFF17457F),
    ),
  ];

  final List<VeiculoFrota> veiculos = [
    VeiculoFrota(
      id: '4021',
      modelo: 'Caio Apache',
      placa: 'ABC1D23',
      status: 'Manutenção',
      motorista: 'João Silva Santos',
      motoristaDetalhe: '17.8 km/h • GPS Ativo',
      linha: 'Campus Central – Terminal Lesle',
      lote: 'Lotação Atual: 100% (44/44) • 142 passageiros hoje',
      ocupacao: 44,
      capacidade: 44,
      acaoSecundaria: 'Atribuir Rota',
    ),
    VeiculoFrota(
      id: '3055',
      modelo: 'Marcopolo Viale',
      placa: 'EFG4H56',
      status: 'Em Rota',
      motorista: 'Marcos Vinícius P.',
      motoristaDetalhe: '32.4 km/h • GPS Ativo',
      linha: 'Campus Sul – Centro Urbano',
      lote: 'Lotação Atual: 72% (32/44) • 96 passageiros hoje',
      ocupacao: 32,
      capacidade: 44,
      acaoSecundaria: 'Atribuir Rota',
    ),
    VeiculoFrota(
      id: '18',
      modelo: 'Caio Finitum',
      placa: 'IJK7L89',
      status: 'Parado',
      motorista: 'Facilito Duarte',
      motoristaDetalhe: 'No Garagem (Parada 30)',
      linha: 'Sem rota atribuída',
      lote: 'Lotação Atual: 0% (0/44) • 0 passageiros hoje',
      ocupacao: 0,
      capacidade: 44,
      acaoSecundaria: 'Atribuir Rota',
    ),
    VeiculoFrota(
      id: '2040-500',
      modelo: 'Mercedes-Benz',
      placa: 'MNO3P45',
      status: 'Sem motorista',
      motorista: 'Sem motorista',
      motoristaDetalhe: 'Ponto Central • Retornado',
      linha: 'Sem rota atribuída',
      lote: 'Lotação Atual: 0% (0/44) • 0 passageiros hoje',
      ocupacao: 0,
      capacidade: 44,
      acaoSecundaria: 'Designar para Linha',
    ),
  ];

  final List<RotaAtivaAdmin> rotasAtivas = [
    const RotaAtivaAdmin(
      codigo: 'L01',
      origem: 'Campus Central',
      destino: 'Centro Urbano',
      status: 'Em Rota',
      horarios: '06:40 • 07:00 • 07:20 (Almoço) • 13:00 • 16:30',
      passageiros: '212/440 passageiros por dia',
    ),
    const RotaAtivaAdmin(
      codigo: 'L02',
      origem: 'Campus Sul',
      destino: 'Terminal Lesle',
      status: 'Em Rota',
      horarios: '07:10 • 08:00 • 11:30 (Almoço) • 17:10',
      passageiros: '168/380 passageiros por dia',
    ),
    const RotaAtivaAdmin(
      codigo: 'L03',
      origem: 'Politécnica',
      destino: 'Bairro Universitário',
      status: 'Partida',
      horarios: '06:50 • 08:15 • 12:00 (Almoço) • 18:00',
      passageiros: '94/260 passageiros por dia',
    ),
  ];

  final List<SolicitacaoPendente> solicitacoes = [
    SolicitacaoPendente(
      iniciais: 'MS',
      nome: 'Mariana Salles',
      detalhe:
          'Matrícula 2024.1 • Centro Acadêmico • RA: 4432-8903\nAtualização de matrícula anexada',
      hora: 'há 15 min',
      cor: const Color(0xFF17457F),
    ),
    SolicitacaoPendente(
      iniciais: 'RC',
      nome: 'Rafael Cordeiro',
      detalhe:
          'Motorista • CNH D/E verificada • Registro: 99887766554\nVínculo com Consórcio Fênix anexado',
      hora: 'há 48 min',
      cor: const Color(0xFF0D9488),
    ),
  ];

  final List<UsuarioAdmin> usuarios = [
    UsuarioAdmin(
      iniciais: 'LA',
      nome: 'Lucas Albuquerque',
      categoria: 'Aluno',
      detalhe1: 'RA: 2024.1057 • Matrícula Regular',
      detalhe2: 'Câmera Digital Ativa • Semestre 2026/1',
      cor: const Color(0xFF16A34A),
      badge: 'Ativo',
    ),
    UsuarioAdmin(
      iniciais: 'JS',
      nome: 'João Silva Santos',
      categoria: 'Motorista',
      detalhe1: 'RA: 2023.4412 • Matrícula Regular',
      detalhe2: 'Linha L01 / Ônibus #002\nTurno Manhã • Rota Diária OK',
      cor: const Color(0xFF17457F),
      badge: 'Ativo',
      emRota: true,
    ),
    UsuarioAdmin(
      iniciais: 'HV',
      nome: 'Dra. Helena Vasconcelos',
      categoria: 'Admin',
      detalhe1: 'ADM CCO',
      detalhe2: 'Acesso Total • Permissões de Governança e Despacho',
      cor: const Color(0xFF7C3AED),
      badge: 'Ativo',
    ),
    UsuarioAdmin(
      iniciais: 'GF',
      nome: 'Gabriel Fontes',
      categoria: 'Aluno',
      detalhe1: 'RA: 2021-0442 • Matrícula Trancada',
      detalhe2:
          'Vínculo institucional travado por DAC. Carteirinha expirada há 21 dias.',
      cor: const Color(0xFFDC2626),
      badge: 'Bloqueado',
      bloqueado: true,
      motivoBloqueio: 'Suspensão acadêmica / Trancamento de Matrícula',
    ),
  ];

  // ── Getters derivados ─────────────────────────────────────────────
  int get alertasPendentes => alertas.where((a) => !a.resolvido).length;
  int get solicitacoesAbertas => solicitacoes.length;
  int get usuariosAtivos =>
      usuarios.where((u) => !u.bloqueado).length + 4841;
  int get usuariosBloqueados =>
      usuarios.where((u) => u.bloqueado).length + usuariosBloqueadosBase - 1;
  double get mediaViagens {
    final soma = viagensSemana.fold<int>(0, (a, b) => a + b);
    return soma / viagensSemana.length;
  }

  int get veiculosEmRota => veiculos.where((v) => v.status == 'Em Rota').length;
  int get veiculosParados => veiculos.where((v) => v.status == 'Parado').length;
  int get veiculosManutencao =>
      veiculos.where((v) => v.status == 'Manutenção').length;
  int get veiculosSemMotorista =>
      veiculos.where((v) => v.status == 'Sem motorista').length;

  String get primeiroNome {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return 'Administrador';
    return partes.first;
  }

  String get cargoExibicao => cargo.isNotEmpty ? cargo : 'Gestor CCO';
  String get orgaoExibicao => orgao.isNotEmpty ? orgao : 'PRAE';
  String get iniciaisAvatar {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.length >= 2) {
      return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
    }
    if (partes.isNotEmpty && partes.first.isNotEmpty) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return 'AD';
  }

  // ── Ciclo de vida ─────────────────────────────────────────────────
  Future<void> load() async {
    try {
      final a = await AdminStorage.getAdmin();
      nome = a['nome'] ?? '';
      email = a['email'] ?? '';
      cpf = a['cpf'] ?? '';
      orgao = a['orgao'] ?? '';
      cargo = a['cargo'] ?? '';
      chave = a['chave'] ?? '';
    } catch (_) {
      // Sem preferências — mantém vazio.
    }
    notifyListeners();
  }

  void limparTudo() {
    nome = '';
    email = '';
    cpf = '';
    orgao = '';
    cargo = '';
    chave = '';
    notifyListeners();
  }

  // ── Ações ─────────────────────────────────────────────────────────
  void resolverAlerta(AlertaAdmin alerta) {
    alerta.resolvido = true;
    notifyListeners();
  }

  void reabrirAlertas() {
    for (final a in alertas) {
      a.resolvido = false;
    }
    notifyListeners();
  }

  void aprovarSolicitacao(SolicitacaoPendente s) {
    solicitacoes.remove(s);
    alunosCadastrados++;
    notifyListeners();
  }

  void recusarSolicitacao(SolicitacaoPendente s) {
    solicitacoes.remove(s);
    notifyListeners();
  }

  void alternarBloqueio(UsuarioAdmin u) {
    u.bloqueado = !u.bloqueado;
    if (u.bloqueado) {
      u.motivoBloqueio = 'Bloqueio administrativo registrado no CCO';
    } else {
      u.motivoBloqueio = '';
    }
    notifyListeners();
  }

  void designarMotorista(VeiculoFrota v, String motorista) {
    v.motorista = motorista;
    v.motoristaDetalhe = '28.0 km/h • GPS Ativo';
    v.status = 'Em Rota';
    if (v.linha == 'Sem rota atribuída') {
      v.linha = 'Campus Central – Centro Urbano';
    }
    notifyListeners();
  }

  void cadastrarVeiculo(String modelo, String placa) {
    veiculos.insert(
      0,
      VeiculoFrota(
        id: '${9000 + veiculos.length}',
        modelo: modelo,
        placa: placa,
        status: 'Sem motorista',
        motorista: 'Sem motorista',
        motoristaDetalhe: 'Aguardando designação',
        linha: 'Sem rota atribuída',
        lote: 'Lotação Atual: 0% (0/44) • 0 passageiros hoje',
        ocupacao: 0,
        capacidade: 44,
        acaoSecundaria: 'Designar para Linha',
      ),
    );
    onibusTotal++;
    notifyListeners();
  }

  String emitirRelatorio() {
    final agora = DateTime.now();
    final data =
        '${agora.day.toString().padLeft(2, '0')}/'
        '${agora.month.toString().padLeft(2, '0')}/${agora.year}';
    return 'Relatório geral gerado ($data) — PDF/Excel disponível na central.';
  }
}
