import 'package:flutter/material.dart';

import '../screens/aluno/notificacoes_screen.dart';
import '../services/notification_store.dart';
import '../theme.dart';
import 'configuracoes_sheet.dart';
import 'logo.dart';
import 'notificacoes_popup.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key, this.subtitle = 'Início'});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
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
              style: const TextStyle(fontSize: 11, color: AppColors.textGray),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          key: const ValueKey('bell-btn'),
          onTap: () => mostrarNotificacoes(
            context,
            onVerTodas: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificacoesScreen(),
                ),
              );
            },
          ),
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
                Positioned(
                  top: 1,
                  right: 2,
                  child: ListenableBuilder(
                    listenable: NotificationStore.instance,
                    builder: (context, _) {
                      if (!NotificationStore.instance.hasUnread) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        key: const ValueKey('bell-dot'),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          key: const ValueKey('avatar-btn'),
          onTap: () => mostrarConfiguracoes(context),
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: BusFlowAvatar(radius: 16),
          ),
        ),
      ],
    );
  }
}
