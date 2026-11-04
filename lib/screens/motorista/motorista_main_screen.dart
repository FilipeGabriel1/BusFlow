import 'package:flutter/material.dart';

import '../../services/motorista_data_store.dart';
import '../../theme.dart';
import 'motorista_alertas_screen.dart';
import 'motorista_home_screen.dart';
import 'motorista_perfil_screen.dart';
import 'motorista_rotas_screen.dart';
import 'motorista_validar_screen.dart';

class MotoristaMainScreen extends StatefulWidget {
  const MotoristaMainScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MotoristaMainScreen> createState() => _MotoristaMainScreenState();
}

class _MotoristaMainScreenState extends State<MotoristaMainScreen> {
  late int _index = widget.initialIndex;

  static const _labels = ['Início', 'Viagens', 'Validar', 'Alertas', 'Perfil'];
  static const _icons = [
    Icons.home_outlined,
    Icons.directions_bus_outlined,
    Icons.qr_code_scanner,
    Icons.notifications_none,
    Icons.person_outline,
  ];

  @override
  void initState() {
    super.initState();
    MotoristaDataStore.instance.load();
  }

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            MotoristaHomeScreen(onOpenRotas: () => _goTo(1)),
            const MotoristaRotasScreen(),
            const MotoristaValidarScreen(),
            const MotoristaAlertasScreen(),
            const MotoristaPerfilScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _labels.length; i++)
                  Expanded(
                    child: GestureDetector(
                      key: ValueKey('motorista-nav-$i'),
                      onTap: () => _goTo(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _icons[i],
                            size: 22,
                            color: _index == i
                                ? AppColors.primary
                                : AppColors.textGray,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _labels[i],
                            style: TextStyle(
                              fontSize: 10,
                              color: _index == i
                                  ? AppColors.primary
                                  : AppColors.textGray,
                              fontWeight: _index == i
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}