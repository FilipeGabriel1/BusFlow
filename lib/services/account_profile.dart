import 'admin_storage.dart';
import 'motorista_storage.dart';
import 'supabase_auth_service.dart';
import 'student_storage.dart';

enum ProfileKind { admin, motorista, aluno }

class AccountProfile {
  const AccountProfile({required this.kind, required this.email});

  final ProfileKind kind;
  final String email;

  Future<void> updatePassword(String password) async {
    switch (kind) {
      case ProfileKind.admin:
        await AdminStorage.updatePassword(password);
        break;
      case ProfileKind.motorista:
        await MotoristaStorage.updatePassword(password);
        break;
      case ProfileKind.aluno:
        await StudentStorage.updatePassword(password);
        break;
    }
  }
}

Future<AccountProfile?> findAccountByEmail(String email) async {
  final normalized = email.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  if (SupabaseAuthService.isConfigured) {
    return AccountProfile(kind: ProfileKind.aluno, email: normalized);
  }

  if (await AdminStorage.isRegistered()) {
    final account = await AdminStorage.getAdmin();
    if ((account['email'] ?? '').trim().toLowerCase() == normalized) {
      return AccountProfile(kind: ProfileKind.admin, email: normalized);
    }
  }
  if (await MotoristaStorage.isRegistered()) {
    final account = await MotoristaStorage.getMotorista();
    if ((account['email'] ?? '').trim().toLowerCase() == normalized) {
      return AccountProfile(kind: ProfileKind.motorista, email: normalized);
    }
  }
  if (await StudentStorage.isRegistered()) {
    final account = await StudentStorage.getAluno();
    if ((account['email'] ?? '').trim().toLowerCase() == normalized) {
      return AccountProfile(kind: ProfileKind.aluno, email: normalized);
    }
  }
  return null;
}
