import 'package:flutter/material.dart';

import '../screens/dados_pessoais_screen.dart';
import '../services/account_profile.dart';
import '../services/supabase_auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/security_settings_screen.dart';
import '../services/app_settings.dart';
import '../theme.dart';

Future<void> sairDaConta(BuildContext context) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Sair da conta?',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark,
        ),
      ),
      content: const Text(
        'Você voltará para a tela de login do BusFlow. '
        'Seus dados de passagem continuam salvos neste dispositivo.',
        style: TextStyle(
          fontSize: 13.5,
          height: 1.5,
          color: AppColors.textGray,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text(
            'Cancelar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textGray,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text(
            'Sair',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFFDC2626),
            ),
          ),
        ),
      ],
    ),
  );
  if (confirmado != true || !context.mounted) return;
  await SupabaseAuthService.signOut();
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

class ConfiguracoesCard extends StatefulWidget {
  const ConfiguracoesCard({
    super.key,
    this.profileKind = ProfileKind.aluno,
    this.onDadosAtualizados,
  });

  final ProfileKind profileKind;
  final VoidCallback? onDadosAtualizados;

  @override
  State<ConfiguracoesCard> createState() => _ConfiguracoesCardState();
}

class _ConfiguracoesCardState extends State<ConfiguracoesCard> {
  bool _notificacoes = true;

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.person_outline,
            titulo: 'Dados Pessoais',
            subtitulo: 'Nome, e-mail e matrícula',
            onTap: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) =>
                      DadosPessoaisScreen(profileKind: widget.profileKind),
                ),
              );
              if (updated == true) widget.onDadosAtualizados?.call();
            },
          ),
          const _SettingDivider(),
          _SettingRow(
            icon: Icons.notifications_none,
            titulo: 'Notificações',
            subtitulo: 'Alertas de viagem e embarque',
            trailing: Switch(
              key: const ValueKey('config-notificacoes'),
              value: _notificacoes,
              activeThumbColor: AppColors.primary,
              onChanged: (v) {
                setState(() => _notificacoes = v);
                _snack(
                  v ? 'Notificações ativadas.' : 'Notificações desativadas.',
                );
              },
            ),
          ),
          const _SettingDivider(),
          _SettingRow(
            icon: Icons.lock_outline,
            titulo: 'Segurança',
            subtitulo: 'Senha, biometria e sessões',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SecuritySettingsScreen(),
              ),
            ),
          ),
          const _SettingDivider(),
          _SettingRow(
            icon: Icons.dark_mode_outlined,
            titulo: 'Tema escuro',
            subtitulo: 'Aplicar tema escuro no aplicativo',
            trailing: ListenableBuilder(
              listenable: AppSettings.instance,
              builder: (context, _) => Switch(
                key: const ValueKey('config-tema-escuro'),
                value: AppSettings.instance.darkMode,
                activeThumbColor: AppColors.primary,
                onChanged: AppSettings.instance.setDarkMode,
              ),
            ),
          ),
          const _SettingDivider(),
          _SettingRow(
            icon: Icons.help_outline,
            titulo: 'Ajuda e Suporte',
            subtitulo: 'Central de ajuda e contato',
            onTap: () => _snack('Central de ajuda: em breve.'),
          ),
          const _SettingDivider(),
          _SettingRow(
            icon: Icons.info_outline,
            titulo: 'Sobre o App',
            subtitulo: 'Versão 1.0.0 • Termos e privacidade',
            onTap: () => _snack('BusFlow • Programa Mobilidade Universitária'),
          ),
        ],
      ),
    );
  }
}

class LogoutCard extends StatelessWidget {
  const LogoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => sairDaConta(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout,
                size: 19,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sair da conta',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Voltar para a tela de login',
                    style: TextStyle(fontSize: 11, color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFDC2626)),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.titulo,
    this.subtitulo,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String titulo;
  final String? subtitulo;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: const Color(0xFF1E63B4)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitulo!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.hintGray,
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: const Divider(height: 1, color: AppColors.border),
    );
  }
}
