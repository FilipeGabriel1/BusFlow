import 'package:flutter/material.dart';

import '../services/app_settings.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'password_recovery_screen.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleBiometrics(BuildContext context, bool enabled) async {
    try {
      if (enabled) {
        final activated = await AppSettings.instance.enableBiometrics();
        if (!context.mounted) return;
        _message(
          context,
          activated ? 'Biometria ativada neste aparelho.' : 'O aparelho não possui biometria disponível ou a autenticação foi cancelada.',
        );
      } else {
        await AppSettings.instance.disableBiometrics();
        if (context.mounted) _message(context, 'Biometria desativada.');
      }
    } catch (error) {
      if (context.mounted) {
        _message(context, 'Não foi possível configurar a biometria: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Segurança'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.password_outlined),
              title: const Text('Senha'),
              subtitle: const Text('Solicitar redefinição por e-mail'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ForgotPasswordScreen(),
                ),
              ),
            ),
          ),
          Card(
            child: ListenableBuilder(
              listenable: AppSettings.instance,
              builder: (context, _) => SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Biometria'),
                subtitle: const Text(
                  'Usa a autenticação segura do sistema do aparelho.',
                ),
                value: AppSettings.instance.biometricEnabled,
                onChanged: (value) => _toggleBiometrics(context, value),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.devices_outlined),
              title: const Text('Sessões'),
              subtitle: const Text('Este aparelho • sessão atual'),
              trailing: TextButton(
                onPressed: () => Navigator.of(context, rootNavigator: true)
                    .pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    ),
                child: const Text('Encerrar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
