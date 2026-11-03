import 'package:flutter/material.dart';

class AppNotification {
  AppNotification({
    required this.titulo,
    required this.mensagem,
    required this.hora,
    required this.icone,
    required this.iconeBg,
    required this.iconeCor,
    this.lida = false,
  });

  final String titulo;
  final String mensagem;
  final String hora;
  final IconData icone;
  final Color iconeBg;
  final Color iconeCor;
  bool lida;
}

class NotificationStore extends ChangeNotifier {
  NotificationStore._() : _items = _seed();

  static final NotificationStore instance = NotificationStore._();

  late List<AppNotification> _items;

  static List<AppNotification> _seed() => [
        AppNotification(
          titulo: 'Embarque Confirmado',
          mensagem: 'Linha 04 • Campus Central às 19:24. '
              'Dirija-se ao ponto B.',
          hora: 'Agora',
          icone: Icons.directions_bus,
          iconeBg: const Color(0xFFDBEAFE),
          iconeCor: const Color(0xFF17457F),
        ),
        AppNotification(
          titulo: 'Ônibus em rota até você',
          mensagem: 'Parada prevista às 19:34 (saída da garagem às 19:30).',
          hora: '12 min',
          icone: Icons.near_me,
          iconeBg: const Color(0xFFEFF4FF),
          iconeCor: const Color(0xFF2CA6E0),
        ),
        AppNotification(
          titulo: 'Reserva de vaga assegurada',
          mensagem: 'Seu assento na Linha 04 está confirmado para hoje.',
          hora: '1 h',
          icone: Icons.event_seat_outlined,
          iconeBg: const Color(0xFFF0FDF4),
          iconeCor: const Color(0xFF16A34A),
        ),
        AppNotification(
          titulo: 'Obra na Avenida Brasil',
          mensagem: 'Linha 02 com atraso de 10 min. Considere a Linha 04.',
          hora: 'Ontem',
          icone: Icons.construction,
          iconeBg: const Color(0xFFFEF3C7),
          iconeCor: const Color(0xFFF59E0B),
          lida: true,
        ),
      ];

  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.lida).length;

  bool get hasUnread => unreadCount > 0;

  void marcarTodasComoLidas() {
    if (!hasUnread) return;
    for (final n in _items) {
      n.lida = true;
    }
    notifyListeners();
  }

  void reset() {
    _items = _seed();
    notifyListeners();
  }
}
