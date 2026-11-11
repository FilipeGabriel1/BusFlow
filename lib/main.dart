import 'package:flutter/material.dart';

import 'services/app_settings.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/aluno/aluno_main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/motorista/motorista_main_screen.dart';
import 'services/admin_storage.dart';
import 'services/motorista_storage.dart';
import 'services/supabase_auth_service.dart';
import 'services/student_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.load();
  await SupabaseAuthService.initialize();
  runApp(const BusFlowApp());
}

class BusFlowApp extends StatefulWidget {
  const BusFlowApp({super.key});

  @override
  State<BusFlowApp> createState() => _BusFlowAppState();
}

class _BusFlowAppState extends State<BusFlowApp> {
  late Future<Widget> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _resolveHome();
  }

  void _retryStartup() {
    setState(() => _homeFuture = _resolveHome());
  }

  Future<void> _signOutStartup() async {
    await SupabaseAuthService.signOut();
    if (mounted) _retryStartup();
  }

  Future<Widget> _resolveHome() async {
    Widget? destination;
    if (SupabaseAuthService.isConfigured) {
      final role = await SupabaseAuthService.currentRole();
      destination = switch (role) {
        BusFlowRole.admin => const AdminMainScreen(),
        BusFlowRole.motorista => const MotoristaMainScreen(),
        BusFlowRole.aluno => const AlunoMainScreen(),
        null => null,
      };
    } else if (await AdminStorage.isRegistered()) {
      destination = const AdminMainScreen();
    } else if (await MotoristaStorage.isRegistered()) {
      destination = const MotoristaMainScreen();
    } else if (await StudentStorage.isRegistered()) {
      destination = const AlunoMainScreen();
    }
    if (destination == null) return const LoginScreen();
    if (AppSettings.instance.biometricEnabled &&
        !await AppSettings.instance.authenticateBiometrics()) {
      return const LoginScreen();
    }
    return destination;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) => MaterialApp(
        title: 'BusFlow',
        debugShowCheckedModeBanner: false,
        themeMode: AppSettings.instance.darkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2CA6E0),
            brightness: Brightness.dark,
            surface: const Color(0xFF182230),
          ),
          scaffoldBackgroundColor: const Color(0xFF101722),
        ),
        home: FutureBuilder<Widget>(
          future: _homeFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 42),
                        const SizedBox(height: 12),
                        const Text(
                          'Não foi possível carregar sua conta.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text('${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _retryStartup,
                          child: const Text('Tentar novamente'),
                        ),
                        TextButton(
                          onPressed: _signOutStartup,
                          child: const Text('Sair e voltar ao login'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snapshot.data ?? const LoginScreen();
          },
        ),
      ),
    );
  }
}
