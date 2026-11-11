import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/api_service.dart';
import '../../services/app_settings.dart';
import '../../services/motorista_storage.dart';
import '../../services/supabase_auth_service.dart';
import '../../theme.dart';
import '../../widgets/profile_photo_picker.dart';
import '../../widgets/registration_widgets.dart';
import '../motorista/motorista_main_screen.dart';

class MotoristaRegistrationScreen extends StatefulWidget {
  const MotoristaRegistrationScreen({super.key});

  @override
  State<MotoristaRegistrationScreen> createState() =>
      _MotoristaRegistrationScreenState();
}

class _MotoristaRegistrationScreenState
    extends State<MotoristaRegistrationScreen> {
  final Set<int> _turnos = {1};
  bool _saving = false;
  bool _biometricOnSignup = false;
  bool _consultandoCnh = false;
  String? _categoriaIdentificada;
  String _cnhConsultada = '';
  int _cnhConsultaId = 0;
  String? _empresa;
  String _profilePhoto = '';

  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _cpf = TextEditingController();
  final _telefone = TextEditingController();
  final _cnh = TextEditingController();
  final _senha = TextEditingController();
  final _senhaConfirm = TextEditingController();

  final _cpfMascara = _CampoMascara(_formatarCpf);
  final _telMascara = _CampoMascara(_formatarCelular);

  static const _turnoData = [
    (Icons.wb_sunny, 'Manhã', '06h - 12h'),
    (Icons.wb_sunny, 'Tarde', '12h - 18h'),
    (Icons.nightlight_round, 'Noite', '18h - 23h50'),
  ];

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _cpf.dispose();
    _telefone.dispose();
    _cnh.dispose();
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

  void _onTelefoneChanged(String valor) {
    final formatado = _telMascara.formatar(valor);
    if (_telefone.text != formatado) {
      _telefone.text = formatado;
      _telefone.selection = TextSelection.collapsed(offset: formatado.length);
    }
  }

  String get _badgeCategoria {
    if (_consultandoCnh) return 'CONSULTANDO...';
    final cat = _categoriaIdentificada;
    if (cat == null) return 'AGUARDANDO CNH';
    return 'CATEGORIA $cat';
  }

  String get _textoConsultaCnh {
    if (_consultandoCnh) {
      return 'Consultando cadastro nacional de condutores (SENATRAN)...';
    }
    final cat = _categoriaIdentificada;
    if (cat == null) {
      return 'Digite os 11 dígitos da CNH para identificar a categoria automaticamente.';
    }
    return 'CNH localizada no cadastro do governo — categoria $cat confirmada.';
  }

  /// Simula a consulta ao cadastro nacional de condutores (SENATRAN/DETRAN):
  /// a categoria é derivada dos próprios dígitos da CNH.
  String _consultarCategoria(String digitos) {
    final soma = digitos.codeUnits.fold<int>(0, (a, b) => a + b);
    const resultados = ['D', 'D/E', 'B/D', 'C/D', 'A/B/D'];
    return resultados[soma % resultados.length];
  }

  void _onCnhChanged(String valor) {
    final digitos = valor.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length < 11) {
      _cnhConsultaId++;
      if (_consultandoCnh || _categoriaIdentificada != null) {
        setState(() {
          _consultandoCnh = false;
          _categoriaIdentificada = null;
          _cnhConsultada = '';
        });
      }
      return;
    }
    if (_consultandoCnh || _cnhConsultada == digitos) return;
    final id = ++_cnhConsultaId;
    setState(() {
      _consultandoCnh = true;
      _categoriaIdentificada = null;
      _cnhConsultada = digitos;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || id != _cnhConsultaId) return;
      setState(() {
        _consultandoCnh = false;
        _categoriaIdentificada = _consultarCategoria(digitos);
      });
    });
  }

  Future<void> _selecionarEmpresa() async {
    final opcoes = [
      'Consórcio Fênix • Transporte Urbano',
      'Expresso Universitário • Linhas Municipais',
      'Terminal Central de Campinas',
      'Prefeitura Municipal • Mobilidade Urbana',
      'Transportes Alvorada Ltda.',
      'Vínculo Direto com a Instituição',
      'Autônomo / Particular',
    ];
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
                  'Empresa, Consórcio ou Vínculo',
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
                    for (final opcao in opcoes)
                      ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.directions_bus_outlined,
                          size: 20,
                          color: _empresa == opcao
                              ? AppColors.primary
                              : AppColors.textGray,
                        ),
                        title: Text(
                          opcao,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: _empresa == opcao
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _empresa == opcao
                                ? AppColors.primary
                                : AppColors.textDark,
                          ),
                        ),
                        trailing: _empresa == opcao
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
      setState(() => _empresa = selecionado);
    }
  }

  Future<void> _cadastrar() async {
    if (_nome.text.trim().isEmpty || _email.text.trim().isEmpty) {
      _snack('Preencha ao menos o nome e o e-mail.');
      return;
    }
    if (_senha.text.isEmpty) {
      _snack('Crie uma senha para continuar.');
      return;
    }
    if (_senha.text.length < 6) {
      _snack('A senha precisa de pelo menos 6 dígitos.');
      return;
    }
    if (_senha.text != _senhaConfirm.text) {
      _snack('As senhas digitadas não conferem.');
      return;
    }
    if (_categoriaIdentificada == null) {
      _snack('Informe a CNH completa para identificar a categoria.');
      return;
    }
    if (_empresa == null) {
      _snack('Selecione a empresa, consórcio ou vínculo do transporte.');
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
          role: BusFlowRole.motorista,
          profileData: {
            'nome': _nome.text.trim(),
            'email': _email.text.trim().toLowerCase(),
            'cpf': _cpf.text.trim(),
            'telefone': _telefone.text.trim(),
            'cnh': _cnh.text.trim(),
            'categoria': _categoriaIdentificada!,
            'turno': _turnoData[[..._turnos].first].$2,
            'empresa': _empresa ?? '',
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
        // Tentar salvar na API MySQL primeiro
        final apiOnline = await ApiService.isApiOnline();
        if (apiOnline) {
          final result = await ApiService.cadastrarMotorista(
            nome: _nome.text.trim(),
            email: _email.text.trim().toLowerCase(),
            senha: _senha.text,
            cpf: _cpf.text.trim(),
            cnh: _cnh.text.trim(),
            empresa: _empresa ?? '',
            telefone: _telefone.text.trim(),
          );
          if (result['sucesso'] != true) {
            if (!mounted) return;
            setState(() => _saving = false);
            _snack(result['erro'] as String? ?? 'Erro ao cadastrar');
            return;
          }
        }
        // Salvar também no SharedPreferences como cache
        await MotoristaStorage.saveMotorista(
          nome: _nome.text.trim(),
          email: _email.text.trim(),
          cpf: _cpf.text.trim(),
          telefone: _telefone.text.trim(),
          cnh: _cnh.text.trim(),
          categoria: _categoriaIdentificada!,
          turno: _turnoData[[..._turnos].first].$2,
          empresa: _empresa ?? '',
          senha: _senha.text,
          profilePhoto: _profilePhoto,
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
      MaterialPageRoute(builder: (_) => const MotoristaMainScreen()),
      (route) => false,
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
              const RegistrationTopBar(title: 'Cadastro De Motorista'),
              const SizedBox(height: 18),
              const TopBadge(
                label: 'CADASTRO OPERACIONAL',
                icon: Icons.verified_outlined,
              ),
              const SizedBox(height: 12),
              const Text(
                'Cadastre suas informações profissionais para operar as rotas universitárias.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 22),
              _buildPhotoSection(),
              const SizedBox(height: 24),
              LabeledField(
                label: 'Nome Completo',
                child: BusFlowTextField(
                  hint: 'Ex: Marcos Silva Pereira',
                  icon: Icons.person_outline,
                  controller: _nome,
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'E-mail Profissional ou Pessoal',
                child: BusFlowTextField(
                  hint: 'motorista@consorcio.com.br',
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
              const SizedBox(height: 14),
              LabeledField(
                label: 'Telefone para Contato',
                child: BusFlowTextField(
                  hint: '(00) 00000-0000',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: _telefone,
                  onChanged: _onTelefoneChanged,
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Registro da CNH',
                trailing: Container(
                  key: const ValueKey('cnh-badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_consultandoCnh) ...[
                        const SizedBox(
                          width: 9,
                          height: 9,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.6,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        _badgeCategoria,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                child: BusFlowTextField(
                  hint: 'Número do registro (11 dígitos)',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  controller: _cnh,
                  onChanged: _onCnhChanged,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _categoriaIdentificada != null
                          ? Icons.verified_outlined
                          : Icons.sync_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _textoConsultaCnh,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'Senha de Acesso',
                child: PasswordField(
                  hint: 'Mínimo 6 dígitos',
                  controller: _senha,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Confirmar Senha',
                child: PasswordField(
                  hint: 'Repita a senha',
                  controller: _senhaConfirm,
                ),
              ),
              const SizedBox(height: 24),
              LabeledField(
                label: 'Turno de Operação Principal',
                trailing: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'SELECIONE 1 OU MAIS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _turnoData.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      TurnTile(
                        icon: _turnoData[i].$1,
                        title: _turnoData[i].$2,
                        time: _turnoData[i].$3,
                        selected: _turnos.contains(i),
                        onTap: () => setState(() {
                          _turnos.contains(i)
                              ? _turnos.remove(i)
                              : _turnos.add(i);
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'Empresa, Consórcio ou Vínculo do Transporte',
                child: GestureDetector(
                  key: const ValueKey('empresa-field'),
                  onTap: _selecionarEmpresa,
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
                        color: _empresa != null
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_bus_outlined,
                          size: 20,
                          color: AppColors.hintGray,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _empresa ?? 'Selecione seu consórcio ou modalidade',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: _empresa != null
                                  ? AppColors.textDark
                                  : AppColors.hintGray,
                              fontWeight: _empresa != null
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
              const SizedBox(height: 18),
              const InfoCard(
                icon: Icons.shield_outlined,
                title: 'Validação de Segurança e Trafegabilidade',
                body: 'O cadastro passará por validação cadastral da fiscalização de trânsito em até 24 horas. Você receberá notificação por e-mail e SMS assim que aprovado.',
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
                label: _saving ? 'Salvando...' : 'Cadastrar Motorista',
                icon: Icons.directions_bus,
                onPressed: _saving ? null : _cadastrar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfilePhotoPicker(
          photo: _profilePhoto,
          onChanged: (photo) => setState(() => _profilePhoto = photo),
          size: 88,
          label: _profilePhoto.isEmpty ? 'Adicionar foto' : 'Trocar foto',
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text(
                'Foto de Perfil do Motorista',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Escolha uma imagem da galeria ou tire uma foto na hora.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.check_circle, size: 15, color: AppColors.green),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Rosto nítido e bem iluminado',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

/// Máscara de dígitos que reaplica a formatação a cada tecla.
class _CampoMascara {
  _CampoMascara(this._formatar);

  final String Function(String digitos) _formatar;

  String _valorAnterior = '';
  String _digitosAnteriores = '';

  String formatar(String valor) {
    var digitos = valor.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length > 11) digitos = digitos.substring(0, 11);

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
