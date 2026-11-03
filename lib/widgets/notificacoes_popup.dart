import 'package:flutter/material.dart';

import '../services/notification_store.dart';
import '../theme.dart';

Future<void> mostrarNotificacoes(
  BuildContext context, {
  VoidCallback? onVerTodas,
}) async {
  var foiParaTela = false;
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black45,
    builder: (dialogContext) => Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(dialogContext).padding.top + 56,
          right: 12,
          left: 12,
        ),
        child: _NotificacoesPopup(
          onVerTodas: () {
            foiParaTela = true;
            Navigator.of(dialogContext).maybePop();
            onVerTodas?.call();
          },
        ),
      ),
    ),
  );
  if (foiParaTela || !context.mounted) return;
  NotificationStore.instance.marcarTodasComoLidas();
}

class _NotificacoesPopup extends StatelessWidget {
  const _NotificacoesPopup({required this.onVerTodas});

  final VoidCallback onVerTodas;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380, maxHeight: 520),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Notificações',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  ListenableBuilder(
                    listenable: NotificationStore.instance,
                    builder: (context, _) {
                      if (!NotificationStore.instance.hasUnread) {
                        return const Row(
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
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        );
                      }
                      return GestureDetector(
                        key: const ValueKey('popup-marcar-lidas'),
                        onTap: NotificationStore.instance.marcarTodasComoLidas,
                        behavior: HitTestBehavior.opaque,
                        child: const Text(
                          'Marcar todas como lidas',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E63B4),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Flexible(
              child: ListenableBuilder(
                listenable: NotificationStore.instance,
                builder: (context, _) {
                  final items = NotificationStore.instance.items;
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Nenhuma notificação',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textGray,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _NotificacaoLinha(notificacao: items[index]),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            GestureDetector(
              key: const ValueKey('popup-ver-todas'),
              onTap: onVerTodas,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ver todas as notificações',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E63B4),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: Color(0xFF1E63B4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificacaoLinha extends StatelessWidget {
  const _NotificacaoLinha({required this.notificacao});

  final AppNotification notificacao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: notificacao.iconeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(notificacao.icone, size: 17, color: notificacao.iconeCor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notificacao.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: notificacao.lida
                        ? AppColors.textGray
                        : AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notificacao.mensagem,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notificacao.hora,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.hintGray,
                  ),
                ),
              ],
            ),
          ),
          if (!notificacao.lida) ...[
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
