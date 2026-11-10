import 'dart:convert';

import 'package:http/http.dart' as http;

class PasswordRecoveryService {
  PasswordRecoveryService._();

  static const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static Uri get _endpoint {
    if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      throw StateError(
        'Configure SUPABASE_URL e SUPABASE_ANON_KEY para ativar a recuperação por e-mail.',
      );
    }
    return Uri.parse('$_supabaseUrl/functions/v1/password-recovery');
  }

  static Future<void> requestCode(String email) async {
    await _post({'action': 'request_code', 'email': email.trim()});
  }

  static Future<String> verifyCode({
    required String email,
    required String code,
  }) async {
    final response = await _post({
      'action': 'verify_code',
      'email': email.trim(),
      'code': code,
    });
    final token = response['resetToken'];
    if (token is! String || token.isEmpty) {
      throw const FormatException(
        'O servidor não retornou o token de redefinição.',
      );
    }
    return token;
  }

  static Future<void> consumeResetToken({
    required String token,
    required String password,
  }) async {
    await _post({
      'action': 'complete_reset',
      'resetToken': token,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> _post(Map<String, String> body) async {
    final response = await http
        .post(
          _endpoint,
          headers: {
            'Content-Type': 'application/json',
            'apikey': _supabaseAnonKey,
            'Authorization': 'Bearer $_supabaseAnonKey',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Resposta inválida do serviço de recuperação.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded['error'];
      throw Exception(
        message is String && message.isNotEmpty
            ? message
            : 'Não foi possível concluir a recuperação da senha.',
      );
    }
    return decoded;
  }
}
