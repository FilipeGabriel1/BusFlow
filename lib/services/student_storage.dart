import 'dart:math';

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
  static const _kQrId = 'aluno_qr_id';
  static const _kProfilePhoto = 'aluno_profile_photo';

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
    String profilePhoto = '',
    String? qrId,
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
    await prefs.setString(_kProfilePhoto, profilePhoto);
    await prefs.setString(_kQrId, qrId ?? _generateQrId());
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
      'qrId': prefs.getString(_kQrId) ?? '',
      'profilePhoto': prefs.getString(_kProfilePhoto) ?? '',
    };
  }

  static Future<String> getOrCreateQrId() async {
    final prefs = await SharedPreferences.getInstance();
    return _ensureQrId(prefs);
  }

  static Future<void> updateProfile({
    required Map<String, String> fields,
    required String profilePhoto,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    const keys = {
      'nome': _kNome,
      'email': _kEmail,
      'ra': _kRa,
      'cpf': _kCpf,
      'whatsapp': _kWhatsapp,
      'instituicao': _kInstituicao,
      'turno': _kTurno,
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

  static Future<String> _ensureQrId(SharedPreferences prefs) async {
    final existing = prefs.getString(_kQrId);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _generateQrId();
    await prefs.setString(_kQrId, id);
    return id;
  }

  static String _generateQrId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  static String createQrId() => _generateQrId();

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
