import 'package:flutter/material.dart';

import '../../services/notification_store.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  @override
  void dispose() {
    NotificationStore.instance.marcarTodasComoLidas();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = NotificationStore.instance;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final notificacoes = store.items;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(store),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RECENTES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.hintGray,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (store.hasUnread)
                        GestureDetector(
                          key: const ValueKey('marcar-lidas'),
                          onTap: store.marcarTodasComoLidas,
                          behavior: HitTestBehavior.opaque,
                          child: const Text(
                            'Marcar todas como lidas',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E63B4),
                            ),
                          ),
                        )
                      else
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: AppColors.green,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Tudo lido',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final n in notificacoes) ...[
                    _NotificacaoCard(n: n),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(NotificationStore store) {
    return Row(
      children: [
        GestureDetector(
          key: const ValueKey('notificacoes-voltar'),
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const BusFlowMark(size: 22),
        const SizedBox(width: 8),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificações',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            Text(
              'BusFlow',
              style: TextStyle(fontSize: 11, color: AppColors.textGray),
            ),
          ],
        ),
        const Spacer(),
        if (store.unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE1E9FB)),
            ),
            child: Text(
              '${store.unreadCount} novas',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E63B4),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificacaoCard extends StatelessWidget {
  const _NotificacaoCard({required this.n});

  final AppNotification n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: n.lida ? AppColors.border : const Color(0xFFBBD4FB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: n.iconeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(n.icone, size: 19, color: n.iconeCor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    if (!n.lida)
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E63B4),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.mensagem,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Text(
                      n.hora,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.hintGray,
                      ),
                    ),
                    if (!n.lida) ...[
                      const SizedBox(width: 8),
                      const Text(
                        'Nova',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E63B4),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
