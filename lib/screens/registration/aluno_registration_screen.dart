import 'package:flutter/material.dart';

import '../../services/student_storage.dart';
import '../../theme.dart';
import '../../widgets/registration_widgets.dart';
import '../aluno/aluno_main_screen.dart';

class AlunoRegistrationScreen extends StatefulWidget {
  const AlunoRegistrationScreen({super.key});

  @override
  State<AlunoRegistrationScreen> createState() =>
      _AlunoRegistrationScreenState();
}

class _AlunoRegistrationScreenState extends State<AlunoRegistrationScreen> {
  int _turno = 0;
  bool _terms = false;
  bool _saving = false;

  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _ra = TextEditingController();
  final _cpf = TextEditingController();
  final _whatsapp = TextEditingController();
  final _instituicao = TextEditingController();
  final _senha = TextEditingController();
  final _senhaConfirm = TextEditingController();

  final _cpfMascara = _CampoMascara(_formatarCpf);
  final _whatsMascara = _CampoMascara(_formatarCelular);

  String _instituicaoQuery = '';
  bool _sugestoesAbertas = false;

  static const _turnos = [
    (Icons.wb_sunny, Color(0xFFF59E0B), 'Manhã', '07:00 - 12:30'),
    (Icons.wb_sunny, Color(0xFFF59E0B), 'Tarde', '13:00 - 18:00'),
    (Icons.nightlight_round, Color(0xFF6366F1), 'Noite', '18:00 - 23:00'),
  ];

  static final List<String> _instituicoes = <String>[
    'Universidade de Brasília (UnB)',
    'Universidade Federal do ABC (UFABC)',
    'Universidade Federal de Alagoas (UFAL)',
    'Universidade Federal do Acre (UFAC)',
    'Universidade Federal do Amapá (UNIFAP)',
    'Universidade Federal do Amazonas (UFAM)',
    'Universidade Federal da Bahia (UFBA)',
    'Universidade Federal do Ceará (UFC)',
    'Universidade Federal do Espírito Santo (UFES)',
    'Universidade Federal de Goiás (UFG)',
    'Universidade Federal de Itajubá (UNIFEI)',
    'Universidade Federal de Lavras (UFLA)',
    'Universidade Federal do Maranhão (UFMA)',
    'Universidade Federal de Minas Gerais (UFMG)',
    'Universidade Federal do Mato Grosso (UFMT)',
    'Universidade Federal do Mato Grosso do Sul (UFMS)',
    'Universidade Federal do Ouro Preto (UFOP)',
    'Universidade Federal do Pará (UFPA)',
    'Universidade Federal da Paraíba (UFPB)',
    'Universidade Federal do Paraná (UFPR)',
    'Universidade Federal de Pelotas (UFPel)',
    'Universidade Federal de Pernambuco (UFPE)',
    'Universidade Federal do Piauí (UFPI)',
    'Universidade Federal do Rio de Janeiro (UFRJ)',
    'Universidade Federal do Rio Grande do Norte (UFRN)',
    'Universidade Federal do Rio Grande do Sul (UFRGS)',
    'Universidade Federal do Rio Grande (FURG)',
    'Universidade Federal de Rondônia (UNIR)',
    'Universidade Federal de Roraima (UFRR)',
    'Universidade Federal de Santa Catarina (UFSC)',
    'Universidade Federal de Santa Maria (UFSM)',
    'Universidade Federal de São Carlos (UFSCar)',
    'Universidade Federal de Sergipe (UFS)',
    'Universidade Federal do Sul e Sudeste do Pará (UNIFESSPA)',
    'Universidade Federal do Tocantins (UNITINS)',
    'Universidade Federal de Uberlândia (UFU)',
    'Universidade Federal do Vale do São Francisco (UNIVASF)',
    'Universidade Federal de Viçosa (UFV)',
    'Universidade Estadual de Campinas (UNICAMP)',
    'Universidade Estadual Paulista (UNESP)',
    'Universidade Estadual do Ceará (UECE)',
    'Universidade Estadual de Feira de Santana (UEFS)',
    'Universidade Estadual de Goiás (UEG)',
    'Universidade Estadual de Londrina (UEL)',
    'Universidade Estadual de Maringá (UEM)',
    'Universidade Estadual do Maranhão (UEMA)',
    'Universidade Estadual do Norte do Rio de Janeiro (UENF)',
    'Universidade Estadual do Oeste do Paraná (UNIOESTE)',
    'Universidade Estadual do Pará (UEPA)',
    'Universidade Estadual de Ponta Grossa (UEPG)',
    'Universidade Estadual do Piauí (UESPI)',
    'Universidade Estadual do Rio Grande do Sul (UERGS)',
    'Universidade Estadual do Sudoeste da Bahia (UESB)',
    'Instituto Federal de São Paulo (IFSP)',
    'Instituto Federal de Minas Gerais (IFMG)',
    'Instituto Federal do Rio de Janeiro (IFRJ)',
    'Instituto Federal do Ceará (IFCE)',
    'Instituto Federal da Bahia (IFBA)',
    'Instituto Federal de Pernambuco (IFPE)',
    'Instituto Federal do Paraná (IFPR)',
    'Instituto Federal de Santa Catarina (IFSC)',
    'Instituto Federal do Rio Grande do Sul (IFRS)',
    'Instituto Federal do Amazonas (IFAM)',
    'Instituto Federal do Pará (IFPA)',
    'Instituto Federal do Maranhão (IFMA)',
    'Instituto Federal do Piauí (IFPI)',
    'Instituto Federal do Espírito Santo (IFES)',
    'Instituto Federal do Amapá (IFAP)',
    'Pontifícia Universidade Católica de São Paulo (PUC-SP)',
    'Pontifícia Universidade Católica do Rio de Janeiro (PUC-Rio)',
    'Pontifícia Universidade Católica de Campinas (PUC-Campinas)',
    'Pontifícia Universidade Católica de Minas Gerais (PUC-Minas)',
    'Pontifícia Universidade Católica do Paraná (PUC-PR)',
    'Pontifícia Universidade Católica do Rio Grande do Sul (PUCRS)',
    'Pontifícia Universidade Católica de Goiás (PUC-Goiás)',
    'Pontifícia Universidade Católica de Pernambuco (PUC-PE)',
    'Pontifícia Universidade Católica da Bahia (PUC-Bahia)',
    'Pontifícia Universidade Católica de Brasília (UCB)',
    'Universidade Presbiteriana Mackenzie (Mackenzie)',
    'Universidade Cruzeiro do Sul (UNICRUZ)',
    'Universidade São Judas Tadeu (USJT)',
    'Universidade Nove de Julho (UNINOVE)',
    'Universidade Anhanguera (Unianhanguera)',
    'Universidade Paulista (UNIP)',
    'Universidade Guarulhos (UNG)',
    'Universidade Cidade de São Paulo (UNICID)',
    'Universidade de Franca (UNIFRAN)',
    'Universidade de Ribeirão Preto (UNIREP)',
    'Universidade de São Paulo (USP)',
    'Universidade Santa Cruz (UNISANTA)',
    'Universidade do Vale do Paraíba (UNIVAP)',
    'Universidade Metodista de São Paulo (Umet)',
    'Universidade Anhembi Morumbi (Anhembi Morumbi)',
    'Universidade Brasil',
    'Universidade Camilo Castelo Branco (UNICAMILLO)',
    'Universidade Braz Cubas (UBC)',
    'Universidade Ibirapuera (Unib)',
    'Universidade de Caxias do Sul (UCS)',
    'Universidade de Passo Fundo (UPF)',
    'Universidade Feevale',
    'Universidade de Santa Cruz do Sul (UNISC)',
    'Universidade Luterana do Brasil (ULBRA)',
    'Universidade Católica de Pelotas (UCPEL)',
    'Universidade do Sul de Santa Catarina (UNISUL)',
    'Universidade do Vale do Itajaí (UNIVALI)',
    'Universidade Regional de Blumenau (FURB)',
    'Universidade Adventista de São Paulo (UNASP)',
    'Universidade São Francisco (USF)',
    'Universidade Positivo (UP)',
    'Universidade Paranaense (Unipar)',
    'Universidade Metodista do Paraná (Unicenp)',
    'Centro Universitário São Camilo',
    'Centro Universitário UNA (UNA)',
    'Centro Universitário Filadélfia (UNIFIL)',
    'Centro Universitário de Brasília (Unieuro)',
    'Centro Universitário Belas Artes',
    'Faculdade de Tecnologia de São Paulo (FATEC-SP)',
    'Faculdade de Informática e Administração Paulista (FIAP)',
    'Faculdade de Engenharia Industrial (FEI)',
    'Instituto Mauá de Tecnologia (Mauá)',
    'Instituto de Ensino e Pesquisa (Insper)',
    'Fundação Getulio Vargas (FGV)',
    'Escola Superior de Propaganda e Marketing (ESPM)',
    'Estácio de Sá (Estácio)',
  ]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _ra.dispose();
    _cpf.dispose();
    _whatsapp.dispose();
    _instituicao.dispose();
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

  void _onWhatsChanged(String valor) {
    final formatado = _whatsMascara.formatar(valor);
    if (_whatsapp.text != formatado) {
      _whatsapp.text = formatado;
      _whatsapp.selection = TextSelection.collapsed(offset: formatado.length);
    }
  }

  void _onInstituicaoChanged(String valor) {
    setState(() {
      _instituicaoQuery = valor;
      _sugestoesAbertas =
          valor.trim().isNotEmpty && !_instituicoes.contains(valor.trim());
    });
  }

  void _selecionarInstituicao(String nome) {
    _instituicao.text = nome;
    FocusScope.of(context).unfocus();
    setState(() {
      _instituicaoQuery = nome;
      _sugestoesAbertas = false;
    });
  }

  List<String> get _sugestoesInstituicao {
    final consulta = _normalizarTexto(_instituicaoQuery.trim());
    if (consulta.isEmpty) return const [];
    return _instituicoes
        .where((i) => _normalizarTexto(i).contains(consulta))
        .take(8)
        .toList();
  }

  (String, Color) get _forcaSenha {
    final v = _senha.text;
    if (v.isEmpty) return ('—', AppColors.hintGray);
    var tipos = 0;
    if (v.contains(RegExp(r'[a-z]'))) tipos++;
    if (v.contains(RegExp(r'[A-Z]'))) tipos++;
    if (v.contains(RegExp(r'[0-9]'))) tipos++;
    if (v.contains(RegExp(r'[^A-Za-z0-9]'))) tipos++;
    if (v.length < 8 || tipos <= 1) return ('Fraca', Colors.redAccent);
    if (v.length >= 10 && tipos >= 3) return ('Forte', AppColors.green);
    return ('Média', const Color(0xFFF59E0B));
  }

  String get _dicaSenha {
    switch (_forcaSenha.$1) {
      case '—':
        return 'Use letras, números e símbolos';
      case 'Fraca':
        return 'Mínimo 8 caracteres';
      case 'Média':
        return 'Adicione símbolos e maiúsculas';
      default:
        return 'Excelente!';
    }
  }

  Color _senhaBarColor(int index) {
    final nivel = switch (_forcaSenha.$1) {
      'Forte' => 3,
      'Média' => 2,
      'Fraca' => 1,
      _ => 0,
    };
    if (index >= nivel) return AppColors.border;
    return switch (nivel) {
      3 => AppColors.green,
      2 => const Color(0xFFF59E0B),
      _ => Colors.redAccent,
    };
  }

  Future<void> _cadastrar() async {
    if (_nome.text.trim().isEmpty || _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha ao menos o nome e o e-mail.')),
      );
      return;
    }
    if (_senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crie uma senha para continuar.')),
      );
      return;
    }
    if (_senha.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha precisa de pelo menos 8 caracteres.'),
        ),
      );
      return;
    }
    if (_senha.text != _senhaConfirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas digitadas não conferem.')),
      );
      return;
    }
    if (!_terms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aceite os Termos de Transporte para continuar.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    await StudentStorage.saveAluno(
      nome: _nome.text.trim(),
      email: _email.text.trim(),
      ra: _ra.text.trim(),
      cpf: _cpf.text.trim(),
      whatsapp: _whatsapp.text.trim(),
      instituicao: _instituicao.text.trim(),
      turno: _turnos[_turno].$3,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AlunoMainScreen()),
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
              const RegistrationTopBar(
                title: 'Cadastro De Aluno',
                progressColor: AppColors.green,
              ),
              const SizedBox(height: 18),
              const InfoCard(
                icon: Icons.school,
                title: 'Passe Estudantil Ativo',
                body: 'Preencha seus dados acadêmicos para ter acesso às rotas do programa de embarque por verificação facial rápida.',
              ),
              const SizedBox(height: 24),
              _buildPhotoSection(),
              const SizedBox(height: 26),
              const SectionHeader(
                icon: Icons.badge_outlined,
                title: 'Dados Acadêmicos',
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Nome Completo',
                child: BusFlowTextField(
                  hint: 'Nome e sobrenome oficial',
                  icon: Icons.person_outline,
                  controller: _nome,
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'E-mail Acadêmico ou Pessoal',
                child: BusFlowTextField(
                  hint: 'aluno@universidade.edu.br',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  controller: _email,
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Matrícula Acadêmica (RA)',
                child: BusFlowTextField(
                  hint: 'Ex: 2024100849',
                  icon: Icons.badge_outlined,
                  controller: _ra,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: LabeledField(
                      label: 'CPF',
                      child: BusFlowTextField(
                        hint: '000.000.000-00',
                        icon: Icons.credit_card_outlined,
                        keyboardType: TextInputType.number,
                        controller: _cpf,
                        onChanged: _onCpfChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LabeledField(
                      label: 'WhatsApp',
                      child: BusFlowTextField(
                        hint: '(00) 90000-0000',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _whatsapp,
                        onChanged: _onWhatsChanged,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Instituição de Ensino',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BusFlowTextField(
                      hint: 'Selecione seu campus / faculdade',
                      icon: Icons.apartment_outlined,
                      controller: _instituicao,
                      onChanged: _onInstituicaoChanged,
                      suffix: Icon(
                        _sugestoesAbertas
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 22,
                        color: AppColors.textGray,
                      ),
                    ),
                    _buildSugestoesInstituicao(),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const SectionHeader(
                icon: Icons.lock_outline,
                title: 'Segurança de Acesso',
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Criar Senha de Acesso',
                child: PasswordField(
                  hint: 'Mínimo 8 caracteres',
                  controller: _senha,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Força da senha: ',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textGray),
                  ),
                  Text(
                    _forcaSenha.$1,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: _forcaSenha.$2,
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    child: Text(
                      _dicaSenha,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.hintGray,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _senhaBarColor(i),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Confirmar Senha',
                child: PasswordField(
                  hint: 'Repita a senha digitada',
                  controller: _senhaConfirm,
                ),
              ),
              const SizedBox(height: 26),
              const SectionHeader(
                icon: Icons.schedule,
                title: 'Turno de Aulas Habitual',
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecione o turno principal para priorizar nas rotas.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textGray),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var i = 0; i < _turnos.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    TurnCard(
                      icon: _turnos[i].$1,
                      iconColor: _turnos[i].$2,
                      title: _turnos[i].$3,
                      time: _turnos[i].$4,
                      selected: _turno == i,
                      onTap: () => setState(() => _turno = i),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 26),
              TermCheckbox(
                value: _terms,
                onChanged: (v) => setState(() => _terms = v ?? false),
                title: 'Concordo com os Termos de Transporte Universitário',
                body: 'Declaro que os dados fornecidos são verídicos e que utilizei meus dados corretamente para os embarques, bem como, com as regras de assentos e reservas dos ônibus.',
              ),
              const SizedBox(height: 24),
              PrimarySubmitButton(
                label: _saving ? 'Salvando...' : 'Cadastrar Aluno',
                icon: Icons.school,
                onPressed: _saving ? null : _cadastrar,
              ),
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 15, color: AppColors.green),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Seus dados são protegidos e validados junto à secretaria de educação.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textGray,
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

  Widget _buildSugestoesInstituicao() {
    if (!_sugestoesAbertas) return const SizedBox.shrink();
    final sugestoes = _sugestoesInstituicao;
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
                        'Nenhuma instituição encontrada para '
                        '"${_instituicaoQuery.trim()}"',
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
                    onTap: () => _selecionarInstituicao(nome),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              nome,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
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

  Widget _buildPhotoSection() {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 130,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
                ),
                child: const Icon(
                  Icons.photo_camera,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                top: 66,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_camera, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'TIRAR FOTO',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 2,
                top: 74,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, size: 15, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              'Foto para Reconhecimento Facial',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            'Tire uma foto nítida e iluminada do seu rosto, sem óculos escuros ou boné, para verificação imediata na catraca dos ônibus.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textGray,
            ),
          ),
        ),
      ],
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

String _formatarCelular(String digitos) {
  if (digitos.isEmpty) return '';
  if (digitos.length == 1) return '($digitos';
  if (digitos.length <= 2) return '($digitos)';
  final ddd = digitos.substring(0, 2);
  final resto = digitos.substring(2);
  if (resto.length <= 5) return '($ddd) $resto';
  return '($ddd) ${resto.substring(0, 5)}-${resto.substring(5)}';
}

String _normalizarTexto(String texto) {
  var normal = texto.toLowerCase();
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
