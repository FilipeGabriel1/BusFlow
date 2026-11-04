import 'package:shared_preferences/shared_preferences.dart';

class AdminStorage {
  AdminStorage._();

  static const _kRegistered = 'admin_registered';
  static const _kNome = 'admin_nome';
  static const _kEmail = 'admin_email';
  static const _kCpf = 'admin_cpf';
  static const _kOrgao = 'admin_orgao';
  static const _kCargo = 'admin_cargo';
  static const _kChave = 'admin_chave';
  static const _kSenha = 'admin_senha';

  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kRegistered) ?? false;
  }

  static Future<void> saveAdmin({
    required String nome,
    required String email,
    String cpf = '',
    String orgao = '',
    String cargo = '',
    String chave = '',
    required String senha,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRegistered, true);
    await prefs.setString(_kNome, nome);
    await prefs.setString(_kEmail, email);
    await prefs.setString(_kCpf, cpf);
    await prefs.setString(_kOrgao, orgao);
    await prefs.setString(_kCargo, cargo);
    await prefs.setString(_kChave, chave);
    await prefs.setString(_kSenha, senha);
  }

  static Future<Map<String, String>> getAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nome': prefs.getString(_kNome) ?? '',
      'email': prefs.getString(_kEmail) ?? '',
      'cpf': prefs.getString(_kCpf) ?? '',
      'orgao': prefs.getString(_kOrgao) ?? '',
      'cargo': prefs.getString(_kCargo) ?? '',
      'chave': prefs.getString(_kChave) ?? '',
      'senha': prefs.getString(_kSenha) ?? '',
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRegistered);
    await prefs.remove(_kNome);
    await prefs.remove(_kEmail);
    await prefs.remove(_kCpf);
    await prefs.remove(_kOrgao);
    await prefs.remove(_kCargo);
    await prefs.remove(_kChave);
    await prefs.remove(_kSenha);
  }
}
