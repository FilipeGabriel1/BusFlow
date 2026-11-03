import 'dart:async';
import 'dart:js_interop';

import 'package:latlong2/latlong.dart';
import 'package:web/web.dart' as web;

/// Obtém a posição GPS do navegador (pede permissão automaticamente).
/// Retorna null se o usuário negar ou o GPS estiver indisponível.
Future<LatLng?> getUserLocation() {
  final completer = Completer<LatLng?>();
  try {
    web.window.navigator.geolocation.getCurrentPosition(
      (web.GeolocationPosition position) {
        if (!completer.isCompleted) {
          completer.complete(
            LatLng(
              position.coords.latitude.toDouble(),
              position.coords.longitude.toDouble(),
            ),
          );
        }
      }.toJS,
      (web.GeolocationPositionError error) {
        if (!completer.isCompleted) completer.complete(null);
      }.toJS,
    );
  } catch (_) {
    if (!completer.isCompleted) completer.complete(null);
  }
  return completer.future;
}
