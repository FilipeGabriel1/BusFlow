import 'package:flutter/material.dart';

import '../../services/motorista_data_store.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';

class MotoristaAlertasScreen extends StatefulWidget {
  const MotoristaAlertasScreen({super.key});

  @override
  State<MotoristaAlertasScreen> createState() =>
      _MotoristaAlertasScreenState();
}

class _MotoristaAlertasScreenState extends State<MotoristaAlertasScreen> {
  int _filtro = 0;

  static const _filtros = ['Todos', 'Validação', 'Viagem', 'Sistema'];

  List<AlertaMotorista> _filtrados(MotoristaDataStore store) {
    switch (_filtro) {
      case 1:
        return store.alertas.where((a) => a.categoria == 'Validação').toList();
      case 2:
        return store.alertas.where((a) => a.categoria == 'Viagem').toList();
      case 3:
        return store.alertas.where((a) => a.categoria == 'Sistema').toList();
      default:
        return store.alertas;
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final store = MotoristaDataStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final alertas = _filtrados(store);
        final unread = store.alertasNaoLidos;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(unread),
              const SizedBox(height: 16),
              _buildHeader(unread),
              const SizedBox(height: 14),
              _buildFiltros(),
              const SizedBox(height: 14),
              if (alertas.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 40,
                        color: AppColors.hintGray,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Nenhum alerta neste filtro.',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGray,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Alertas surgem com viagens e validações.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.hintGray,
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (final a in alertas) ...[
                  _AlertaCard(alerta: a),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 8),
              if (unread > 0)
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    key: const ValueKey('alertas-marcar-lidas'),
                    onPressed: () {
                      store.marcarTodosAlertasLidos();
                      _snack('Todos os alertas marcados como lidos.');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.done_all, size: 17),
                    label: const Text(
                      'Marcar todos como lidos',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(int unread) {
    return Row(
      children: [
        const BusFlowMark(size: 22),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BusFlow',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                'ACADÊMICO • ALERTAS',
                style: TextStyle(fontSize: 10.5, color: AppColors.textGray),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none,
              size: 24,
              color: AppColors.textDark,
            ),
            if (unread > 0)
              Positioned(
                top: -2,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unread',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        const BusFlowAvatar(radius: 15),
      ],
    );
  }

  Widget _buildHeader(int unread) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E63B4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Central de Alertas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Ocorrências de rota, avisos e notificações da central',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFBFDBFE),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              unread > 0 ? '$unread novos' : 'Tudo lido',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tabBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _filtros.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                key: ValueKey('alerta-filtro-$i'),
                onTap: () => setState(() => _filtro = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: _filtro == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: _filtro == i
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _filtros[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight:
                          _filtro == i ? FontWeight.w800 : FontWeight.w600,
                      color:
                          _filtro == i ? AppColors.primary : AppColors.textGray,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AlertaCard extends StatelessWidget {
  const _AlertaCard({required this.alerta});

  final AlertaMotorista alerta;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!alerta.lido) {
          MotoristaDataStore.instance.marcarAlertaLido(alerta);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: alerta.lido ? Colors.white : AppColors.softBlue,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                alerta.lido ? AppColors.border : AppColors.softBlueBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: alerta.iconeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(alerta.icone, size: 19, color: alerta.iconeCor),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alerta.titulo,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: alerta.lido
                                ? AppColors.textGray
                                : AppColors.primaryDark,
                          ),
                        ),
                      ),
                      if (!alerta.lido)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        alerta.hora,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.hintGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    alerta.mensagem,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      color: alerta.lido
                          ? AppColors.hintGray
                          : AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}