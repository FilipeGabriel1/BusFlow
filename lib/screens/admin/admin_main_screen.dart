import 'package:flutter/material.dart';

import '../../services/admin_data_store.dart';
import '../../theme.dart';
import 'admin_frota_screen.dart';
import 'admin_home_screen.dart';
import 'admin_perfil_screen.dart';
import 'admin_usuarios_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  late int _index = widget.initialIndex;

  static const _labels = ['Início', 'Frota', 'Usuários', 'Perfil'];
  static const _icons = [
    Icons.grid_view_outlined,
    Icons.directions_bus_outlined,
    Icons.people_outline,
    Icons.badge_outlined,
  ];

  @override
  void initState() {
    super.initState();
    AdminDataStore.instance.load();
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
            AdminHomeScreen(
              onOpenFrota: () => _goTo(1),
              onOpenUsuarios: () => _goTo(2),
            ),
            const AdminFrotaScreen(),
            const AdminUsuariosScreen(),
            const AdminPerfilScreen(),
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
                      key: ValueKey('admin-nav-$i'),
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
