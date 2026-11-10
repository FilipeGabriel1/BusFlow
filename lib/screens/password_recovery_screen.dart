import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/account_profile.dart';
import '../services/password_recovery_service.dart';
import '../services/supabase_auth_service.dart';
import '../theme.dart';
import 'admin/admin_main_screen.dart';
import 'aluno/aluno_main_screen.dart';
import 'motorista/motorista_main_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _message('Informe um endereço de e-mail válido.');
      return;
    }
    setState(() => _sending = true);
    try {
      final account = await findAccountByEmail(email);
      if (account == null) {
        _message(
          'Não encontramos uma conta com esse e-mail neste dispositivo.',
        );
        return;
      }
      await PasswordRecoveryService.requestCode(email);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VerifyRecoveryCodeScreen(account: account),
        ),
      );
    } catch (error) {
      if (mounted) _message('Não foi possível enviar o código: $error');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => _RecoveryScaffold(
    title: 'Recuperar senha',
    step: '1 de 3',
    subtitle: 'Informe o e-mail usado no cadastro. Enviaremos um código de 6 dígitos.',
    children: [
      _RecoveryField(
        label: 'E-mail cadastrado',
        controller: _email,
        hint: 'seu@email.com',
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 20),
      _RecoveryButton(
        label: 'Enviar código',
        loading: _sending,
        onPressed: _sendCode,
      ),
    ],
  );
}

class VerifyRecoveryCodeScreen extends StatefulWidget {
  const VerifyRecoveryCodeScreen({super.key, required this.account});

  final AccountProfile account;

  @override
  State<VerifyRecoveryCodeScreen> createState() =>
      _VerifyRecoveryCodeScreenState();
}

class _VerifyRecoveryCodeScreenState extends State<VerifyRecoveryCodeScreen> {
  final _code = TextEditingController();
  bool _verifying = false;
  bool _resending = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_code.text.length != 6) {
      _message('Digite o código de 6 dígitos.');
      return;
    }
    setState(() => _verifying = true);
    try {
      final token = await PasswordRecoveryService.verifyCode(
        email: widget.account.email,
        code: _code.text,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              ResetPasswordScreen(account: widget.account, resetToken: token),
        ),
      );
    } catch (error) {
      if (mounted) _message('Código inválido ou expirado: $error');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await PasswordRecoveryService.requestCode(widget.account.email);
      if (mounted) _message('Se o prazo permitir, um novo código foi enviado.');
    } catch (error) {
      if (mounted) _message('Não foi possível reenviar: $error');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => _RecoveryScaffold(
    title: 'Confirmar código',
    step: '2 de 3',
    subtitle:
        'Digite o código enviado para ${_maskEmail(widget.account.email)}. Ele expira em 15 minutos.',
    children: [
      _RecoveryField(
        label: 'Código de confirmação',
        controller: _code,
        hint: '000000',
        keyboardType: TextInputType.number,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: _resending ? null : _resend,
          child: Text(_resending ? 'Enviando...' : 'Reenviar código'),
        ),
      ),
      _RecoveryButton(
        label: 'Confirmar código',
        loading: _verifying,
        onPressed: _verify,
      ),
    ],
  );
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.account,
    required this.resetToken,
  });

  final AccountProfile account;
  final String resetToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_password.text.length < 6) {
      _message('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    if (_password.text != _confirmation.text) {
      _message('As senhas digitadas não conferem.');
      return;
    }
    setState(() => _saving = true);
    try {
      if (SupabaseAuthService.isConfigured) {
        await PasswordRecoveryService.consumeResetToken(
          token: widget.resetToken,
          password: _password.text,
        );
        final role = await SupabaseAuthService.signIn(
          email: widget.account.email,
          password: _password.text,
        );
        if (!mounted) return;
        final destination = switch (role) {
          BusFlowRole.admin => const AdminMainScreen(),
          BusFlowRole.motorista => const MotoristaMainScreen(),
          BusFlowRole.aluno => const AlunoMainScreen(),
        };
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => destination),
          (_) => false,
        );
        return;
      }
      await PasswordRecoveryService.consumeResetToken(
        token: widget.resetToken,
        password: _password.text,
      );
      await widget.account.updatePassword(_password.text);
      if (!mounted) return;
      final destination = switch (widget.account.kind) {
        ProfileKind.admin => const AdminMainScreen(),
        ProfileKind.motorista => const MotoristaMainScreen(),
        ProfileKind.aluno => const AlunoMainScreen(),
      };
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => destination),
        (_) => false,
      );
    } catch (error) {
      if (mounted) _message('Não foi possível redefinir a senha: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => _RecoveryScaffold(
    title: 'Criar nova senha',
    step: '3 de 3',
    subtitle: 'Defina uma nova senha para acessar sua conta BusFlow.',
    children: [
      _RecoveryField(
        label: 'Nova senha',
        controller: _password,
        hint: 'Mínimo de 6 caracteres',
        obscureText: true,
      ),
      const SizedBox(height: 14),
      _RecoveryField(
        label: 'Confirmar nova senha',
        controller: _confirmation,
        hint: 'Digite novamente',
        obscureText: true,
      ),
      const SizedBox(height: 20),
      _RecoveryButton(
        label: 'Salvar nova senha',
        loading: _saving,
        onPressed: _save,
      ),
    ],
  );
}

String _maskEmail(String email) {
  final parts = email.split('@');
  if (parts.length != 2 || parts.first.isEmpty) return email;
  final name = parts.first;
  final visible = name.length > 2 ? name.substring(0, 2) : name.substring(0, 1);
  return '$visible${List<String>.filled(name.length - visible.length, '*').join()}@${parts.last}';
}

class _RecoveryScaffold extends StatelessWidget {
  const _RecoveryScaffold({
    required this.title,
    required this.step,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String step;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primaryDark,
      elevation: 0,
      title: const Text(
        'BusFlow',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ETAPA $step',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _RecoveryField extends StatelessWidget {
  const _RecoveryField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.fieldBg,
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
    ],
  );
}

class _RecoveryButton extends StatelessWidget {
  const _RecoveryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    ),
  );
}
