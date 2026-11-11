import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_storage.dart';
import 'motorista_storage.dart';
import 'student_storage.dart';

enum BusFlowRole { aluno, motorista, admin }

class SupabaseAuthService {
  SupabaseAuthService._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (!isConfigured) return;
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  }

  static String roleValue(BusFlowRole role) => switch (role) {
    BusFlowRole.aluno => 'student',
    BusFlowRole.motorista => 'driver',
    BusFlowRole.admin => 'admin',
  };

  static Future<bool> signUp({
    required String email,
    required String password,
    required BusFlowRole role,
    required Map<String, String> profileData,
  }) async {
    final data = Map<String, String>.from(profileData);
    if (role == BusFlowRole.aluno) {
      data['qrId'] ??= StudentStorage.createQrId();
    }
    final response = await client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {
        'display_name': data['nome'] ?? '',
        'requested_role': roleValue(role),
        'profile_data': data,
      },
    );
    if (response.session == null || response.user == null) return false;
    final profile = await client
        .from('user_profiles')
        .select('role, requested_role, profile_data, status')
        .eq('id', response.user!.id)
        .maybeSingle();
    if (profile == null) {
      await client.auth.signOut();
      throw const AuthException(
        'Conta criada, mas o perfil não foi criado. Aplique as migrações do Supabase.',
      );
    }
    try {
      _ensureCanEnter(profile);
    } on AuthException {
      await client.auth.signOut();
      rethrow;
    }
    data['email'] = email.trim().toLowerCase();
    await _cacheProfile(role, data);
    return true;
  }

  static Future<BusFlowRole> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException(
        'O servidor não retornou o usuário autenticado.',
      );
    }

    final profile = await client
        .from('user_profiles')
        .select('role, requested_role, profile_data, status')
        .eq('id', user.id)
        .maybeSingle();
    if (profile == null) {
      await client.auth.signOut();
      throw const AuthException(
        'Perfil não encontrado. Aplique as migrações do Supabase e tente novamente.',
      );
    }
    try {
      _ensureCanEnter(profile);
    } on AuthException {
      await client.auth.signOut();
      rethrow;
    }

    final role = _parseRole(profile['role']);
    final rawData = profile['profile_data'];
    final profileData = rawData is Map
        ? rawData.map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          )
        : <String, String>{};
    profileData['email'] = user.email ?? email.trim().toLowerCase();
    profileData['nome'] = profileData['nome']?.isNotEmpty == true
        ? profileData['nome']!
        : user.userMetadata?['display_name']?.toString() ?? '';
    await _cacheProfile(role, profileData);
    return role;
  }

  static Future<BusFlowRole?> currentRole() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final profile = await client
        .from('user_profiles')
        .select('requested_role, profile_data, status')
        .eq('id', user.id)
        .maybeSingle();
    if (profile == null) return null;
    _ensureCanEnter(profile);
    final role = _parseRole(profile['role']);
    final rawData = profile['profile_data'];
    final profileData = rawData is Map
        ? rawData.map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          )
        : <String, String>{};
    profileData['email'] = user.email ?? '';
    await _cacheProfile(role, profileData);
    return role;
  }

  static Future<void> signOut() async {
    if (isConfigured) await client.auth.signOut();
  }

  static Future<bool> updateCurrentProfileData(
    Map<String, String> fields,
  ) async {
    if (!isConfigured || client.auth.currentUser == null) return false;
    final user = client.auth.currentUser!;
    final existing = await client
        .from('user_profiles')
        .select('profile_data')
        .eq('id', user.id)
        .single();
    final rawData = existing['profile_data'];
    final profileData = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};
    final email = fields['email']?.trim().toLowerCase();
    final emailChanged =
        email != null && email.isNotEmpty && email != user.email;
    if (emailChanged) {
      await client.auth.updateUser(UserAttributes(email: email));
    }
    final profileFields = Map<String, String>.from(fields)..remove('email');
    profileData.addAll(profileFields);
    await client
        .from('user_profiles')
        .update({
          'display_name': profileFields['nome'] ?? profileData['nome'] ?? '',
          'profile_data': profileData,
        })
        .eq('id', user.id);
    return emailChanged;
  }

  static BusFlowRole _parseRole(Object? value) => switch (value) {
    'driver' => BusFlowRole.motorista,
    'admin' => BusFlowRole.admin,
    _ => BusFlowRole.aluno,
  };

  static void _ensureCanEnter(Map<String, dynamic> profile) {
    if (profile['status'] == 'pending') {
      throw const AuthException(
        'Seu cadastro aguarda aprovação da administração antes do acesso.',
      );
    }
    if (profile['status'] == 'blocked') {
      throw const AuthException(
        'Esta conta está bloqueada. Entre em contato com a administração.',
      );
    }
    if (profile['role'] != profile['requested_role']) {
      throw const AuthException(
        'O cadastro aguarda aprovação da administração antes do acesso.',
      );
    }
  }

  static Future<void> _cacheProfile(
    BusFlowRole role,
    Map<String, String> data,
  ) async {
    final name = data['nome'] ?? '';
    final email = data['email'] ?? '';
    switch (role) {
      case BusFlowRole.aluno:
        await StudentStorage.saveAluno(
          nome: name,
          email: email,
          ra: data['ra'] ?? '',
          cpf: data['cpf'] ?? '',
          whatsapp: data['whatsapp'] ?? '',
          instituicao: data['instituicao'] ?? '',
          turno: data['turno'] ?? '',
          senha: '',
          qrId: data['qrId'],
        );
      case BusFlowRole.motorista:
        await MotoristaStorage.saveMotorista(
          nome: name,
          email: email,
          cpf: data['cpf'] ?? '',
          telefone: data['telefone'] ?? '',
          cnh: data['cnh'] ?? '',
          categoria: data['categoria'] ?? '',
          turno: data['turno'] ?? '',
          empresa: data['empresa'] ?? '',
          senha: '',
        );
      case BusFlowRole.admin:
        await AdminStorage.saveAdmin(
          nome: name,
          email: email,
          cpf: data['cpf'] ?? '',
          orgao: data['orgao'] ?? '',
          cargo: data['cargo'] ?? '',
          senha: '',
        );
    }
  }
}
