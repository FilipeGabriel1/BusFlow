import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../services/motorista_data_store.dart';
import '../../theme.dart';
import '../../widgets/home_top_bar.dart';

class MotoristaHomeScreen extends StatefulWidget {
  const MotoristaHomeScreen({super.key, this.onOpenRotas});

  final VoidCallback? onOpenRotas;

  @override
  State<MotoristaHomeScreen> createState() => _MotoristaHomeScreenState();
}

class _MotoristaHomeScreenState extends State<MotoristaHomeScreen> {
  StreamSubscription<Position>? _locationSubscription;
  Position? _driverPosition;

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleTrip(
    MotoristaDataStore store,
    RotaAtribuida route,
  ) async {
    if (store.viagemIniciada) {
      await _locationSubscription?.cancel();
      _locationSubscription = null;
      store.encerrarViagem();
      if (mounted) _snack('${route.linha} encerrada.');
      return;
    }

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _snack('Ative o serviço de localização para iniciar a viagem.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _snack('Permita o acesso à localização para iniciar a viagem.');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _driverPosition = position);
      store.iniciarViagem(route);
      _locationSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen(
            (updatedPosition) {
              if (mounted) setState(() => _driverPosition = updatedPosition);
            },
            onError: (Object error) {
              if (mounted) {
                _snack('A atualização do GPS falhou: $error');
              }
            },
          );
      _snack('${route.linha} iniciada. Boa viagem!');
    } catch (error) {
      if (mounted) _snack('Não foi possível iniciar o GPS: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = MotoristaDataStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeTopBar(subtitle: 'ACADÊMICO • MOTORISTA'),
              const SizedBox(height: 16),
              _buildGreeting(store),
              const SizedBox(height: 16),
              _buildViagemAtual(store),
              const SizedBox(height: 16),
              _buildLotacao(store),
              const SizedBox(height: 16),
              _buildChecklist(store),
              if (store.viagemIniciada) ...[
                const SizedBox(height: 16),
                _buildProximaParada(store),
              ],
              const SizedBox(height: 22),
              const Text(
                'FERRAMENTAS DE BORDO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.hintGray,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ToolCard(
                    icon: Icons.qr_code_scanner,
                    title: 'Validar Passe',
                    subtitle: 'QR & Facial',
                    onTap: () => _snack('Leitor de passes ativado.'),
                  ),
                  const SizedBox(width: 10),
                  _ToolCard(
                    icon: Icons.map_outlined,
                    title: 'Ver Rota',
                    subtitle: 'Trânsito Ao Vivo',
                    onTap: () {
                      if (store.viagemAtual == null) {
                        _snack('Nenhuma viagem ativa para acompanhar.');
                      } else {
                        _snack('Abrindo rota ao vivo.');
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  _ToolCard(
                    icon: Icons.support_agent,
                    title: 'Central',
                    subtitle: 'Ocorrências',
                    onTap: () => _snack('Central de ocorrências acionada.'),
                  ),
                ],
              ),
              if (store.viagemIniciada) ...[
                const SizedBox(height: 16),
                _buildMonitoramentoVia(store),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildGreeting(MotoristaDataStore store) {
    final turno = store.turno.isNotEmpty ? store.turno : 'Turno não definido';
    final empresa = store.empresa.isNotEmpty ? store.empresa : 'Sem empresa';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E63B4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Olá, ${store.primeiroNome}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.verified, size: 22, color: Color(0xFF7DD3FC)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$turno • $empresa',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFFBFDBFE)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 14, color: Color(0xFF86EFAC)),
                SizedBox(width: 6),
                Text(
                  'GPS Ativo • Conectado à Central',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViagemAtual(MotoristaDataStore store) {
    final rota = store.viagemAtual;
    if (rota == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'VIAGEM ATUAL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.hintGray,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            const Icon(
              Icons.route_outlined,
              size: 32,
              color: AppColors.hintGray,
            ),
            const SizedBox(height: 8),
            const Text(
              'Nenhuma viagem ativa',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Atribuições da central aparecem em Viagens.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textGray),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                onPressed: widget.onOpenRotas,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.directions_bus_outlined, size: 17),
                label: const Text(
                  'Ver Minhas Rotas',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final statusLabel = store.viagemIniciada
        ? 'Em Andamento'
        : 'Aguardando Saída';
    final statusColor = store.viagemIniciada
        ? AppColors.green
        : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.softBlueBorder),
                ),
                child: const Text(
                  'VIAGEM ATUAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ORIGEM',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.hintGray,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      rota.origem,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Saída: ${rota.saida}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'DESTINO',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.hintGray,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      rota.destino,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Previsto: ${rota.chegada}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.directions_bus,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  rota.onibus,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatusDot(
                label: 'Aguardando',
                active: !store.viagemIniciada,
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 10),
              _StatusDot(
                label: 'Em Andamento',
                active: store.viagemIniciada,
                color: AppColors.green,
              ),
              const SizedBox(width: 10),
              const _StatusDot(
                label: 'Finalizada',
                active: false,
                color: AppColors.textGray,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              key: const ValueKey('iniciar-viagem-btn'),
              onPressed: () => _toggleTrip(store, rota),
              style: ElevatedButton.styleFrom(
                backgroundColor: store.viagemIniciada
                    ? const Color(0xFFDC2626)
                    : AppColors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(store.viagemIniciada ? Icons.stop : Icons.play_arrow),
              label: Text(
                store.viagemIniciada ? 'Encerrar Viagem' : 'Iniciar Viagem',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLotacao(MotoristaDataStore store) {
    final ocupados = store.lotacao;
    final total = MotoristaDataStore.capacidadeTotal;
    final percent = store.lotacaoFraction;
    final pctLabel = '${(percent * 100).round()}% ${store.statusLotacao}';
    final barColor = percent >= 0.9 ? const Color(0xFFF59E0B) : AppColors.green;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lotação do Ônibus',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.badgeBorder),
                ),
                child: Text(
                  pctLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: barColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$ocupados de $total assentos ocupados',
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
              Text(
                '${store.assentosLivres} livres',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist(MotoristaDataStore store) {
    final entries = store.checklist.entries.toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Checklist de partida',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              if (store.checklistCompleto)
                const Text(
                  'Completo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            GestureDetector(
              onTap: () => store.toggleChecklist(entries[i].key),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: entries[i].value ? AppColors.green : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: entries[i].value
                            ? AppColors.green
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: entries[i].value
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entries[i].key,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: entries[i].value
                            ? AppColors.textDark
                            : AppColors.textGray,
                      ),
                    ),
                  ),
                  if (entries[i].value)
                    const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProximaParada(MotoristaDataStore store) {
    final rota = store.viagemAtual;
    if (rota == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.softBlueBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'PRÓXIMA PARADA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rota.destino,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.softBlueBorder),
                ),
                child: Text(
                  'Chegada ${rota.chegada}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.softBlueBorder),
                ),
                child: Text(
                  rota.lotacaoLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGray,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoramentoVia(MotoristaDataStore store) {
    final rota = store.viagemAtual;
    if (rota == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monitoramento de Via',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.badgeBorder),
                ),
                child: Text(
                  store.viagemIniciada ? 'Em rota' : 'Parado',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: store.viagemIniciada
                        ? AppColors.green
                        : AppColors.textGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 170,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _driverPosition == null
                        ? const LatLng(-8.0600, -34.9300)
                        : LatLng(
                            _driverPosition!.latitude,
                            _driverPosition!.longitude,
                          ),
                    initialZoom: 13.2,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'br.edu.busflow.motorista',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: const [
                            LatLng(-8.0480, -34.9050),
                            LatLng(-8.0540, -34.9170),
                            LatLng(-8.0600, -34.9300),
                            LatLng(-8.0660, -34.9440),
                            LatLng(-8.0720, -34.9560),
                          ],
                          strokeWidth: 4,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        if (_driverPosition != null)
                          Marker(
                            point: LatLng(
                              _driverPosition!.latitude,
                              _driverPosition!.longitude,
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.my_location,
                              color: AppColors.flowBlue,
                              size: 28,
                            ),
                          ),
                        Marker(
                          point: const LatLng(-8.0480, -34.9050),
                          width: 30,
                          height: 30,
                          child: const Icon(
                            Icons.place,
                            size: 26,
                            color: AppColors.green,
                          ),
                        ),
                        Marker(
                          point: const LatLng(-8.0720, -34.9560),
                          width: 30,
                          height: 30,
                          child: const Icon(
                            Icons.place,
                            size: 26,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        Marker(
                          point: const LatLng(-8.0600, -34.9300),
                          width: 40,
                          height: 40,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 2.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_bus,
                              size: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${rota.origem} → ${rota.destino}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.label,
    required this.active,
    required this.color,
  });

  final String label;
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: active ? color : AppColors.border,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? color : AppColors.hintGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.softBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
