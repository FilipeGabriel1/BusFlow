import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../services/admin_data_store.dart';
import '../../services/admin_report_service.dart';
import '../../theme.dart';
import '../../widgets/admin_top_bar.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key, this.onOpenFrota, this.onOpenUsuarios});

  final VoidCallback? onOpenFrota;
  final VoidCallback? onOpenUsuarios;

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _emitReport(AdminDataStore store) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Relatório geral em PDF',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Visualizar / Imprimir'),
              onTap: () => Navigator.pop(context, 'print'),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Enviar para outro aplicativo'),
              onTap: () => Navigator.pop(context, 'share'),
            ),
          ],
        ),
      ),
    );
    if (action == null) return;
    try {
      final bytes = await AdminReportService.createPdf(store);
      if (action == 'print') {
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name: 'busflow-relatorio-geral.pdf',
        );
      } else {
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'busflow-relatorio-geral.pdf',
          subject: 'Relatório geral BusFlow',
          body: 'Relatório geral gerado pelo BusFlow.',
        );
      }
    } catch (error) {
      if (mounted) {
        _snack('Não foi possível gerar ou compartilhar o PDF: $error');
      }
    }
  }

  static String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
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
              const SizedBox(height: 14),
              _buildStatusRow(),
              const SizedBox(height: 14),
              _buildGreeting(store),
              const SizedBox(height: 16),
              _buildMetricas(store),
              const SizedBox(height: 16),
              _buildViagensRealizadas(store),
              const SizedBox(height: 16),
              _buildAlertas(store),
              const SizedBox(height: 18),
              const Text(
                'AÇÕES DE GESTÃO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.hintGray,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              _AcaoCard(
                key: const ValueKey('acao-frota'),
                icon: Icons.directions_bus_outlined,
                title: 'Gerenciar Frota',
                subtitle:
                    '${store.onibusTotal} veículos operacionais e manutenção',
                badge: '${store.onibusTotal} ativos',
                onTap: widget.onOpenFrota ?? () {},
              ),
              const SizedBox(height: 10),
              _AcaoCard(
                key: const ValueKey('acao-usuarios'),
                icon: Icons.people_outline,
                title: 'Gerenciar Usuários',
                subtitle: 'Estudantes, motoristas e aprovações',
                badge: '${store.solicitacoesAbertas} pendentes',
                onTap: widget.onOpenUsuarios ?? () {},
              ),
              const SizedBox(height: 10),
              _AcaoCard(
                key: const ValueKey('acao-rotas'),
                icon: Icons.route_outlined,
                title: 'Ver Rotas e Escalas',
                subtitle: '8 linhas ativas, itinerários e turnos',
                badge: '8 ativos',
                onTap: () => widget.onOpenFrota?.call(),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  key: const ValueKey('emitir-relatorio'),
                  onPressed: () => _emitReport(store),
                  icon: const Icon(
                    Icons.download_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Emitir Relatório Geral (PDF/Excel)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    backgroundColor: AppColors.softBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sync, size: 13, color: AppColors.hintGray),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Dados sincronizados a cada 15 segundos com telemetria GPS dos veículos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: AppColors.hintGray,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.badgeBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.badgeBorder),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: AppColors.greenDot),
              SizedBox(width: 6),
              Text(
                'Sistema Online • 99.9% Uptime',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const Text(
          'CCO • 2026/1',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(AdminDataStore store) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, ${store.primeiroNome}!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Centro de Controle Operacional • Gestão Acadêmica Unificada',
            style: TextStyle(fontSize: 12.5, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricas(AdminDataStore store) {
    final pctFrota = ((store.onibusOperacionais / store.onibusTotal) * 100)
        .round();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                valor: _fmt(store.alunosCadastrados),
                badge: '+${store.alunosNovos}',
                badgeCor: AppColors.green,
                titulo: 'Alunos Cadastrados',
                subtitulo: 'Ativos no sistema',
                icone: Icons.school_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                valor: '${store.motoristasAtivos}',
                badge: 'de ${store.motoristasTotal} total',
                badgeCor: AppColors.primary,
                titulo: 'Motoristas em Turno',
                subtitulo: 'Turno em progresso',
                icone: Icons.badge_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                valor: '${store.onibusOperacionais}/${store.onibusTotal}',
                badge: '${store.onibusManual} manual',
                badgeCor: const Color(0xFFF59E0B),
                titulo: 'Ônibus Operacionais',
                subtitulo: '$pctFrota% frota operacional',
                icone: Icons.directions_bus_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                valor: '${store.viagensEmCurso}',
                badge: 'Ao vivo',
                badgeCor: AppColors.flowBlue,
                titulo: 'Viagens em Curso',
                subtitulo: '${store.viagensEmbarque} em embarque',
                icone: Icons.play_circle_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViagensRealizadas(AdminDataStore store) {
    final max = store.viagensSemana.fold<int>(0, (a, b) => b > a ? b : a);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Viagens Realizadas',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Distribuição semanal da CCO',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.badgeBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 12, color: AppColors.green),
                    SizedBox(width: 4),
                    Text(
                      '98.7% pontual',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < store.viagensSemana.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _Barra(
                      valor: store.viagensSemana[i],
                      max: max,
                      dia: AdminDataStore.diasSemana[i],
                      destaque: store.viagensSemana[i] == max,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.circle, size: 7, color: AppColors.primary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Pico de demanda: Qui (Campus Central)',
                  style: TextStyle(fontSize: 11, color: AppColors.textGray),
                ),
              ),
              Text(
                'Média: 83 viagens',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertas(AdminDataStore store) {
    final pendentes = store.alertas.where((a) => !a.resolvido).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              'Alertas do Sistema',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 8),
            if (pendentes.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pendentes.length} pendente(s)',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            const Spacer(),
            GestureDetector(
              key: const ValueKey('alertas-ver-todos'),
              onTap: () {
                if (pendentes.isEmpty) {
                  _snack('Todos os alertas já foram resolvidos.');
                } else {
                  _snack(
                    '${pendentes.length} alerta(s) aguardando ação do gestor.',
                  );
                }
              },
              child: const Text(
                'Ver Todos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (pendentes.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 30,
                  color: AppColors.green,
                ),
                SizedBox(height: 8),
                Text(
                  'Nenhum alerta pendente',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Todo o sistema está operando dentro dos parâmetros.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
              ],
            ),
          )
        else
          for (final alerta in pendentes) ...[
            _AlertaCard(
              alerta: alerta,
              onAction: () {
                store.resolverAlerta(alerta);
                _snack('${alerta.acao} executado — alerta resolvido.');
              },
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.valor,
    required this.badge,
    required this.badgeCor,
    required this.titulo,
    required this.subtitulo,
    required this.icone,
  });

  final String valor;
  final String badge;
  final Color badgeCor;
  final String titulo;
  final String subtitulo;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
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
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, size: 16, color: AppColors.primary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeCor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: badgeCor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({
    required this.valor,
    required this.max,
    required this.dia,
    required this.destaque,
  });

  final int valor;
  final int max;
  final String dia;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final altura = max == 0 ? 0.0 : (valor / max) * 88.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$valor',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: destaque ? AppColors.primary : AppColors.textGray,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: altura < 6 ? 6 : altura,
          decoration: BoxDecoration(
            color: destaque ? AppColors.primary : const Color(0xFFC7D9F2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          dia,
          style: const TextStyle(fontSize: 10, color: AppColors.textGray),
        ),
      ],
    );
  }
}

class _AlertaCard extends StatelessWidget {
  const _AlertaCard({required this.alerta, required this.onAction});

  final AlertaAdmin alerta;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: alerta.iconeCor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(alerta.icone, size: 17, color: alerta.iconeCor),
              ),
              const SizedBox(width: 10),
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
                              color: alerta.tituloCor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: alerta.tituloCor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            alerta.categoria,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: alerta.tituloCor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alerta.mensagem,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                alerta.hora,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.hintGray,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.bolt, size: 14),
                label: Text(
                  alerta.acao,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
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

class _AcaoCard extends StatelessWidget {
  const _AcaoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              child: Icon(icon, size: 19, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.softBlueBorder),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.hintGray,
            ),
          ],
        ),
      ),
    );
  }
}
