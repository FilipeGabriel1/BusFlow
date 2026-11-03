import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/aluno_bottom_nav.dart';
import 'aluno_home_screen.dart';
import 'carteirinha_screen.dart';
import 'conta_aluno_screen.dart';
import 'mapa_screen.dart';
import 'trips_screen.dart';

class AlunoMainScreen extends StatefulWidget {
  const AlunoMainScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AlunoMainScreen> createState() => _AlunoMainScreenState();
}

class _AlunoMainScreenState extends State<AlunoMainScreen> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            AlunoHomeScreen(
              onOpenTrips: () => setState(() => _index = 1),
              onOpenMap: () => setState(() => _index = 2),
            ),
            const TripsScreen(),
            MapaScreen(active: _index == 2),
            ContaAlunoScreen(
              onOpenHistory: () => setState(() => _index = 1),
              onOpenCarteirinha: _abrirCarteirinha,
            ),
          ],
        ),
      ),
      bottomNavigationBar: AlunoBottomNav(
        selected: _index,
        onTap: (i) => setState(() => _index = i),
        onCenterTap: _abrirCarteirinha,
      ),
    );
  }

  void _abrirCarteirinha() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CarteirinhaScreen()),
    );
  }
}
