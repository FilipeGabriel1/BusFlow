import 'package:flutter/material.dart';

import '../screens/admin/admin_perfil_screen.dart';
import '../services/admin_data_store.dart';
import '../theme.dart';
import 'logo.dart';

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({
    super.key,
    this.subtitle = 'ACADÊMICO • GESTÃO',
    this.onBell,
  });

  final String subtitle;
  final VoidCallback? onBell;

  @override
  Widget build(BuildContext context) {
    final store = AdminDataStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return Row(
          children: [
            const BusFlowMark(size: 22),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BusFlow',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              key: const ValueKey('admin-bell'),
              onTap: onBell ??
                  () {
                    final n = store.alertasPendentes;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            n == 0
                                ? 'Nenhum alerta pendente no sistema.'
                                : '$n alerta(s) do sistema pendente(s).',
                          ),
                        ),
                      );
                  },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      size: 26,
                      color: AppColors.textDark,
                    ),
                    if (store.alertasPendentes > 0)
                      Positioned(
                        top: 1,
                        right: 2,
                        child: Container(
                          key: const ValueKey('admin-bell-dot'),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              key: const ValueKey('admin-avatar'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AdminPerfilScreen(),
                ),
              ),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  store.iniciaisAvatar,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
