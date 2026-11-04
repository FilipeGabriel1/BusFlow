import 'package:shared_preferences/shared_preferences.dart';

class StudentStorage {
  StudentStorage._();

  static const _kRegistered = 'aluno_registered';
  static const _kNome = 'aluno_nome';
  static const _kEmail = 'aluno_email';
  static const _kRa = 'aluno_ra';
  static const _kCpf = 'aluno_cpf';
  static const _kWhatsapp = 'aluno_whatsapp';
  static const _kInstituicao = 'aluno_instituicao';
  static const _kTurno = 'aluno_turno';
  static const _kSenha = 'aluno_senha';

  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kRegistered) ?? false;
  }

  static Future<void> saveAluno({
    required String nome,
    required String email,
    required String ra,
    required String cpf,
    required String whatsapp,
    required String instituicao,
    required String turno,
    required String senha,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRegistered, true);
    await prefs.setString(_kNome, nome);
    await prefs.setString(_kEmail, email);
    await prefs.setString(_kRa, ra);
    await prefs.setString(_kCpf, cpf);
    await prefs.setString(_kWhatsapp, whatsapp);
    await prefs.setString(_kInstituicao, instituicao);
    await prefs.setString(_kTurno, turno);
    await prefs.setString(_kSenha, senha);
  }

  static Future<Map<String, String>> getAluno() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nome': prefs.getString(_kNome) ?? '',
      'email': prefs.getString(_kEmail) ?? '',
      'ra': prefs.getString(_kRa) ?? '',
      'cpf': prefs.getString(_kCpf) ?? '',
      'whatsapp': prefs.getString(_kWhatsapp) ?? '',
      'instituicao': prefs.getString(_kInstituicao) ?? '',
      'turno': prefs.getString(_kTurno) ?? '',
      'senha': prefs.getString(_kSenha) ?? '',
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
