import 'package:flutter/material.dart';

import '../../services/motorista_data_store.dart';
import '../../theme.dart';
import '../../widgets/home_top_bar.dart';

class MotoristaRotasScreen extends StatefulWidget {
  const MotoristaRotasScreen({super.key});

  @override
  State<MotoristaRotasScreen> createState() => _MotoristaRotasScreenState();
}

class _MotoristaRotasScreenState extends State<MotoristaRotasScreen> {
  int _filtro = 0;

  static const _filtros = [
    'Todas',
    'Em Andamento',
    'Próximas',
    'Concluída',
  ];

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<RotaAtribuida> _filtradas(MotoristaDataStore store) {
    switch (_filtro) {
      case 1:
        return store.rotas
            .where((r) => r.status == 'Em Andamento')
            .toList();
      case 2:
        return store.rotas
            .where(
              (r) => r.status == 'Aguardando Saída' || r.status == 'Tarde',
            )
            .toList();
      case 3:
        return store.rotas.where((r) => r.concluida).toList();
      default:
        return store.rotas;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = MotoristaDataStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final filtradas = _filtradas(store);
        final hoje = DateTime.now();
        final dataLabel =
            '${hoje.day.toString().padLeft(2, '0')} ${_mesCurto(hoje.month)}';
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeTopBar(subtitle: 'ACADÊMICO • MOTORISTA'),
              const SizedBox(height: 16),
              _buildEscalaHeader(store, dataLabel),
              const SizedBox(height: 16),
              _buildStats(store),
              const SizedBox(height: 16),
              _buildFiltros(),
              const SizedBox(height: 14),
              if (filtradas.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.route_outlined,
                        size: 36,
                        color: AppColors.hintGray,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        store.rotas.isEmpty
                            ? 'Nenhuma rota atribuída ainda.'
                            : 'Nenhuma rota neste filtro.',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGray,
                        ),
                      ),
                      if (store.rotas.isEmpty) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'Aguardando escala da central.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.hintGray,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                for (final rota in filtradas) ...[
                  _RotaCard(rota: rota, onAction: _snack),
                  const SizedBox(height: 12),
                ],
              const SizedBox(height: 8),
              _buildDesempenho(store),
              const SizedBox(height: 14),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _snack('Histórico de escalas em breve.'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text(
                    'Consultar Histórico e Escalas Anteriores',
                    style: TextStyle(
                      fontSize: 13.5,
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

  String _mesCurto(int m) {
    const meses = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return meses[m - 1];
  }

  Widget _buildEscalaHeader(MotoristaDataStore store, String dataLabel) {
    final turno = store.turno.isNotEmpty ? store.turno : 'Sem turno';
    final temRota = store.rotas.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.badgeBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.badgeBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  temRota ? Icons.verified : Icons.schedule,
                  size: 13,
                  color: temRota ? AppColors.green : AppColors.textGray,
                ),
                const SizedBox(width: 5),
                Text(
                  temRota ? 'Escala Ativa • $turno' : 'Sem escala ativa',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: temRota ? AppColors.green : AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Hoje, $dataLabel',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(MotoristaDataStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Minhas Rotas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Escalas operacionais, itinerários e viagens atribuídas',
          style: TextStyle(fontSize: 12.5, color: AppColors.textGray),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '${store.rotasHoje}',
                label: 'HOJE',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                value: '${store.rotasAtivas}',
                label: 'ATIVA',
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                value: '${store.rotasProgramadas}',
                label: 'PROGRAMADAS',
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                value: '${store.rotasConcluidas}',
                label: 'CONCLUÍDA',
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ],
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
                key: ValueKey('filtro-$i'),
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
                      fontWeight: _filtro == i
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: _filtro == i
                          ? AppColors.primary
                          : AppColors.textGray,
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

  Widget _buildDesempenho(MotoristaDataStore store) {
    final total = store.rotasConcluidas;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, Color(0xFF17457F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                size: 20,
                color: Color(0xFFFFD54F),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Desempenho',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            total > 0 ? '$total viagens concluídas' : 'Sem viagens concluídas',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF93C5FD)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DesempenhoItem(
                  value: '${store.rotasConcluidas}',
                  label: 'Viagens Feitas',
                ),
              ),
              Expanded(
                child: _DesempenhoItem(
                  value: '${store.lotacao}',
                  label: 'Embarques Hoje',
                ),
              ),
              Expanded(
                child: _DesempenhoItem(
                  value: '${store.alertasNaoLidos}',
                  label: 'Alertas Abertos',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: AppColors.hintGray,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RotaCard extends StatelessWidget {
  const _RotaCard({required this.rota, required this.onAction});

  final RotaAtribuida rota;
  final void Function(String) onAction;

  @override
  Widget build(BuildContext context) {
    final percent = rota.total > 0 ? rota.ocupados / rota.total : 0.0;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_bus,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  rota.linha,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '• ${rota.onibus}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textGray,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: rota.statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  rota.status,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: rota.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rota.origem,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${rota.origemNota} • ${rota.saida}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.arrow_forward,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rota.destino,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${rota.destinoNota} • ${rota.chegada}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${rota.lotacaoLabel}: ${rota.ocupados}/${rota.total}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percent >= 0.9
                              ? const Color(0xFFF59E0B)
                              : AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rota.infoExtra,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        onAction('${rota.acaoPrimaria} — ${rota.linha}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(rota.acaoPrimariaIcon, size: 15),
                    label: Text(
                      rota.acaoPrimaria,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              if (rota.acaoSecundaria != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () => onAction(
                        '${rota.acaoSecundaria} — ${rota.linha}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(rota.acaoSecundariaIcon, size: 15),
                      label: Text(
                        rota.acaoSecundaria!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DesempenhoItem extends StatelessWidget {
  const _DesempenhoItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF93C5FD),
          ),
        ),
      ],
    );
  }
}