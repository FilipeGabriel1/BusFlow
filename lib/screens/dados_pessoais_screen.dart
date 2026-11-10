import 'package:flutter/material.dart';

import '../services/account_profile.dart';
import '../services/admin_storage.dart';
import '../services/motorista_storage.dart';
import '../services/student_storage.dart';
import '../services/supabase_auth_service.dart';
import '../theme.dart';
import '../widgets/profile_photo_picker.dart';

class DadosPessoaisScreen extends StatefulWidget {
  const DadosPessoaisScreen({super.key, required this.profileKind});

  final ProfileKind profileKind;

  @override
  State<DadosPessoaisScreen> createState() => _DadosPessoaisScreenState();
}

class _DadosPessoaisScreenState extends State<DadosPessoaisScreen> {
  late final Map<String, TextEditingController> _controllers = {
    for (final field in _fields) field: TextEditingController(),
  };
  String _photo = '';
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  List<String> get _fields => switch (widget.profileKind) {
    ProfileKind.aluno => [
      'nome',
      'email',
      'ra',
      'cpf',
      'whatsapp',
      'instituicao',
      'turno',
    ],
    ProfileKind.motorista => [
      'nome',
      'email',
      'cpf',
      'telefone',
      'cnh',
      'categoria',
      'turno',
      'empresa',
    ],
    ProfileKind.admin => ['nome', 'email', 'cpf', 'orgao', 'cargo'],
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final data = switch (widget.profileKind) {
        ProfileKind.aluno => await StudentStorage.getAluno(),
        ProfileKind.motorista => await MotoristaStorage.getMotorista(),
        ProfileKind.admin => await AdminStorage.getAdmin(),
      };
      if (!mounted) return;
      for (final entry in _controllers.entries) {
        entry.value.text = data[entry.key] ?? '';
      }
      setState(() {
        _photo = data['profilePhoto'] ?? '';
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Não foi possível carregar seus dados: $error';
      });
    }
  }

  Future<void> _save() async {
    final name = _controllers['nome']!.text.trim();
    final email = _controllers['email']!.text.trim();
    if (name.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _message('Informe seu nome e um e-mail válido.');
      return;
    }
    setState(() => _saving = true);
    try {
      final fields = {
        for (final entry in _controllers.entries)
          entry.key: entry.value.text.trim(),
      };
      final emailConfirmationPending =
          await SupabaseAuthService.updateCurrentProfileData(fields);
      switch (widget.profileKind) {
        case ProfileKind.aluno:
          await StudentStorage.updateProfile(
            fields: fields,
            profilePhoto: _photo,
          );
          break;
        case ProfileKind.motorista:
          await MotoristaStorage.updateProfile(
            fields: fields,
            profilePhoto: _photo,
          );
          break;
        case ProfileKind.admin:
          await AdminStorage.updateProfile(
            fields: fields,
            profilePhoto: _photo,
          );
          break;
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      if (emailConfirmationPending) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Confirme a alteração do e-mail pelo link enviado à sua caixa postal.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) _message('Não foi possível salvar seus dados: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _label(String field) => switch (field) {
    'nome' => 'Nome completo',
    'email' => 'E-mail',
    'ra' => 'Matrícula / RA',
    'cpf' => 'CPF',
    'whatsapp' => 'WhatsApp',
    'instituicao' => 'Instituição',
    'turno' => 'Turno',
    'telefone' => 'Telefone',
    'cnh' => 'CNH',
    'categoria' => 'Categoria',
    'empresa' => 'Empresa / vínculo',
    'orgao' => 'Órgão',
    'cargo' => 'Cargo',
    _ => field,
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primaryDark,
      elevation: 0,
      title: const Text(
        'Dados Pessoais',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _loadError != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_loadError!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loadProfile,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          )
        : SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Center(
                  child: ProfilePhotoPicker(
                    photo: _photo,
                    onChanged: (photo) => setState(() => _photo = photo),
                    size: 112,
                    label: 'Alterar foto',
                  ),
                ),
                const SizedBox(height: 12),
                ..._fields.map(
                  (field) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TextField(
                      controller: _controllers[field],
                      keyboardType: field == 'email'
                          ? TextInputType.emailAddress
                          : TextInputType.text,
                      textCapitalization: field == 'email'
                          ? TextCapitalization.none
                          : TextCapitalization.words,
                      autocorrect: field != 'email',
                      decoration: InputDecoration(
                        labelText: _label(field),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Salvar alterações',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
          ),
  );
}
