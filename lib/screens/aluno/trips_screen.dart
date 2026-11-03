import 'package:flutter/material.dart';

import '../../services/reservation_store.dart';
import '../../theme.dart';
import '../../widgets/home_top_bar.dart';
import 'route_tracking_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  int _day = 0;
  int _timeFilter = 0;
  int _tab = 0;

  static const _weekdayLabels = ['SEG', 'TER', 'QUA', 'QUI', 'SEX'];
  static const _monthLabels = [
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

  late final List<({String weekday, String day, String month, bool isToday})>
  _week;

  @override
  void initState() {
    super.initState();
    _week = _buildWeek();
    final now = DateTime.now();
    _day = now.weekday <= DateTime.friday ? now.weekday - 1 : 0;
  }

  static List<({String weekday, String day, String month, bool isToday})>
  _buildWeek() {
    final now = DateTime.now();
    var monday = now.subtract(Duration(days: now.weekday - 1));
    if (now.weekday >= DateTime.saturday) {
      monday = monday.add(const Duration(days: DateTime.daysPerWeek));
    }
    return List<
      ({String weekday, String day, String month, bool isToday})
    >.generate(5, (i) {
      final date = monday.add(Duration(days: i));
      return (
        weekday: _weekdayLabels[i],
        day: date.day.toString().padLeft(2, '0'),
        month: _monthLabels[date.month - 1],
        isToday:
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day,
      );
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  final _viagens = const [
    _Viagem(
      line: 'Linha 04',
      priority: 'Alta Prioridade',
      priorityColor: AppColors.primary,
      priorityBg: Color(0xFFDBEAFE),
      destination: 'Campus Central → Terminal Norte*',
      time: '21:30',
      prevTime: 'Prev. 22:05',
      embarque: 'Embarque: Terminal Norte • Ponto 4',
      tech: 'Tecnologia: Biometria Facial',
      ocupados: 28,
      total: 40,
      waitlist: false,
      onibus: 'Ônibus #402 • Rota Noturna',
      placa: 'Placa: BRF-2020',
    ),
    _Viagem(
      line: 'Linha 02',
      priority: 'Alta Prioridade',
      priorityColor: AppColors.primary,
      priorityBg: Color(0xFFDBEAFE),
      destination: 'Campus Central → Bairro Vila Universitária',
      time: '22:00',
      prevTime: 'Prev. 23:15',
      embarque: 'Embarque: Bairro Central • Ponto 1',
      ocupados: 38,
      total: 40,
      waitlist: false,
      reserveLabel: 'Garantir Últimas Vagas',
      reserveIcon: Icons.how_to_reg,
      onibus: 'Ônibus #215 • Rota Expressa',
      placa: 'Placa: RFT-2018',
    ),
    _Viagem(
      line: 'Linha 08',
      priority: 'Emergencial',
      priorityColor: Color(0xFFDC2626),
      priorityBg: Color(0xFFFEE2E2),
      destination: 'Campus Central → Conexão Leste',
      time: '22:15',
      prevTime: 'Prev. 23:05',
      embarque: 'Embarque: Terminal Leste • Parada 3',
      ocupados: 40,
      total: 40,
      waitlist: true,
      reserveLabel: 'Entrar na Fila de Espera',
      reserveIcon: Icons.hourglass_bottom,
      onibus: 'Ônibus #330 • Conexão Leste',
      placa: 'Placa: BQR-2022',
    ),
    _Viagem(
      line: 'Linha 11',
      priority: 'Turno Estendido',
      priorityColor: Color(0xFF4F46E5),
      priorityBg: Color(0xFFE0E7FF),
      destination: 'Laboratórios Integrados → Residencial Estudantil',
      time: '23:00',
      prevTime: 'Prev. 23:45',
      embarque: 'Embarque: Laboratórios • Ponto 2',
      ocupados: 15,
      total: 40,
      waitlist: false,
      onibus: 'Ônibus #108 • Turno Noturno',
      placa: 'Placa: PLC-2019',
    ),
  ];

  void _onTripButton(int index) {
    final store = ReservationStore.instance;
    final v = _viagens[index];
    if (store.tripIndex == index) {
      store.cancel();
      _snack('Reserva da ${v.line} cancelada. A vaga foi liberada.');
      return;
    }
    if (store.hasReservation) {
      final outra = _viagens[store.tripIndex!];
      _snack(
        'Você já tem uma vaga na ${outra.line}. '
        'Cancele antes de reservar outra viagem.',
      );
      return;
    }
    if (v.waitlist) {
      _snack(
        'Você entrou na fila de espera da ${v.line}. '
        'Avisaremos se uma vaga abrir.',
      );
      return;
    }
    store.reserve(index);
    _snack(
      'Reserva confirmada na ${v.line}! '
      'Seu QR Pass foi enviado para o e-mail.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ReservationStore.instance,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeTopBar(),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Rotas e Viagens',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      size: 17,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Consulte horários, reserve assentos e acompanhe linhas acadêmicas.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 16),
              _buildRouteSelectors(),
              const SizedBox(height: 16),
              _buildDayStrip(),
              const SizedBox(height: 14),
              _buildTimeFilters(),
              const SizedBox(height: 18),
              if (_tab == 0) ...[
                _buildActiveTripCard(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Próximas Partidas Noturnas',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      'Atualizado há 4 min',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.hintGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < _viagens.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _buildTripCard(i),
                ],
                const SizedBox(height: 14),
                _buildHistoryCard(),
              ] else
                _buildHistoryTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tab = 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _tab == 0 ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _tab == 0 ? AppColors.primary : AppColors.border,
                  width: _tab == 0 ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_view_week,
                        size: 17,
                        color: _tab == 0
                            ? AppColors.primary
                            : AppColors.textGray,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Dias Úteis',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: _tab == 0
                              ? AppColors.primary
                              : AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Seg - Sex',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: _tab == 0 ? AppColors.primary : AppColors.hintGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tab = 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _tab == 1 ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _tab == 1 ? AppColors.primary : AppColors.border,
                  width: _tab == 1 ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 17,
                        color: _tab == 1
                            ? AppColors.primary
                            : AppColors.textGray,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Histórico',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: _tab == 1
                              ? AppColors.primary
                              : AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Minhas viagens',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: _tab == 1 ? AppColors.primary : AppColors.hintGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteSelectors() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Campus / Origem',
                style: TextStyle(fontSize: 10.5, color: AppColors.hintGray),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Campus Central',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rota / Destino',
                style: TextStyle(fontSize: 10.5, color: AppColors.hintGray),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Terminal Eixa Sul',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayStrip() {
    return Row(
      children: [
        for (var i = 0; i < _week.length; i++) ...[
          if (i > 0) const SizedBox(width: 7),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _day = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _day == i ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _day == i
                        ? AppColors.primary
                        : _week[i].isToday
                        ? AppColors.primary.withValues(alpha: 0.45)
                        : AppColors.border,
                    width: _day == i || _week[i].isToday ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _week[i].weekday,
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: _day == i
                            ? const Color(0xFFBFDBFE)
                            : _week[i].isToday
                            ? AppColors.primary
                            : AppColors.hintGray,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _week[i].day,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _day == i
                            ? Colors.white
                            : _week[i].isToday
                            ? AppColors.primary
                            : AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      _week[i].month,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: _day == i
                            ? const Color(0xFFBFDBFE)
                            : _week[i].isToday
                            ? AppColors.primary
                            : AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeFilters() {
    const filters = ['Todos', 'Manhã (07h-12h)', 'Tarde (13h-18h)'];
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < filters.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _timeFilter = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _timeFilter == i
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _timeFilter == i
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        filters[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _timeFilter == i
                              ? Colors.white
                              : AppColors.textGray,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.refresh, size: 17, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildTripCard(int index) {
    final v = _viagens[index];
    final store = ReservationStore.instance;
    final reservadaAqui = store.tripIndex == index;
    final ocupados = v.ocupados + (reservadaAqui ? 1 : 0);
    final vagas = v.total - ocupados;
    final pct = ocupados / v.total;
    final pill = vagas == 0
        ? 'Sem vagas'
        : vagas <= 2
        ? 'Apenas $vagas vagas disponíveis!'
        : '$vagas vagas disponíveis';
    return _TripCard(
      line: v.line,
      priority: v.priority,
      priorityColor: v.priorityColor,
      priorityBg: v.priorityBg,
      destination: v.destination,
      time: v.time,
      prevTime: v.prevTime,
      embarque: v.embarque,
      tech: v.tech,
      occupancy:
          'Ocupação: $ocupados de ${v.total} lugares '
          '(${(pct * 100).round()}%)',
      occupancyPill: pill,
      occupancyPillGreen: vagas > 2,
      percent: pct,
      buttonLabel: reservadaAqui ? 'Cancelar Vaga' : v.reserveLabel,
      buttonIcon: reservadaAqui ? Icons.close : v.reserveIcon,
      buttonFilled: !reservadaAqui && !v.waitlist,
      reserved: reservadaAqui,
      onPressed: () => _onTripButton(index),
    );
  }

  Widget _buildActiveTripCard() {
    final store = ReservationStore.instance;
    final idx = store.tripIndex;
    if (idx == null) return _buildEmptyReservationCard();
    final v = _viagens[idx];
    final ocupados = v.ocupados + 1;
    final vagas = v.total - ocupados;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'VIAGEM AGENDADA • EM ROTA',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.directions_bus,
                size: 20,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${v.line} • ${v.destination}',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(label: 'Horário', value: v.time),
              const SizedBox(width: 18),
              _Stat(label: 'Prev.', value: v.prevTime),
              const SizedBox(width: 18),
              _Stat(label: 'Assentos', value: '$ocupados/${v.total}'),
              const Spacer(),
              Text(
                vagas > 0 ? 'Disponível' : 'Lotado',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: vagas > 0 ? AppColors.green : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Carlos Mendes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      v.onibus,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                v.placa,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Progresso da Rota',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Próxima parada: Porto 02',
                style: TextStyle(fontSize: 10.5, color: AppColors.hintGray),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RouteProgress(
            stops: const ['Porto 02', 'Campus Central', 'Terminal Sul'],
            progress: 0.35,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RouteTrackingScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.navigation, size: 17),
              label: const Text(
                'Acompanhar Rota ao Vivo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () {
                ReservationStore.instance.cancel();
                _snack(
                  'Reserva cancelada com sucesso. Nenhuma penalidade aplicada.',
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                backgroundColor: const Color(0xFFFEF2F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.close, size: 17),
              label: const Text(
                'Cancelar Reserva',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 14,
                color: Color(0xFFF59E0B),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Cancelamento sem penalidade permitido até 30min antes da partida.',
                  style: TextStyle(fontSize: 10.5, color: AppColors.hintGray),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReservationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nenhuma viagem reservada',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escolha uma partida abaixo, reserve sua vagae acompanhe o ônibus ao vivo pelo mapa com GPS.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
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
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Histórico de Viagens',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '1.420 viagens validadas no sistema',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textGray),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            children: [
              Icon(Icons.history, size: 40, color: AppColors.hintGray),
              SizedBox(height: 12),
              Text(
                'Histórico de Viagens',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Suas viagens realizadas aparecerão aqui.\n1.420 viagens validadas no sistema.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.hintGray),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _RouteProgress extends StatelessWidget {
  const _RouteProgress({required this.stops, required this.progress});

  final List<String> stops;
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
                    child: Container(height: 4, color: const Color(0xFFE2E8F0)),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    width: (width - 12) * progress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  for (var i = 0; i < stops.length; i++)
                    Positioned(
                      top: 3,
                      left: (width - 12) * (i / (stops.length - 1)) + 6 - 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: i / (stops.length - 1) <= progress
                              ? AppColors.primary
                              : const Color(0xFFE2E8F0),
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
            for (final stop in stops)
              Text(
                stop,
                style: const TextStyle(fontSize: 9, color: AppColors.textGray),
              ),
          ],
        ),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.line,
    required this.priority,
    required this.priorityColor,
    required this.priorityBg,
    required this.destination,
    required this.time,
    required this.prevTime,
    required this.embarque,
    this.tech,
    required this.occupancy,
    required this.occupancyPill,
    required this.occupancyPillGreen,
    required this.percent,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.buttonFilled,
    required this.reserved,
    required this.onPressed,
  });

  final String line;
  final String priority;
  final Color priorityColor;
  final Color priorityBg;
  final String destination;
  final String time;
  final String prevTime;
  final String embarque;
  final String? tech;
  final String occupancy;
  final String occupancyPill;
  final bool occupancyPillGreen;
  final double percent;
  final String buttonLabel;
  final IconData buttonIcon;
  final bool buttonFilled;
  final bool reserved;
  final VoidCallback onPressed;

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final barColor = percent >= 0.8
        ? const Color(0xFFDC2626)
        : percent >= 0.6
        ? const Color(0xFFF59E0B)
        : AppColors.green;

    return Container(
      padding: const EdgeInsets.all(15),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  line,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: priorityColor,
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
                child: Text(
                  destination,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    prevTime,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.hintGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            embarque,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textGray),
          ),
          if (tech != null) ...[
            const SizedBox(height: 5),
            Text(
              tech!,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textGray),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  occupancy,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: occupancyPillGreen
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  occupancyPill,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: occupancyPillGreen
                        ? AppColors.green
                        : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 7,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: reserved
                      ? OutlinedButton.icon(
                          onPressed: onPressed,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            backgroundColor: const Color(0xFFFEF2F2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          icon: Icon(buttonIcon, size: 16),
                          label: Text(
                            buttonLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : buttonFilled
                      ? ElevatedButton.icon(
                          onPressed: onPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          icon: Icon(buttonIcon, size: 16),
                          label: Text(
                            buttonLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: onPressed,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          icon: Icon(buttonIcon, size: 16),
                          label: Text(
                            buttonLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _snack(context, 'Abrindo itinerário da $line...'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textGray,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  icon: const Icon(Icons.route, size: 16),
                  label: const Text(
                    'Itinerário',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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

class _Viagem {
  const _Viagem({
    required this.line,
    required this.priority,
    required this.priorityColor,
    required this.priorityBg,
    required this.destination,
    required this.time,
    required this.prevTime,
    required this.embarque,
    this.tech,
    required this.ocupados,
    required this.total,
    required this.waitlist,
    this.reserveLabel = 'Reservar Vaga',
    this.reserveIcon = Icons.event_available,
    required this.onibus,
    required this.placa,
  });

  final String line;
  final String priority;
  final Color priorityColor;
  final Color priorityBg;
  final String destination;
  final String time;
  final String prevTime;
  final String embarque;
  final String? tech;
  final int ocupados;
  final int total;
  final bool waitlist;
  final String reserveLabel;
  final IconData reserveIcon;
  final String onibus;
  final String placa;
}
