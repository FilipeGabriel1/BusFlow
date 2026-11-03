import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/gps_locator_stub.dart'
    if (dart.library.html) '../../services/gps_locator_web.dart';
import '../../theme.dart';

class RouteTrackingScreen extends StatefulWidget {
  const RouteTrackingScreen({super.key});

  @override
  State<RouteTrackingScreen> createState() => _RouteTrackingScreenState();
}

class _RouteTrackingScreenState extends State<RouteTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final ValueNotifier<double> _progress = ValueNotifier(0);
  final MapController _mapController = MapController();

  LatLng? _userPos;
  bool _gpsBusy = true;
  String? _gpsError;

  static const _stops = [
    'Terminal Centro',
    'Porto 02',
    'Campus Central',
    'Terminal Sul',
  ];

  static const _horarios = ['19:05', '19:18', '19:32', '19:45'];

  static final List<LatLng> _rota = [
    const LatLng(-8.0525, -34.9035),
    const LatLng(-8.0580, -34.9120),
    const LatLng(-8.0625, -34.9210),
    const LatLng(-8.0660, -34.9320),
    const LatLng(-8.0680, -34.9450),
    const LatLng(-8.0685, -34.9580),
    const LatLng(-8.0720, -34.9700),
    const LatLng(-8.0780, -34.9800),
  ];

  static const _paradasIdx = [0, 2, 5, 7];

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 28))
          ..addListener(() => _progress.value = _ctrl.value)
          ..repeat();
    _initGps();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _progress.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initGps() async {
    try {
      final pos = await getUserLocation();
      if (!mounted) return;
      if (pos == null) {
        setState(() {
          _gpsBusy = false;
          _gpsError = 'Localização indisponível — exibindo rota padrão';
        });
        return;
      }
      setState(() {
        _userPos = pos;
        _gpsBusy = false;
      });
      _mapController.move(pos, 14.5);
    } catch (_) {
      if (mounted) {
        setState(() {
          _gpsBusy = false;
          _gpsError = 'GPS indisponível — exibindo rota padrão';
        });
      }
    }
  }

  LatLng _latLngAt(double t) {
    double dist(LatLng a, LatLng b) {
      final dx = a.longitude - b.longitude;
      final dy = a.latitude - b.latitude;
      return math.sqrt(dx * dx + dy * dy);
    }

    final segs = <double>[];
    var total = 0.0;
    for (var i = 1; i < _rota.length; i++) {
      final d = dist(_rota[i - 1], _rota[i]);
      segs.add(d);
      total += d;
    }
    var target = t.clamp(0.0, 1.0) * total;
    for (var i = 0; i < segs.length; i++) {
      if (target <= segs[i] || i == segs.length - 1) {
        final f = segs[i] == 0 ? 0.0 : (target / segs[i]).clamp(0.0, 1.0);
        return LatLng(
          _rota[i].latitude + (_rota[i + 1].latitude - _rota[i].latitude) * f,
          _rota[i].longitude +
              (_rota[i + 1].longitude - _rota[i].longitude) * f,
        );
      }
      target -= segs[i];
    }
    return _rota.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ValueListenableBuilder<double>(
                valueListenable: _progress,
                builder: (context, p, _) => _buildTopBar(p),
              ),
              const SizedBox(height: 18),
              ValueListenableBuilder<double>(
                valueListenable: _progress,
                builder: (context, p, _) => _buildRouteCard(p),
              ),
              const SizedBox(height: 14),
              _buildMapCard(),
              const SizedBox(height: 14),
              ValueListenableBuilder<double>(
                valueListenable: _progress,
                builder: (context, p, _) => _buildStats(p),
              ),
              const SizedBox(height: 18),
              ValueListenableBuilder<double>(
                valueListenable: _progress,
                builder: (context, p, _) => _buildStopsList(p),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(double progress) {
    final pulse = 0.55 + 0.45 * math.sin(progress * math.pi * 10).abs();
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'Acompanhar Rota',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        ),
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.greenDot.withValues(alpha: pulse),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'AO VIVO',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'Rota Noturna',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ônibus #402',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const Spacer(),
              const Text(
                'BRF-2020',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.person_outline, size: 15, color: AppColors.textGray),
              SizedBox(width: 5),
              Text(
                'Motorista: Carlos Mendes',
                style: TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RouteProgressBar(progress: progress),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      height: 280,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userPos ?? const LatLng(-8.0640, -34.9430),
              initialZoom: 13.2,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'br.edu.busflow.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _rota,
                    strokeWidth: 5,
                    color: AppColors.primary,
                  ),
                ],
              ),
              ValueListenableBuilder<double>(
                valueListenable: _progress,
                builder: (context, p, _) {
                  final bus = _latLngAt(p);
                  return MarkerLayer(
                    markers: [
                      for (final i in _paradasIdx)
                        Marker(
                          point: _rota[i],
                          width: 18,
                          height: 18,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      if (_userPos != null)
                        Marker(
                          point: _userPos!,
                          width: 34,
                          height: 34,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0x332563EB),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x44000000),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Marker(
                        point: bus,
                        width: 42,
                        height: 42,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_bus,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_gpsBusy)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  else
                    Icon(
                      _userPos != null
                          ? Icons.my_location
                          : Icons.location_off_outlined,
                      size: 13,
                      color: _userPos != null
                          ? AppColors.green
                          : const Color(0xFFF59E0B),
                    ),
                  const SizedBox(width: 6),
                  Text(
                    _gpsBusy
                        ? 'Ativando GPS…'
                        : _userPos != null
                        ? 'GPS ativo — você está aqui'
                        : (_gpsError ?? 'Rota padrão'),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: ValueListenableBuilder<double>(
              valueListenable: _progress,
              builder: (context, p, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.badgeBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.directions_bus,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Próxima: ${_proximaParada(p)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(double progress) {
    final eta = math.max(1, ((1 - progress) * 14).ceil());
    final velocidade = (28 + math.sin(progress * math.pi * 6) * 7)
        .round()
        .clamp(18, 42);
    return Row(
      children: [
        _StatCard(
          icon: Icons.schedule,
          iconColor: AppColors.primary,
          label: 'Chegada em',
          value: '$eta min',
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.speed_outlined,
          iconColor: const Color(0xFFF59E0B),
          label: 'Velocidade',
          value: '$velocidade km/h',
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.event_seat_outlined,
          iconColor: AppColors.green,
          label: 'Ocupação',
          value: '42/50',
        ),
      ],
    );
  }

  Widget _buildStopsList(double progress) {
    final posicao = progress * (_stops.length - 1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paradas da Rota',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _stops.length; i++)
            _StopRow(
              nome: _stops[i],
              horario: _horarios[i],
              visited: i <= posicao,
              current: i > posicao && i - 1 <= posicao,
              isLast: i == _stops.length - 1,
            ),
        ],
      ),
    );
  }

  String _proximaParada(double progress) {
    final posicao = progress * (_stops.length - 1);
    final idx = math.min(posicao.ceil(), _stops.length - 1);
    if (progress >= 0.99) return 'Chegando';
    return _stops[idx];
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.hintGray),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.nome,
    required this.horario,
    required this.visited,
    required this.current,
    required this.isLast,
  });

  final String nome;
  final String horario;
  final bool visited;
  final bool current;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = visited
        ? AppColors.green
        : current
        ? AppColors.primary
        : AppColors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: visited || current ? color : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: visited || current ? color : AppColors.hintGray,
                    width: 2,
                  ),
                ),
                child: visited
                    ? const Icon(Icons.check, size: 9, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: visited ? AppColors.green : AppColors.border,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      nome,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: visited || current
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: visited || current
                            ? AppColors.textDark
                            : AppColors.textGray,
                      ),
                    ),
                  ),
                  if (current)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'A caminho',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else
                    Text(
                      horario,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.hintGray,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteProgressBar extends StatelessWidget {
  const _RouteProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 16,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  Positioned(
                    top: 6,
                    left: 6,
                    right: 6,
                    child: Container(height: 4, color: AppColors.border),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    width: (width - 12) * progress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  for (
                    var i = 0;
                    i < _RouteTrackingScreenState._stops.length;
                    i++
                  )
                    Positioned(
                      top: 3,
                      left:
                          (width - 12) *
                              (i /
                                  (_RouteTrackingScreenState._stops.length -
                                      1)) +
                          6 -
                          8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color:
                              i /
                                      (_RouteTrackingScreenState._stops.length -
                                          1) <=
                                  progress
                              ? AppColors.green
                              : AppColors.border,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final stop in _RouteTrackingScreenState._stops)
              Expanded(
                child: Text(
                  stop,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: AppColors.textGray,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
