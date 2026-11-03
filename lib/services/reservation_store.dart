import 'package:flutter/foundation.dart';

/// Estado compartilhado da reserva de vaga do aluno.
///
/// Começa sempre vazio (sem reserva) e avisa as telas (Viagens e Início)
/// sempre que uma reserva é criada ou cancelada.
class ReservationStore extends ChangeNotifier {
  ReservationStore._();

  static final ReservationStore instance = ReservationStore._();

  int? _tripIndex;

  int? get tripIndex => _tripIndex;
  bool get hasReservation => _tripIndex != null;

  void reserve(int index) {
    _tripIndex = index;
    notifyListeners();
  }

  void cancel() {
    _tripIndex = null;
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _tripIndex = null;
  }
}
