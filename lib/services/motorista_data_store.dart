import 'package:flutter/material.dart';

import 'motorista_storage.dart';

class EmbarquePassageiro {
  EmbarquePassageiro({
    required this.iniciais,
    required this.nome,
    required this.ra,
    required this.curso,
    required this.hora,
    required this.portao,
    required this.cor,
    required this.corTexto,
    this.aprovado = true,
  });

  final String iniciais;
  final String nome;
  final String ra;
  final String curso;
  final String hora;
  final String portao;
  final Color cor;
  final Color corTexto;
  final bool aprovado;
}

class RotaAtribuida {
  const RotaAtribuida({
    required this.linha,
    required this.onibus,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.origem,
    required this.origemNota,
    required this.saida,
    required this.destino,
    required this.destinoNota,
    required this.chegada,
    required this.lotacaoLabel,
    required this.ocupados,
    required this.total,
    required this.infoExtra,
    required this.acaoPrimaria,
    required this.acaoPrimariaIcon,
    this.acaoSecundaria,
    this.acaoSecundariaIcon,
    this.concluida = false,
  });

  final String linha;
  final String onibus;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String origem;
  final String origemNota;
  final String saida;
  final String destino;
  final String destinoNota;
  final String chegada;
  final String lotacaoLabel;
  final int ocupados;
  final int total;
  final String infoExtra;
  final String acaoPrimaria;
  final IconData acaoPrimariaIcon;
  final String? acaoSecundaria;
  final IconData? acaoSecundariaIcon;
  final bool concluida;
}

class AlertaMotorista {
  AlertaMotorista({
    required this.titulo,
    required this.mensagem,
    required this.hora,
    required this.icone,
    required this.iconeBg,
    required this.iconeCor,
    required this.categoria,
    this.lido = false,
  });

  final String titulo;
  final String mensagem;
  final String hora;
  final IconData icone;
  final Color iconeBg;
  final Color iconeCor;
  final String categoria; // 'Validação' | 'Viagem' | 'Sistema'
  bool lido;
}

/// Fonte única de dados do motorista: perfil vindo do [MotoristaStorage]
/// e estado operacional que só existe a partir de ações reais do usuário.
class MotoristaDataStore extends ChangeNotifier {
  MotoristaDataStore._();

  static final MotoristaDataStore instance = MotoristaDataStore._();

  // ── Perfil (preenchido pelo cadastro) ──────────────────────────────
  String nome = '';
  String email = '';
  String cpf = '';
  String telefone = '';
  String cnh = '';
  String categoria = '';
  String turno = '';
  String empresa = '';

  // ── Estado operacional (vazio até o usuário agir) ──────────────────
  final List<RotaAtribuida> rotas = [];
  RotaAtribuida? viagemAtual;
  bool viagemIniciada = false;
  final List<EmbarquePassageiro> embarques = [];
  final Map<String, bool> checklist = <String, bool>{
    'Combustível': false,
    'Pneus': false,
    'Validado OK': false,
  };
  final List<AlertaMotorista> alertas = [];

  static const int capacidadeTotal = 44;

  // ── Getters derivados ──────────────────────────────────────────────
  int get lotacao => embarques.length;
  double get lotacaoFraction => lotacao / capacidadeTotal;
  int get assentosLivres =>
      (capacidadeTotal - lotacao).clamp(0, capacidadeTotal);

  String get faixaLotacao {
    if (lotacaoFraction >= 0.9) return 'Lotação Alta';
    if (lotacaoFraction >= 0.6) return 'Lotação Moderada';
    return 'Lotação Baixa';
  }

  String get statusLotacao {
    if (lotacaoFraction >= 0.9) return 'Lotado';
    if (lotacaoFraction >= 0.6) return 'Confortável';
    return 'Disponível';
  }

  int get rotasHoje => rotas.length;
  int get rotasAtivas =>
      rotas.where((r) => r.status == 'Em Andamento').length;
  int get rotasProgramadas =>
      rotas.where((r) => r.status == 'Aguardando Saída' || r.status == 'Tarde')
          .length;
  int get rotasConcluidas => rotas.where((r) => r.concluida).length;

  int get viagensConcluidas => rotasConcluidas;

  int get alertasNaoLidos => alertas.where((a) => !a.lido).length;

  String get primeiroNome {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return 'Motorista';
    return partes.first;
  }

  String get nomeCompleto {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.length > 1) return '${partes.first} ${partes.last}';
    return partes.isEmpty || partes.first.isEmpty
        ? 'Motorista'
        : partes.first;
  }

  String get categoriaExibicao =>
      categoria.replaceAll('CATEGORIA ', '').isEmpty
          ? '—'
          : categoria.replaceAll('CATEGORIA ', '');

  // ── Ciclo de vida ──────────────────────────────────────────────────
  Future<void> load() async {
    try {
      final m = await MotoristaStorage.getMotorista();
      nome = m['nome'] ?? '';
      email = m['email'] ?? '';
      cpf = m['cpf'] ?? '';
      telefone = m['telefone'] ?? '';
      cnh = m['cnh'] ?? '';
      categoria = m['categoria'] ?? '';
      turno = m['turno'] ?? '';
      empresa = m['empresa'] ?? '';
    } catch (_) {
      // Sem preferências — mantém vazio.
    }
    notifyListeners();
  }

  void limparTudo() {
    nome = '';
    email = '';
    cpf = '';
    telefone = '';
    cnh = '';
    categoria = '';
    turno = '';
    empresa = '';
    rotas.clear();
    viagemAtual = null;
    viagemIniciada = false;
    embarques.clear();
    checklist.updateAll((_, _) => false);
    alertas.clear();
    notifyListeners();
  }

  // ── Ações ──────────────────────────────────────────────────────────
  String _horaAgora() {
    final agora = TimeOfDay.now();
    return '${agora.hour.toString().padLeft(2, '0')}'
        ':${agora.minute.toString().padLeft(2, '0')}';
  }

  void iniciarViagem(RotaAtribuida rota) {
    viagemAtual = rota;
    viagemIniciada = true;
    _addAlerta(
      titulo: 'Viagem iniciada',
      mensagem: '${rota.linha} • ${rota.origem} → ${rota.destino}',
      icone: Icons.directions_bus,
      iconeBg: const Color(0xFFDBEAFE),
      iconeCor: AppPalette.primary,
      categoria: 'Viagem',
    );
    notifyListeners();
  }

  void encerrarViagem() {
    final rota = viagemAtual;
    viagemIniciada = false;
    if (rota != null) {
      _addAlerta(
        titulo: 'Viagem encerrada',
        mensagem:
            '${rota.linha} • $lotacao passageiros • ${_horaAgora()}',
        icone: Icons.flag_outlined,
        iconeBg: const Color(0xFFF1F5F9),
        iconeCor: AppPalette.textGray,
        categoria: 'Viagem',
      );
    }
    viagemAtual = null;
    notifyListeners();
  }

  /// Valida o embarque. Retorna `false` se o ônibus estiver lotado.
  bool validarEmbarque({
    required String iniciais,
    required String nomePassageiro,
    required String ra,
    required String curso,
    required String portao,
    required Color cor,
    required Color corTexto,
  }) {
    if (lotacao >= capacidadeTotal) {
      _addAlerta(
        titulo: 'Embarque recusado — lotado',
        mensagem: 'Ônibus atingiu $capacidadeTotal/$capacidadeTotal assentos.',
        icone: Icons.block,
        iconeBg: const Color(0xFFFEE2E2),
        iconeCor: const Color(0xFFDC2626),
        categoria: 'Validação',
      );
      notifyListeners();
      return false;
    }
    embarques.insert(
      0,
      EmbarquePassageiro(
        iniciais: iniciais,
        nome: nomePassageiro,
        ra: ra,
        curso: curso,
        hora: _horaAgora(),
        portao: portao,
        cor: cor,
        corTexto: corTexto,
      ),
    );
    _addAlerta(
      titulo: 'Embarque validado',
      mensagem: '$nomePassageiro • $ra • $portao',
      icone: Icons.check_circle_outline,
      iconeBg: const Color(0xFFDCFCE7),
      iconeCor: AppPalette.green,
      categoria: 'Validação',
    );
    notifyListeners();
    return true;
  }

  void recusarEmbarque() {
    _addAlerta(
      titulo: 'Passe recusado',
      mensagem: 'Carteirinha inválida ou vencida às ${_horaAgora()}.',
      icone: Icons.cancel_outlined,
      iconeBg: const Color(0xFFFEE2E2),
      iconeCor: const Color(0xFFDC2626),
      categoria: 'Validação',
    );
    notifyListeners();
  }

  void toggleChecklist(String item) {
    if (!checklist.containsKey(item)) return;
    checklist[item] = !(checklist[item] ?? false);
    notifyListeners();
  }

  bool get checklistCompleto => checklist.values.every((v) => v);

  void addRota(RotaAtribuida rota) {
    rotas.add(rota);
    _addAlerta(
      titulo: 'Nova rota atribuída',
      mensagem: '${rota.linha} • ${rota.origem} às ${rota.saida}',
      icone: Icons.route,
      iconeBg: const Color(0xFFEFF4FF),
      iconeCor: AppPalette.primary,
      categoria: 'Sistema',
    );
    notifyListeners();
  }

  void marcarTodosAlertasLidos() {
    for (final a in alertas) {
      a.lido = true;
    }
    notifyListeners();
  }

  void marcarAlertaLido(AlertaMotorista alerta) {
    alerta.lido = true;
    notifyListeners();
  }

  void _addAlerta({
    required String titulo,
    required String mensagem,
    required IconData icone,
    required Color iconeBg,
    required Color iconeCor,
    required String categoria,
  }) {
    alertas.insert(
      0,
      AlertaMotorista(
        titulo: titulo,
        mensagem: mensagem,
        hora: 'Agora',
        icone: icone,
        iconeBg: iconeBg,
        iconeCor: iconeCor,
        categoria: categoria,
      ),
    );
    if (alertas.length > 30) alertas.removeLast();
  }
}

/// Cores usadas pelo store (evita import circular com o widget theme).
class AppPalette {
  AppPalette._();

  static const primary = Color(0xFF17457F);
  static const green = Color(0xFF16A34A);
  static const textGray = Color(0xFF64748B);
}