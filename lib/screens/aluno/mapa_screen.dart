import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../theme.dart';
import '../../widgets/home_top_bar.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key, this.active = false});

  /// Constroi o FlutterMap apenas quando a aba e aberta pela primeira vez.
  final bool active;

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  bool _mapBuilt = false;
  int _filtro = 0;
  int _segundos = 12;
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  StreamSubscription<Position>? _locationSubscription;

  static const _filtros = [
    'Todas as Linhas',
    'Linha 04 (Central)',
    'Linha 02 (Terminal Sul)',
  ];

  static const _veiculos = [
    (
      nome: 'Carlos Mendes',
      placa: 'BRA2E19',
      linha: 'Linha 04',
      rota: 'Linha 04 • Campus Central',
      chegada: '4 min',
      status: '14 Vagas Disponíveis',
      tipo: 0,
      pos: LatLng(-8.0560, -34.9280),
      cor: Color(0xFFEF4444),
      rotulo: '#402',
    ),
    (
      nome: 'Marcos Souza',
      placa: 'QNP4A88',
      linha: 'Linha 02',
      rota: 'Linha 02 • Terminal Sul',
      chegada: '9 min',
      status: '2 Vagas Restantes',
      tipo: 1,
      pos: LatLng(-8.0720, -34.9560),
      cor: Color(0xFF2CA6E0),
      rotulo: '#405',
    ),
    (
      nome: 'Roberto Lima',
      placa: 'RIO1C23',
      linha: 'Linha 08',
      rota: 'Linha 08 • Vila Acadêmica',
      chegada: '12 min',
      status: 'Ônibus Lotado (0 vagas)',
      tipo: 2,
      pos: LatLng(-8.0505, -34.9620),
      cor: AppColors.green,
      rotulo: '#310',
    ),
  ];

  static const _userPos = LatLng(-8.0640, -34.9430);

  @override
  void initState() {
    super.initState();
    _mapBuilt = widget.active;
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active) _mapBuilt = true;
  }

  List<_Veiculo> get _visiveis {
    if (_filtro == 0) return _veiculos;
    final linha = _filtro == 1 ? 'Linha 04' : 'Linha 02';
    return _veiculos.where((v) => v.linha == linha).toList();
  }

  Future<void> _atualizarLocalizacao() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showMessage('Ative o serviço de localização do aparelho.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMessage('Permita o acesso à localização nas configurações.');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = point;
        _mapBuilt = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(point, 15);
      });
      await _locationSubscription?.cancel();
      _locationSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen(
            (updatedPosition) {
              if (!mounted) return;
              setState(
                () => _currentPosition = LatLng(
                  updatedPosition.latitude,
                  updatedPosition.longitude,
                ),
              );
            },
            onError: (Object error) {
              if (mounted) _showMessage('A atualização do GPS falhou: $error');
            },
          );
    } catch (error) {
      if (mounted) _showMessage('Não foi possível obter a localização: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeTopBar(subtitle: 'Mapa Ao Vivo'),
          const SizedBox(height: 16),
          _buildMapCard(),
          const SizedBox(height: 12),
          _buildStatusRow(),
          const SizedBox(height: 18),
          _buildVeiculosHeader(),
          const SizedBox(height: 12),
          _buildFiltros(),
          const SizedBox(height: 14),
          for (final v in _visiveis) ...[
            _VeiculoCard(v: v),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      height: 430,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          if (_mapBuilt)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition ?? _userPos,
                initialZoom: 13.4,
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
                      points: [
                        _veiculos[0].pos,
                        _currentPosition ?? _userPos,
                        _veiculos[1].pos,
                        _veiculos[2].pos,
                      ],
                      strokeWidth: 3,
                      color: AppColors.flowBlue.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    for (final v in _veiculos)
                      Marker(
                        point: v.pos,
                        width: 74,
                        height: 58,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x22000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                v.rotulo,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: v.cor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.directions_bus,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Marker(
                      point: _currentPosition ?? _userPos,
                      width: 160,
                      height: 64,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B63C8),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'VOCÊ ESTÁ AQUI (EU)',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 46,
                            height: 46,
                            decoration: const BoxDecoration(
                              color: Color(0x332563EB),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Container(
              color: AppColors.softBlue,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    size: 42,
                    color: AppColors.hintGray,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Carregando mapa ao vivo…',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: AppColors.flowBlue),
                  SizedBox(width: 6),
                  Text(
                    'Radar GPS Ativo',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
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
            child: Row(
              children: [
                _MapButton(
                  icon: Icons.my_location,
                  color: AppColors.textDark,
                  onTap: _atualizarLocalizacao,
                ),
                const SizedBox(width: 10),
                _MapButton(
                  icon: Icons.remove,
                  color: AppColors.textDark,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    (_mapController.camera.zoom - 1).clamp(3, 18).toDouble(),
                  ),
                ),
                const SizedBox(width: 6),
                _MapButton(
                  icon: Icons.add,
                  color: AppColors.textDark,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    (_mapController.camera.zoom + 1).clamp(3, 18).toDouble(),
                  ),
                ),
                const SizedBox(width: 10),
                _MapButton(
                  icon: Icons.tune,
                  color: Colors.white,
                  filled: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: _LegendItem(
                      color: Color(0xFFEF4444),
                      titulo: 'Lotado',
                      valor: '0 vagas',
                    ),
                  ),
                  _LegendDivider(),
                  Expanded(
                    child: _LegendItem(
                      color: AppColors.flowBlue,
                      titulo: 'Atenção',
                      valor: '1 a 5 vagas',
                    ),
                  ),
                  _LegendDivider(),
                  Expanded(
                    child: _LegendItem(
                      color: AppColors.green,
                      titulo: 'Com vagas',
                      valor: '> 5 vagas',
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

  Widget _buildStatusRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBlueBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.cell_tower, size: 15, color: Color(0xFF1E63B4)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              'Linhas atualizadas há ${_segundos}s • Satélite Galileo',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textGray),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _segundos = 0),
            behavior: HitTestBehavior.opaque,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Atualizar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E63B4),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.refresh, size: 14, color: Color(0xFF1E63B4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVeiculosHeader() {
    return Row(
      children: [
        const Icon(
          Icons.near_me_outlined,
          size: 17,
          color: AppColors.primaryDark,
        ),
        const SizedBox(width: 7),
        const Text(
          'Veículos em Circulação',
          style: TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.softBlueBorder),
          ),
          child: Text(
            '${_visiveis.length} no raio de 1.2km',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textGray,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltros() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < _filtros.length; i++) ...[
            GestureDetector(
              onTap: () => setState(() => _filtro = i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _filtro == i ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _filtro == i ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  _filtros[i],
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _filtro == i ? Colors.white : AppColors.textGray,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

typedef _Veiculo = ({
  String nome,
  String placa,
  String linha,
  String rota,
  String chegada,
  String status,
  int tipo,
  LatLng pos,
  Color cor,
  String rotulo,
});

class _VeiculoCard extends StatelessWidget {
  const _VeiculoCard({required this.v});

  final _Veiculo v;

  static const _statusStyle = [
    (Color(0xFFEFF4FF), AppColors.green, 1),
    (Color(0xFFEFF4FF), Color(0xFF1D4ED8), 1),
    (Color(0xFFFEE2E2), Color(0xFFDC2626), 0),
  ];

  @override
  Widget build(BuildContext context) {
    final (bg, fg, _) = _statusStyle[v.tipo];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      v.nome.split(' ').map((p) => p[0]).take(2).join(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: v.cor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            v.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.softBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            v.placa,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      v.rota,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    v.chegada,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B63C8),
                    ),
                  ),
                  const Text(
                    'chegada',
                    style: TextStyle(fontSize: 11, color: AppColors.textGray),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    v.status,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text('Abrindo rota da ${v.linha}…')),
                      );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver rota',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B63C8),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Color(0xFF1B63C8),
                      ),
                    ],
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

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.titulo,
    required this.valor,
  });

  final Color color;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendDivider extends StatelessWidget {
  const _LegendDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.border,
    );
  }
}
