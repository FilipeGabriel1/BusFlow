import 'dart:convert';
import 'package:http/http.dart' as http;

/// Serviço de comunicação com a API REST do BusFlow
class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';

  // ==================== AUTENTICAÇÃO ====================

  /// Login de aluno via API
  static Future<Map<String, dynamic>> loginAluno({
    required String senha,
    String? email,
    String? cpf,
  }) async {
    return _login('aluno', email: email, cpf: cpf, senha: senha);
  }

  /// Login de motorista via API
  static Future<Map<String, dynamic>> loginMotorista({
    required String senha,
    String? email,
    String? cpf,
  }) async {
    return _login('motorista', email: email, cpf: cpf, senha: senha);
  }

  /// Login de admin via API
  static Future<Map<String, dynamic>> loginAdmin({
    required String senha,
    String? email,
    String? cpf,
  }) async {
    return _login('admin', email: email, cpf: cpf, senha: senha);
  }

  static Future<Map<String, dynamic>> _login(
    String tipo, {
    String? email,
    String? cpf,
    required String senha,
  }) async {
    try {
      final body = <String, dynamic>{'senha': senha};
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (cpf != null && cpf.isNotEmpty) body['cpf'] = cpf;

      final response = await http
          .post(
            Uri.parse('$_baseUrl/login/$tipo'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['ok'] == true) {
          return {'sucesso': true, 'dados': data['dados'] as Map<String, dynamic>};
        }
      }
      if (response.statusCode == 401) {
        return {'sucesso': false, 'erro': 'Senha incorreta ou conta não encontrada'};
      }
      return {'sucesso': false, 'erro': 'Erro ao conectar ao servidor'};
    } catch (_) {
      // API indisponível — usar fallback local
      return {'sucesso': false, 'erro': 'API indisponível', 'offline': true};
    }
  }

  // ==================== CADASTRO ====================

  /// Cadastrar aluno via API
  static Future<Map<String, dynamic>> cadastrarAluno({
    required String nome,
    required String email,
    required String senha,
    String? cpf,
    String? ra,
    String? instituicao,
    String? telefone,
  }) async {
    return _cadastrar('alunos', {
      'nome': nome,
      'email': email,
      'senha': senha,
      if (cpf case final cpf?) 'cpf': cpf,
      if (ra case final ra?) 'ra': ra,
      if (instituicao case final inst?) 'instituicao': inst,
      if (telefone case final tel?) 'telefone': tel,
    });
  }

  /// Cadastrar motorista via API
  static Future<Map<String, dynamic>> cadastrarMotorista({
    required String nome,
    required String email,
    required String senha,
    String? cpf,
    String? cnh,
    String? empresa,
    String? telefone,
  }) async {
    return _cadastrar('motoristas', {
      'nome': nome,
      'email': email,
      'senha': senha,
      if (cpf case final cpf?) 'cpf': cpf,
      if (cnh case final cnh?) 'cnh': cnh,
      if (empresa case final emp?) 'empresa': emp,
      if (telefone case final tel?) 'telefone': tel,
    });
  }

  /// Cadastrar admin via API
  static Future<Map<String, dynamic>> cadastrarAdmin({
    required String nome,
    required String email,
    required String senha,
    String? cpf,
    String? cargo,
    String? orgao,
    String? chaveAdm,
  }) async {
    return _cadastrar('admins', {
      'nome': nome,
      'email': email,
      'senha': senha,
      if (cpf case final cpf?) 'cpf': cpf,
      if (cargo case final c?) 'cargo': c,
      if (orgao case final o?) 'orgao': o,
      if (chaveAdm case final ch?) 'chave_adm': ch,
    });
  }

  static Future<Map<String, dynamic>> _cadastrar(
    String rota,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/$rota'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['ok'] == true) {
          return {'sucesso': true, 'dados': data};
        }
        return {'sucesso': false, 'erro': data['erro'] as String? ?? 'Erro ao cadastrar'};
      }
      if (response.statusCode == 409) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {'sucesso': false, 'erro': data['erro'] as String? ?? 'Conta já existe'};
      }
      return {'sucesso': false, 'erro': 'Erro ao conectar ao servidor'};
    } catch (_) {
      return {'sucesso': false, 'erro': 'API indisponível', 'offline': true};
    }
  }

  // ==================== LISTAGENS ====================

  /// Listar alunos
  static Future<List<Map<String, dynamic>>> listarAlunos() async {
    return _listar('alunos');
  }

  /// Listar motoristas
  static Future<List<Map<String, dynamic>>> listarMotoristas() async {
    return _listar('motoristas');
  }

  /// Listar admins
  static Future<List<Map<String, dynamic>>> listarAdmins() async {
    return _listar('admins');
  }

  /// Listar veículos
  static Future<List<Map<String, dynamic>>> listarVeiculos() async {
    return _listar('veiculos');
  }

  /// Listar rotas
  static Future<List<Map<String, dynamic>>> listarRotas() async {
    return _listar('rotas');
  }

  /// Listar viagens
  static Future<List<Map<String, dynamic>>> listarViagens() async {
    return _listar('viagens');
  }

  /// Listar reservas
  static Future<List<Map<String, dynamic>>> listarReservas() async {
    return _listar('reservas');
  }

  /// Listar notificações
  static Future<List<Map<String, dynamic>>> listarNotificacoes() async {
    return _listar('notificacoes');
  }

  /// Listar alertas
  static Future<List<Map<String, dynamic>>> listarAlertas() async {
    return _listar('alertas');
  }

  /// Listar solicitações
  static Future<List<Map<String, dynamic>>> listarSolicitacoes() async {
    return _listar('solicitacoes');
  }

  static Future<List<Map<String, dynamic>>> _listar(String rota) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/$rota'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['ok'] == true) {
          final lista = data['dados'] as List<dynamic>;
          return lista.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ==================== STATUS ====================

  /// Verificar se a API está online
  static Future<bool> isApiOnline() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/status'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['ok'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
