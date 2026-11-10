import 'package:flutter/material.dart';

import '../../services/student_storage.dart';
import 'aluno_servicos_screen.dart';
import '../../theme.dart';
import '../../widgets/configuracoes_widgets.dart';
import '../../widgets/home_top_bar.dart';
import '../../widgets/profile_photo_picker.dart';

class ContaAlunoScreen extends StatefulWidget {
  const ContaAlunoScreen({
    super.key,
    this.onOpenHistory,
    this.onOpenCarteirinha,
  });

  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenCarteirinha;

  @override
  State<ContaAlunoScreen> createState() => _ContaAlunoScreenState();
}

class _ContaAlunoScreenState extends State<ContaAlunoScreen> {
  String _nome = 'Ana Costa';
  String _profilePhoto = '';

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
        _profilePhoto = aluno['profilePhoto'] ?? '';
        if (aluno['nome']?.isNotEmpty == true) {
          final partes = aluno['nome']!.trim().split(RegExp(r'\s+'));
          _nome = partes.length > 1
              ? '${partes.first} ${partes.last}'
              : partes.first;
        }
      });
    } catch (_) {
      // Sem preferências disponíveis — mantém o nome de demonstração.
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openStudentServices(int tab) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AlunoServicosScreen(initialTab: tab),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeTopBar(subtitle: 'Minha Conta'),
          const SizedBox(height: 18),
          _buildGreetingCard(),
          const SizedBox(height: 16),
          _buildRotaCard(),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Ações do Estudante',
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                'Autoatendimento',
                style: TextStyle(fontSize: 11.5, color: AppColors.textGray),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAcoesGrid(),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Últimas Solicitações',
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                '3 registros recentes',
                style: TextStyle(fontSize: 11.5, color: AppColors.textGray),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSolicitacao(
            numero: '#2026-892',
            titulo: 'Ausência Justificada',
            detalhe: 'Registrado hoje, 14:20',
            badge: 'Em Atendimento',
            badgeBg: AppColors.softBlue,
            badgeFg: const Color(0xFF1E63B4),
            icon: Icons.event_busy_outlined,
          ),
          const SizedBox(height: 10),
          _buildSolicitacao(
            numero: '#2026-810',
            titulo: 'Troca de Turno eventual',
            detalhe: 'Ontem, 09:15',
            badge: 'Concluído',
            badgeBg: AppColors.badgeBg,
            badgeFg: AppColors.green,
            icon: Icons.swap_horiz_outlined,
          ),
          const SizedBox(height: 10),
          _buildSolicitacao(
            numero: '#2026-940',
            titulo: 'Objeto Perdido',
            detalhe: '22 de Fev, 18:40',
            badge: 'Em Análise',
            badgeBg: AppColors.softBlue,
            badgeFg: const Color(0xFF1E63B4),
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: widget.onOpenHistory,
            behavior: HitTestBehavior.opaque,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ver histórico de viagens',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E63B4),
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 16, color: Color(0xFF1E63B4)),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Configurações',
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                'Conta e preferências',
                style: TextStyle(fontSize: 11.5, color: AppColors.textGray),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConfiguracoesCard(onDadosAtualizados: _loadAluno),
          const SizedBox(height: 12),
          const LogoutCard(),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ProfilePhotoAvatar(photo: _profilePhoto, size: 52),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: AppColors.greenDot,
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
                        'Olá, $_nome!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: Color(0xFF1E63B4),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.badgeBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.badgeBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: AppColors.greenDot,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Estudante • Ativo',
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
                    Flexible(
                      child: Text(
                        'Matrícula: 2024-8841',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onOpenCarteirinha,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.badge_outlined,
                size: 21,
                color: Color(0xFF1E63B4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E63B4), Color(0xFF17457F)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17457F).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus, size: 16, color: Colors.white),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'LINHA UNIVERSITÁRIA #04',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenDot,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'Em andamento',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Campus → Centro',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.near_me_outlined,
                      size: 17,
                      color: Color(0xFF93C5FD),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ônibus em rota a 4 quadras do seu ponto',
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.35,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Horário estimado de parada: 19:34 '
                            '(Saída da garagem: 19:30)',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.4,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _RotaStepper(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 15,
                color: Color(0xFF93C5FD),
              ),
              const SizedBox(width: 7),
              Text(
                'Próxima Saída regular:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Quinta-feira, às 08:00',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcoesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        _AcaoCard(
          icon: Icons.event_busy_outlined,
          iconBg: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          trailing: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
          titulo: 'Desistência de Vaga',
          descricao: '(Avisa que não usará o ônibus no dia)',
          onTap: () => _snack(
            'Para desistir de uma vaga, abra o histórico da viagem e selecione a reserva.',
          ),
        ),
        _AcaoCard(
          icon: Icons.watch_later_outlined,
          iconBg: AppColors.softBlue,
          iconColor: const Color(0xFF1E63B4),
          trailing: const Icon(
            Icons.schedule,
            size: 17,
            color: AppColors.hintGray,
          ),
          titulo: 'Pedir Espera',
          descricao: '(Notifica atraso na saída da aula)',
          onTap: () => _openStudentServices(0),
        ),
        _AcaoCard(
          icon: Icons.calendar_month_outlined,
          iconBg: AppColors.softBlue,
          iconColor: const Color(0xFF1E63B4),
          trailing: const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.hintGray,
          ),
          titulo: 'Calendário de Rotas',
          descricao: 'Consulte horários e semestres',
          onTap: () => _openStudentServices(1),
        ),
        _AcaoCard(
          icon: Icons.inventory_2_outlined,
          iconBg: AppColors.tabBg,
          iconColor: AppColors.textGray,
          trailing: const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.hintGray,
          ),
          titulo: 'Achados e Perdidos',
          descricao: 'Registre itens esquecidos a bordo',
          onTap: () => _openStudentServices(2),
        ),
      ],
    );
  }

  Widget _buildSolicitacao({
    required String numero,
    required String titulo,
    required String detalhe,
    required String badge,
    required Color badgeBg,
    required Color badgeFg,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF1E63B4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  numero,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E63B4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detalhe,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeFg.withValues(alpha: 0.25)),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: badgeFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AcaoCard extends StatelessWidget {
  const _AcaoCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.trailing,
    required this.titulo,
    required this.descricao,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Widget trailing;
  final String titulo;
  final String descricao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                trailing,
              ],
            ),
            const Spacer(),
            Text(
              titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.25,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              descricao,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                height: 1.35,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RotaStepper extends StatelessWidget {
  const _RotaStepper();

  static const _paradas = ['Campus', 'Av. Brasil', 'Seu Ponto', 'Centro'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 24,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              const inset = 12.0;
              final span = w - inset * 2;
              double cx(int i) => inset + span * (i / (_paradas.length - 1));
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: inset,
                    right: inset,
                    top: 10,
                    child: Container(height: 3, color: Colors.white24),
                  ),
                  Positioned(
                    left: inset,
                    top: 10,
                    width: span / (_paradas.length - 1),
                    child: Container(height: 3, color: Colors.white),
                  ),
                  Positioned(
                    left: cx(0) - 7,
                    top: 5,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF93C5FD),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: cx(1) - 11,
                    top: 1,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF60A5FA),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: cx(2) - 7,
                    top: 5,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: cx(3) - 6,
                    top: 6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white38,
                        shape: BoxShape.circle,
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
          children: [
            for (var i = 0; i < _paradas.length; i++)
              Expanded(
                child: Text(
                  _paradas[i],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: i == 1 ? FontWeight.w800 : FontWeight.w600,
                    color: i == 3
                        ? Colors.white.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
