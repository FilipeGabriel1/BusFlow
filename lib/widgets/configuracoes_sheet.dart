import 'package:flutter/material.dart';

import '../services/student_storage.dart';
import '../theme.dart';
import '../widgets/configuracoes_widgets.dart';
import '../widgets/logo.dart';

Future<void> mostrarConfiguracoes(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _ConfiguracoesSheet(),
  );
}

class _ConfiguracoesSheet extends StatefulWidget {
  const _ConfiguracoesSheet();

  @override
  State<_ConfiguracoesSheet> createState() => _ConfiguracoesSheetState();
}

class _ConfiguracoesSheetState extends State<_ConfiguracoesSheet> {
  String _nome = 'Ana Costa';
  String _ra = '2024.1.08849';

  @override
  void initState() {
    super.initState();
    _loadAluno();
  }

  Future<void> _loadAluno() async {
    try {
      final aluno = await StudentStorage.getAluno();
      if (!mounted) return;
      setState(() {
        if (aluno['nome']?.isNotEmpty == true) {
          final partes = aluno['nome']!.trim().split(RegExp(r'\s+'));
          _nome = partes.length > 1
              ? '${partes.first} ${partes.last}'
              : partes.first;
        }
        if (aluno['ra']?.isNotEmpty == true) {
          _ra = aluno['ra']!;
        }
      });
    } catch (_) {
      // Sem preferências disponíveis — mantém os dados de demonstração.
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const BusFlowAvatar(radius: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RA $_ra',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.badgeBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.badgeBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 6, color: AppColors.greenDot),
                      SizedBox(width: 5),
                      Text(
                        'Matrícula Ativa',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  key: const ValueKey('config-fechar'),
                  onTap: () => Navigator.of(context).maybePop(),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 22,
                      color: AppColors.hintGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'CONFIGURAÇÕES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.hintGray,
              ),
            ),
            const SizedBox(height: 10),
            const ConfiguracoesCard(),
            const SizedBox(height: 12),
            const LogoutCard(),
          ],
        ),
      ),
    );
  }
}
