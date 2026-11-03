import 'package:flutter/material.dart';

import 'screens/aluno/aluno_main_screen.dart';
import 'screens/login_screen.dart';
import 'services/student_storage.dart';

void main() => runApp(const BusFlowApp());

class BusFlowApp extends StatelessWidget {
  const BusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FutureBuilder<bool>(
        future: StudentStorage.isRegistered(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == true) return const AlunoMainScreen();
          return const LoginScreen();
        },
      ),
    );
  }
}
