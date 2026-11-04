import 'package:flutter/material.dart';

import 'screens/admin/admin_main_screen.dart';
import 'screens/aluno/aluno_main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/motorista/motorista_main_screen.dart';
import 'services/admin_storage.dart';
import 'services/motorista_storage.dart';
import 'services/student_storage.dart';

void main() => runApp(const BusFlowApp());

class BusFlowApp extends StatelessWidget {
  const BusFlowApp({super.key});

  Future<Widget> _resolveHome() async {
    if (await AdminStorage.isRegistered()) {
      return const AdminMainScreen();
    }
    if (await MotoristaStorage.isRegistered()) {
      return const MotoristaMainScreen();
    }
    if (await StudentStorage.isRegistered()) {
      return const AlunoMainScreen();
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FutureBuilder<Widget>(
        future: _resolveHome(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data ?? const LoginScreen();
        },
      ),
    );
  }
}
