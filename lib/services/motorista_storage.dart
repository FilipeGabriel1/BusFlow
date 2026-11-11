import 'package:shared_preferences/shared_preferences.dart';

class MotoristaStorage {
  MotoristaStorage._();

  static const _kRegistered = 'motorista_registered';
  static const _kNome = 'motorista_nome';
  static const _kEmail = 'motorista_email';
  static const _kCpf = 'motorista_cpf';
  static const _kTelefone = 'motorista_telefone';
  static const _kCnh = 'motorista_cnh';
  static const _kCategoria = 'motorista_categoria';
  static const _kTurno = 'motorista_turno';
  static const _kEmpresa = 'motorista_empresa';
  static const _kSenha = 'motorista_senha';
  static const _kProfilePhoto = 'motorista_profile_photo';

  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kRegistered) ?? false;
  }

  static Future<void> saveMotorista({
    required String nome,
    required String email,
    required String cpf,
    required String telefone,
    required String cnh,
    required String categoria,
    required String turno,
    String empresa = '',
    required String senha,
    String profilePhoto = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRegistered, true);
    await prefs.setString(_kNome, nome);
    await prefs.setString(_kEmail, email);
    await prefs.setString(_kCpf, cpf);
    await prefs.setString(_kTelefone, telefone);
    await prefs.setString(_kCnh, cnh);
    await prefs.setString(_kCategoria, categoria);
    await prefs.setString(_kTurno, turno);
    await prefs.setString(_kEmpresa, empresa);
    await prefs.setString(_kSenha, senha);
    await prefs.setString(_kProfilePhoto, profilePhoto);
  }

  static Future<Map<String, String>> getMotorista() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nome': prefs.getString(_kNome) ?? '',
      'email': prefs.getString(_kEmail) ?? '',
      'cpf': prefs.getString(_kCpf) ?? '',
      'telefone': prefs.getString(_kTelefone) ?? '',
      'cnh': prefs.getString(_kCnh) ?? '',
      'categoria': prefs.getString(_kCategoria) ?? '',
      'turno': prefs.getString(_kTurno) ?? '',
      'empresa': prefs.getString(_kEmpresa) ?? '',
      'senha': prefs.getString(_kSenha) ?? '',
      'profilePhoto': prefs.getString(_kProfilePhoto) ?? '',
    };
  }

  static Future<void> updateProfile({
    required Map<String, String> fields,
    required String profilePhoto,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    const keys = {
      'nome': _kNome,
      'email': _kEmail,
      'cpf': _kCpf,
      'telefone': _kTelefone,
      'cnh': _kCnh,
      'categoria': _kCategoria,
      'turno': _kTurno,
      'empresa': _kEmpresa,
    };
    for (final entry in fields.entries) {
      final key = keys[entry.key];
      if (key != null) await prefs.setString(key, entry.value);
    }
    await prefs.setString(_kProfilePhoto, profilePhoto);
  }

  static Future<void> updatePassword(String senha) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSenha, senha);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRegistered);
    await prefs.remove(_kNome);
    await prefs.remove(_kEmail);
    await prefs.remove(_kCpf);
    await prefs.remove(_kTelefone);
    await prefs.remove(_kCnh);
    await prefs.remove(_kCategoria);
    await prefs.remove(_kTurno);
    await prefs.remove(_kEmpresa);
    await prefs.remove(_kSenha);
    await prefs.remove(_kProfilePhoto);
  }
}
