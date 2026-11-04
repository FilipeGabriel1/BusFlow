import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/admin_data_store.dart';
import '../../theme.dart';
import '../../widgets/admin_top_bar.dart';

class AdminFrotaScreen extends StatefulWidget {
  const AdminFrotaScreen({super.key});

  @override
  State<AdminFrotaScreen> createState() => _AdminFrotaScreenState();
}

class _AdminFrotaScreenState extends State<AdminFrotaScreen> {
  int _aba = 0;
  int _filtro = 0;

  static const _filtros = ['Todos', 'Em Rota', 'Parados', 'Manutenção'];

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<VeiculoFrota> _filtrados(AdminDataStore store) {
    switch (_filtro) {
      case 1:
        return store.veiculos.where((v) => v.status == 'Em Rota').toList();
      case 2:
        return store.veiculos
            .where((v) => v.status == 'Parado' || v.status == 'Sem motorista')
            .toList();
      case 3:
        return store.veiculos.where((v) => v.status == 'Manutenção').toList();
      default:
        return store.veiculos;
    }
  }

  Future<void> _cadastrarOnibus(AdminDataStore store) async {
    final modelo = TextEditingController();
    final placa = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Cadastrar Ônibus',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: modelo,
              decoration: const InputDecoration(
                labelText: 'Modelo',
                hintText: 'Ex: Caio Apache',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: placa,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Placa',
                hintText: 'ABC1D23',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final m = modelo.text.trim();
    final p = placa.text.trim();
    if (m.isEmpty || p.isEmpty) {
      _snack('Informe modelo e placa para cadastrar.');
      return;
    }
    store.cadastrarVeiculo(m, p.toUpperCase());
    _snack('Ônibus $m ($p) cadastrado na frota.');
  }

  @override
  Widget build(BuildContext context) {
    final store = AdminDataStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AdminTopBar(),
              const SizedBox(height: 16),
              _buildHeader(store),
              const SizedBox(height: 16),
              _buildAbas(store),
              const SizedBox(height: 14),
              if (_aba == 0) ...[
                _buildMapa(),
                const SizedBox(height: 16),
                Text(
                  'Veículos Cadastrados (${store.veiculos.length} ativos)',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                _buildFiltros(),
                const SizedBox(height: 12),
                ..._listaVeiculos(store),
                const SizedBox(height: 16),
                _buildDistribuicao(store),
              ] else
                _buildRotas(store),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AdminDataStore store) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frota e Rotas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Acompanhamento de desempenho operacional e veículos em tempo real',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          key: const ValueKey('cadastrar-onibus'),
          onPressed: () => _cadastrarOnibus(store),
          icon: const Icon(Icons.add, size: 16),
          label: const Text(
            'Cadastrar Ônibus',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbas(AdminDataStore store) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tabBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabBtn(
              label: 'Ônibus & Frota (${store.veiculos.length})',
              active: _aba == 0,
              onTap: () => setState(() => _aba = 0),
            ),
          ),
          Expanded(
            child: _TabBtn(
              label: 'Rotas & Viagens (${store.rotasAtivas.length})',
              active: _aba == 1,
              onTap: () => setState(() => _aba = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filtros.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final ativo = _filtro == i;
          return GestureDetector(
            onTap: () => setState(() => _filtro = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: ativo ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ativo ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                _filtros[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ativo ? Colors.white : AppColors.textGray,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _listaVeiculos(AdminDataStore store) {
    final lista = _filtrados(store);
    if (lista.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.directions_bus_outlined,
                size: 30,
                color: AppColors.hintGray,
              ),
              SizedBox(height: 8),
              Text(
                'Nenhum veículo neste filtro',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Ajuste o filtro ou cadastre um novo ônibus.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
        ),
      ];
    }
    return [
      for (final v in lista) ...[
        _VeiculoCard(
          veiculo: v,
          onAtribuir: () {
            store.designarMotorista(v, 'Substituto Designado');
            _snack('Motorista designado para o ônibus #${v.id}.');
          },
          onEditar: () =>
              _snack('Editando cadastro do ônibus #${v.id} — ${v.modelo}.'),
        ),
        const SizedBox(height: 10),
      ],
    ];
  }

  Widget _buildMapa() {
    final veiculos = AdminDataStore.instance.veiculos;
    return Container(
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-8.0560, -34.9280),
              initialZoom: 12.4,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'br.edu.busflow.admin',
              ),
              MarkerLayer(
                markers: [
                  for (var i = 0; i < veiculos.length; i++)
                    Marker(
                      point: _posicoes[i % _posicoes.length],
                      width: 40,
                      height: 40,
                      child: Tooltip(
                        message: '${veiculos[i].placa} • ${veiculos[i].linha}',
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: veiculos[i].status == 'Em Rota'
                                ? AppColors.primary
                                : veiculos[i].status == 'Manutenção'
                                    ? const Color(0xFFF59E0B)
                                    : AppColors.textGray,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_bus,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
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
                  Icon(Icons.circle, size: 8, color: AppColors.greenDot),
                  SizedBox(width: 6),
                  Text(
                    'Rastreamento OSM ao vivo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: ElevatedButton.icon(
              key: const ValueKey('abrir-mapa'),
              onPressed: () => _snack('Abrindo mapa de rastreamento ao vivo.'),
              icon: const Icon(Icons.map_outlined, size: 16),
              label: const Text(
                'Abrir Mapa de Rastreamento',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _posicoes = [
    LatLng(-8.0560, -34.9280),
    LatLng(-8.0720, -34.9560),
    LatLng(-8.0505, -34.9620),
    LatLng(-8.0480, -34.9050),
    LatLng(-8.0830, -34.9410),
    LatLng(-8.0390, -34.9380),
  ];

  Widget _buildDistribuicao(AdminDataStore store) {
    final total = store.veiculos.length;
    final emRota = store.veiculosEmRota;
    final parados = store.veiculosParados + store.veiculosSemMotorista;
    final manut = store.veiculosManutencao;
    double pct(int v) => total == 0 ? 0 : (v / total) * 100;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISTRIBUIÇÃO DA FROTA EM TEMPO REAL',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.hintGray,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legenda(
                cor: AppColors.green,
                label: 'Em Rota',
                pct: '${pct(emRota).round()}%',
              ),
              const SizedBox(width: 14),
              _Legenda(
                cor: AppColors.flowBlue,
                label: 'Parados',
                pct: '${pct(parados).round()}%',
              ),
              const SizedBox(width: 14),
              _Legenda(
                cor: const Color(0xFFF59E0B),
                label: 'Manutenção',
                pct: '${pct(manut).round()}%',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Expanded(
                  flex: emRota == 0 ? 1 : emRota,
                  child: Container(height: 10, color: AppColors.green),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: parados == 0 ? 1 : parados,
                  child: Container(height: 10, color: AppColors.flowBlue),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: manut == 0 ? 1 : manut,
                  child: Container(height: 10, color: const Color(0xFFF59E0B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotas(AdminDataStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Rotas Acadêmicas Ativas (${store.rotasAtivas.length})',
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        if (store.rotasAtivas.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.route_outlined, size: 30, color: AppColors.hintGray),
                SizedBox(height: 8),
                Text(
                  'Nenhuma rota ativa',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'As linhas programadas aparecerão aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
              ],
            ),
          )
        else
          for (final r in store.rotasAtivas) ...[
            _RotaCard(rota: r),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
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
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textGray,
          ),
        ),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({
    required this.cor,
    required this.label,
    required this.pct,
  });

  final Color cor;
  final String label;
  final String pct;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$pct $label',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

Color _statusCor(String status) {
  switch (status) {
    case 'Em Rota':
      return AppColors.green;
    case 'Manutenção':
      return const Color(0xFFF59E0B);
    case 'Parado':
      return AppColors.flowBlue;
    default:
      return AppColors.textGray;
  }
}

class _VeiculoCard extends StatelessWidget {
  const _VeiculoCard({
    required this.veiculo,
    required this.onAtribuir,
    required this.onEditar,
  });

  final VeiculoFrota veiculo;
  final VoidCallback onAtribuir;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final cor = _statusCor(veiculo.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '#${veiculo.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  veiculo.modelo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: cor),
                    const SizedBox(width: 4),
                    Text(
                      veiculo.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: cor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Placa: ${veiculo.placa} • ${veiculo.linha}',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textGray),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.softBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      veiculo.motorista,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      veiculo.motoristaDetalhe,
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
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              veiculo.lote,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textGray,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEditar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Editar Dados',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAtribuir,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text(
                    veiculo.acaoSecundaria,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RotaCard extends StatelessWidget {
  const _RotaCard({required this.rota});

  final RotaAtivaAdmin rota;

  @override
  Widget build(BuildContext context) {
    final cor = rota.status == 'Em Rota'
        ? AppColors.green
        : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  rota.codigo,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${rota.origem} → ${rota.destino}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  rota.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: cor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rota.horarios,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textGray),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 14,
                color: AppColors.hintGray,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  rota.passageiros,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textGray,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Ver Paradas',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

