import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/app_settings.dart';
import '../../services/admin_storage.dart';
import '../../services/supabase_auth_service.dart';
import '../../theme.dart';
import '../../widgets/registration_widgets.dart';
import '../admin/admin_main_screen.dart';

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  State<AdminRegistrationScreen> createState() =>
      _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  bool _sigilo = false;
  bool _lgpd = false;
  bool _saving = false;
  bool _biometricOnSignup = false;

  final _cpfMascara = _CampoMascara(_formatarCpf);
  String? _cargoSel;

  String _orgaoQuery = '';
  bool _sugestoesAbertas = false;

  static const _orgaos = <String>[
    'Prefeitura Municipal de Vitória de Santo Antão • PE',
    'Prefeitura Municipal de Recife • PE',
    'Prefeitura Municipal de Olinda • PE',
    'Prefeitura Municipal de Jaboatão dos Guararapes • PE',
    'Prefeitura Municipal de Caruaru • PE',
    'Prefeitura Municipal de Petrolina • PE',
    'Prefeitura Municipal de Campinas • SP',
    'Prefeitura Municipal de São Paulo • SP',
    'Prefeitura Municipal de Santos • SP',
    'Prefeitura Municipal de Sorocaba • SP',
    'Prefeitura Municipal de Ribeirão Preto • SP',
    'Prefeitura Municipal de São José dos Campos • SP',
    'Prefeitura Municipal de Guarulhos • SP',
    'Prefeitura Municipal de Osasco • SP',
    'Prefeitura Municipal de Uberlândia • MG',
    'Prefeitura Municipal de Belo Horizonte • MG',
    'Prefeitura Municipal de Juiz de Fora • MG',
    'Prefeitura Municipal de Contagem • MG',
    'Prefeitura Municipal de Uberaba • MG',
    'Prefeitura Municipal do Rio de Janeiro • RJ',
    'Prefeitura Municipal de Niterói • RJ',
    'Prefeitura Municipal de Duque de Caxias • RJ',
    'Prefeitura Municipal de Nova Iguaçu • RJ',
    'Prefeitura Municipal de Petrópolis • RJ',
    'Prefeitura Municipal de Curitiba • PR',
    'Prefeitura Municipal de Londrina • PR',
    'Prefeitura Municipal de Maringá • PR',
    'Prefeitura Municipal de Ponta Grossa • PR',
    'Prefeitura Municipal de Porto Alegre • RS',
    'Prefeitura Municipal de Caxias do Sul • RS',
    'Prefeitura Municipal de Pelotas • RS',
    'Prefeitura Municipal de Canoas • RS',
    'Prefeitura Municipal de Florianópolis • SC',
    'Prefeitura Municipal de Joinville • SC',
    'Prefeitura Municipal de Blumenau • SC',
    'Prefeitura Municipal de Salvador • BA',
    'Prefeitura Municipal de Feira de Santana • BA',
    'Prefeitura Municipal de Vitória da Conquista • BA',
    'Prefeitura Municipal de Camaçari • BA',
    'Prefeitura Municipal de Fortaleza • CE',
    'Prefeitura Municipal de Caucaia • CE',
    'Prefeitura Municipal de Juazeiro do Norte • CE',
    'Prefeitura Municipal de Manaus • AM',
    'Prefeitura Municipal de Belém • PA',
    'Prefeitura Municipal de Ananindeua • PA',
    'Prefeitura Municipal de São Luís • MA',
    'Prefeitura Municipal de Teresina • PI',
    'Prefeitura Municipal de Natal • RN',
    'Prefeitura Municipal de João Pessoa • PB',
    'Prefeitura Municipal de Maceió • AL',
    'Prefeitura Municipal de Aracaju • SE',
    'Prefeitura Municipal de Goiânia • GO',
    'Prefeitura Municipal de Aparecida de Goiânia • GO',
    'Prefeitura Municipal de Cuiabá • MT',
    'Prefeitura Municipal de Campo Grande • MS',
    'Prefeitura Municipal de Brasília • DF',
    'Prefeitura Municipal de Vitória • ES',
    'Prefeitura Municipal de Macapá • AP',
    'Prefeitura Municipal de Porto Velho • RO',
    'Prefeitura Municipal de Boa Vista • RR',
    'Prefeitura Municipal de Palmas • TO',
    'Consórcio Intermunicipal de Mobilidade Urbana',
    'Governo do Estado — Secretaria de Mobilidade',
  ];

  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _cpf = TextEditingController();
  final _orgao = TextEditingController();
  final _chave = TextEditingController();
  final _senha = TextEditingController();
  final _senhaConfirm = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _cpf.dispose();
    _orgao.dispose();
    _chave.dispose();
    _senha.dispose();
    _senhaConfirm.dispose();
    super.dispose();
  }

  void _onCpfChanged(String valor) {
    final formatado = _cpfMascara.formatar(valor);
    if (_cpf.text != formatado) {
      _cpf.text = formatado;
      _cpf.selection = TextSelection.collapsed(offset: formatado.length);
    }
  }

  void _onOrgaoChanged(String valor) {
    setState(() {
      _orgaoQuery = valor;
      _sugestoesAbertas =
          valor.trim().isNotEmpty && !_orgaos.contains(valor.trim());
    });
  }

  void _selecionarOrgao(String nome) {
    _orgao.text = nome;
    FocusScope.of(context).unfocus();
    setState(() {
      _orgaoQuery = nome;
      _sugestoesAbertas = false;
    });
  }

  List<String> get _sugestoesOrgao {
    final consulta = _normalizarTexto(_orgaoQuery.trim());
    if (consulta.isEmpty) return const [];
    return _orgaos
        .where((o) => _normalizarTexto(o).contains(consulta))
        .take(8)
        .toList();
  }

  Widget _buildSugestoesOrgao() {
    if (!_sugestoesAbertas) return const SizedBox.shrink();
    final sugestoes = _sugestoesOrgao;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 240),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: sugestoes.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 17,
                      color: AppColors.hintGray,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nenhum município encontrado para '
                        '"${_orgaoQuery.trim()}"',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: sugestoes.length,
                separatorBuilder: (_, _) => const Padding(
                  padding: EdgeInsets.only(left: 46, right: 14),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                itemBuilder: (context, index) {
                  final nome = sugestoes[index];
                  return InkWell(
                    onTap: () => _selecionarOrgao(nome),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_city_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              nome,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.north_west,
                            size: 13,
                            color: AppColors.hintGray,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  static const _cargos = [
    'Coordenador de Mobilidade Estudantil',
    'Diretor de Trânsito Municipal',
    'Gestor de Transporte Público',
    'Supervisor de Frota',
    'Analista de Mobilidade Urbana',
    'Chefe de Setor de Transportes',
    'Secretário Adjunto de Mobilidade',
    'Administrador do Sistema CCO',
  ];

  Future<void> _selecionarCargo() async {
    final selecionado = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  'Cargo / Função Institucional',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    for (final opcao in _cargos)
                      ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.work_outline,
                          size: 20,
                          color: _cargoSel == opcao
                              ? AppColors.primary
                              : AppColors.textGray,
                        ),
                        title: Text(
                          opcao,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: _cargoSel == opcao
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _cargoSel == opcao
                                ? AppColors.primary
                                : AppColors.textDark,
                          ),
                        ),
                        trailing: _cargoSel == opcao
                            ? const Icon(
                                Icons.check_circle,
                                size: 20,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () => Navigator.of(ctx).pop(opcao),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selecionado != null) {
      setState(() => _cargoSel = selecionado);
    }
  }

  void _usarChaveDemonstracao() {
    _chave.text = 'ADM-DEMO-0001-2026';
    setState(() {});
    _snack('Chave de demonstração preenchida. Válida apenas para testes.');
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _cadastrar() async {
    if (_nome.text.trim().isEmpty || _email.text.trim().isEmpty) {
      _snack('Preencha ao menos o nome e o e-mail institucional.');
      return;
    }
    final cpfDigitos = _cpf.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpfDigitos.isNotEmpty && cpfDigitos.length != 11) {
      _snack('CPF incompleto — use 11 dígitos.');
      return;
    }
    if (_cargoSel == null) {
      _snack('Selecione o cargo / função institucional na lista.');
      return;
    }
    if (_senha.text.isEmpty || _senha.text.length < 6) {
      _snack('A senha mestra precisa de pelo menos 6 dígitos.');
      return;
    }
    if (_senha.text != _senhaConfirm.text) {
      _snack('As senhas digitadas não conferem.');
      return;
    }
    if (!_sigilo || !_lgpd) {
      _snack('Aceite o termo de sigilo e a conformidade LGPD.');
      return;
    }

    if (_biometricOnSignup) {
      try {
        final enabled = await AppSettings.instance.enableBiometrics();
        if (!enabled) {
          _snack(
            'Não foi possível confirmar a biometria. Desative a opção ou tente novamente.',
          );
          return;
        }
      } catch (error) {
        if (mounted) _snack('Não foi possível ativar biometria: $error');
        return;
      }
    }

    setState(() => _saving = true);
    try {
      if (SupabaseAuthService.isConfigured) {
        final signedIn = await SupabaseAuthService.signUp(
          email: _email.text,
          password: _senha.text,
          role: BusFlowRole.admin,
          profileData: {
            'nome': _nome.text.trim(),
            'email': _email.text.trim().toLowerCase(),
            'cpf': _cpf.text.trim(),
            'orgao': _orgao.text.trim(),
            'cargo': _cargoSel!,
          },
        );
        if (!signedIn) {
          if (!mounted) return;
          setState(() => _saving = false);
          _snack(
            'Conta criada. Confirme o e-mail enviado e depois entre com sua senha.',
          );
          return;
        }
      } else {
        await AdminStorage.saveAdmin(
          nome: _nome.text.trim(),
          email: _email.text.trim(),
          cpf: _cpf.text.trim(),
          orgao: _orgao.text.trim(),
          cargo: _cargoSel!,
          chave: _chave.text.trim(),
          senha: _senha.text,
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack(
        'Não foi possível criar a conta: '
        '${error is AuthException ? error.message : error}',
      );
      return;
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminMainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RegistrationTopBar(title: 'Cadastro De Administrador'),
              const SizedBox(height: 18),
              const TopBadge(
                label: 'ACESSO RESTRITO MUNICIPAL • CHEFE DE SETOR/SECRETARIA',
                icon: Icons.domain,
              ),
              const SizedBox(height: 16),
              const Text(
                'Cadastro Institucional ADM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crie sua conta administrativa para monitorar a frota, rotas e comunicações universitárias municipais em tempo real.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 18),
              const InfoCard(
                icon: Icons.verified_user_outlined,
                title: 'Autenticação Controlada',
                body: 'Este módulo exige credenciamento formal prévio junto à Secretaria de Trânsito & Mobilidade Urbana.',
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                icon: Icons.person_outline,
                title: 'Dados do Gestor',
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Nome Completo do Gestor',
                child: BusFlowTextField(
                  hint: 'Ex: Carlos Eduardo de Almeida',
                  icon: Icons.person_outline,
                  controller: _nome,
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'E-mail Institucional Oficial',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'gov ou convênio',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                child: BusFlowTextField(
                  hint: 'gestor@prefeitura.sp.gov.br',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  controller: _email,
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'CPF',
                child: BusFlowTextField(
                  hint: '000.000.000-00',
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  controller: _cpf,
                  onChanged: _onCpfChanged,
                ),
              ),
              const SizedBox(height: 26),
              const SectionHeader(
                icon: Icons.apartment,
                title: 'Vínculo Municipal e Autorização',
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Órgão / Município Vinculado',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BusFlowTextField(
                      hint: 'Ex: Prefeitura Municipal de Campinas • SP',
                      icon: Icons.location_city_outlined,
                      controller: _orgao,
                      onChanged: _onOrgaoChanged,
                      suffix: Icon(
                        _sugestoesAbertas
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 22,
                        color: AppColors.textGray,
                      ),
                    ),
                    _buildSugestoesOrgao(),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Cargo / Função Institucional',
                child: GestureDetector(
                  key: const ValueKey('cargo-field'),
                  onTap: _selecionarCargo,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fieldBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _cargoSel != null
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.work_outline,
                          size: 20,
                          color: AppColors.hintGray,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _cargoSel ?? 'Selecione o cargo na lista',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: _cargoSel != null
                                  ? AppColors.textDark
                                  : AppColors.hintGray,
                              fontWeight: _cargoSel != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 22,
                          color: AppColors.textGray,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Chave de Acesso ADM Municipal',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: const Text(
                    'CÓDIGO ÚNICO',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                child: BusFlowTextField(
                  hint: 'ADM-XXXX-XXXX-XXX',
                  icon: Icons.vpn_key_outlined,
                  controller: _chave,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chave fornecida pela oficina de homologação da prefeitura. '
                'Sem ela, use a chave de demonstração abaixo para testar o painel.',
                style: TextStyle(fontSize: 11.5, color: AppColors.hintGray),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('chave-demo'),
                  onPressed: _usarChaveDemonstracao,
                  icon: const Icon(Icons.science_outlined, size: 16),
                  label: const Text(
                    'Usar chave de demonstração',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.softBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AppColors.softBlueBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const SectionHeader(
                icon: Icons.lock_outline,
                title: 'Credenciais de Autenticação Segura',
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Senha de Acesso Mestra',
                child: PasswordField(hint: '••••••', controller: _senha),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Confirmar Senha',
                child: PasswordField(
                  hint: 'Repita a senha',
                  controller: _senhaConfirm,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Critérios de Rigor e Compliança',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Text(
                    'Aprovação obrigatória',
                    style: TextStyle(fontSize: 11, color: AppColors.hintGray),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MiniCheck(
                      value: _sigilo,
                      label: 'Assinatura Termo',
                      onChanged: (v) => setState(() => _sigilo = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniCheck(
                      value: _lgpd,
                      label: 'LGPD Municipal',
                      onChanged: (v) => setState(() => _lgpd = v ?? false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const SectionHeader(
                icon: Icons.description_outlined,
                title: 'Compromisso e Termo de Sigilo LGPD',
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Termo de Confidencialidade e Responsabilidade Administrativa (Lei Federal 13.709/2018)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '1. O gestor declara ciência de que o sistema é restrito aos servidores autorizados e que os dados universitários institucionais e mobilidade são de acesso restrito.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textGray,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. Eu concordo e assumo responsabilidade pelo uso do Sistema de Sigilo e LGPD no meu cargo de diretor.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _biometricOnSignup,
                activeColor: AppColors.primary,
                title: const Text('Ativar biometria neste aparelho'),
                subtitle: const Text(
                  'A confirmação é feita pelo sistema do dispositivo.',
                  style: TextStyle(fontSize: 12),
                ),
                onChanged: (value) =>
                    setState(() => _biometricOnSignup = value ?? false),
              ),
              const SizedBox(height: 24),
              PrimarySubmitButton(
                label: _saving ? 'Cadastrando...' : 'Cadastrar Administrador',
                icon: Icons.admin_panel_settings,
                onPressed: _saving ? null : _cadastrar,
              ),
              const SizedBox(height: 18),
              Column(
                children: [
                  const Text(
                    'Não possui acesso ADM do município?',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Solicitar ao Controle de Tecnologia ↗',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCheck extends StatelessWidget {
  const _MiniCheck({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: value
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatarCpf(String digitos) {
  final sb = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i == 3 || i == 6) sb.write('.');
    if (i == 9) sb.write('-');
    sb.write(digitos[i]);
  }
  return sb.toString();
}

/// Remove acentos e normaliza para comparação em buscas.
String _normalizarTexto(String texto) {
  var normal = texto.toLowerCase().trim();
  const mapa = {
    'á': 'a',
    'à': 'a',
    'ã': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'ê': 'e',
    'è': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ó': 'o',
    'õ': 'o',
    'ô': 'o',
    'ò': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };
  mapa.forEach((de, para) => normal = normal.replaceAll(de, para));
  return normal;
}

/// Máscara de dígitos que reaplica a formatação a cada tecla.
class _CampoMascara {
  _CampoMascara(this._formatar);

  final String Function(String digitos) _formatar;

  String _valorAnterior = '';
  String _digitosAnteriores = '';

  String formatar(String valor) {
    var digitos = valor.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length > 11) digitos = digitos.substring(0, 11);

    // Backspace sobre um separador apaga também o dígito anterior.
    final apagouSeparador =
        valor.length < _valorAnterior.length &&
        digitos == _digitosAnteriores &&
        digitos.isNotEmpty;
    if (apagouSeparador) digitos = digitos.substring(0, digitos.length - 1);

    final formatado = _formatar(digitos);
    _valorAnterior = formatado;
    _digitosAnteriores = digitos;
    return formatado;
  }
}
