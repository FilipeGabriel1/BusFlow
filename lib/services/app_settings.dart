import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const _darkModeKey = 'app_dark_mode';
  static const _biometricKey = 'app_biometric_enabled';
  bool _darkMode = false;
  bool _biometricEnabled = false;

  bool get darkMode => _darkMode;
  bool get biometricEnabled => _biometricEnabled;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _darkMode = preferences.getBool(_darkModeKey) ?? false;
    _biometricEnabled = preferences.getBool(_biometricKey) ?? false;
  }

  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, enabled);
    notifyListeners();
  }

  Future<bool> enableBiometrics() async {
    final auth = LocalAuthentication();
    try {
      if (!await auth.isDeviceSupported()) return false;
      final available = await auth.getAvailableBiometrics();
      if (available.isEmpty) return false;
      final authenticated = await auth.authenticate(
        localizedReason: 'Confirme sua identidade para ativar a biometria.',
        biometricOnly: true,
      );
      if (!authenticated) return false;
      _biometricEnabled = true;
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_biometricKey, true);
      notifyListeners();
      return true;
    } on PlatformException {
      rethrow;
    }
  }

  Future<bool> authenticateBiometrics() async {
    if (!_biometricEnabled) return false;
    final auth = LocalAuthentication();
    try {
      if (!await auth.isDeviceSupported()) return false;
      return await auth.authenticate(
        localizedReason: 'Confirme sua identidade para entrar no BusFlow.',
        biometricOnly: true,
      );
    } on PlatformException {
      rethrow;
    }
  }

  Future<void> disableBiometrics() async {
    _biometricEnabled = false;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_biometricKey, false);
    notifyListeners();
  }
}
