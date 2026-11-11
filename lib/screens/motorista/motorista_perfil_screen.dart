import 'package:flutter/material.dart';

import '../../services/account_profile.dart';
import '../../services/app_settings.dart';
import '../../services/motorista_data_store.dart';
import '../../services/motorista_storage.dart';
import '../../services/supabase_auth_service.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';
import '../../widgets/profile_photo_picker.dart';
import '../dados_pessoais_screen.dart';
import '../login_screen.dart';
import '../security_settings_screen.dart';

class MotoristaPerfilScreen extends StatefulWidget {
  const MotoristaPerfilScreen({super.key});

  @override
  State<MotoristaPerfilScreen> createState() => _MotoristaPerfilScreenState();
}

class _MotoristaPerfilScreenState extends State<MotoristaPerfilScreen> {
  bool _alertasTrafego = true;
  String _profilePhoto = '';

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    final data = await MotoristaStorage.getMotorista();
    if (mounted) setState(() => _profilePhoto = data['profilePhoto'] ?? '');
  }

  Future<void> _editarDados() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            const DadosPessoaisScreen(profileKind: ProfileKind.motorista),
      ),
    );
    await MotoristaDataStore.instance.load();
    await _loadProfilePhoto();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _encerrarSessao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar sessão?'),
        content: const Text(
          'Você precisará entrar novamente para acessar o painel.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Encerrar',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await SupabaseAuthService.signOut();
    await MotoristaStorage.clear();
    MotoristaDataStore.instance.limparTudo();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = MotoristaDataStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(store),
              const SizedBox(height: 18),
              _buildPerfilCard(store),
              const SizedBox(height: 14),
              _buildCredenciais(store),
              const SizedBox(height: 14),
              _buildDesempenho(store),
              const SizedBox(height: 14),
              _buildVeiculo(store),
              const SizedBox(height: 14),
              _buildEscala(store),
              const SizedBox(height: 14),
              _buildConfiguracoes(),
              const SizedBox(height: 14),
              _buildRodape(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(MotoristaDataStore store) {
    final unread = store.alertasNaoLidos;
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
                'ACADÊMICO • MOTORISTA',
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
        const SizedBox(width: 16),
        const Icon(
          Icons.settings_outlined,
          size: 22,
          color: AppColors.textDark,
        ),
      ],
    );
  }

  Widget _buildPerfilCard(MotoristaDataStore store) {
    final nome = store.nomeCompleto;
    final cat = store.categoriaExibicao;
    final empresa = store.empresa.isNotEmpty ? store.empresa : 'Sem empresa';
    final turno = store.turno.isNotEmpty ? store.turno : 'Turno não definido';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _editarDados,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ProfilePhotoAvatar(photo: _profilePhoto, size: 84),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'CNH Categoria $cat',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textGray),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            alignment: WrapAlignment.center,
            children: [
              _MiniBadge(icon: Icons.badge_outlined, label: empresa),
              _MiniBadge(icon: Icons.schedule, label: turno),
              if (store.cnh.isNotEmpty)
                _MiniBadge(icon: Icons.verified, label: 'CNH ${store.cnh}'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => _mostrarCnh(store),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.badge, size: 18),
              label: const Text(
                'Carteira Digital',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredenciais(MotoristaDataStore store) {
    final temCnh = store.cnh.isNotEmpty;
    return _SectionCard(
      title: 'Credenciais & Documentos',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.badgeBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.badgeBorder),
        ),
        child: Text(
          temCnh ? 'CNH Cadastrada' : 'Pendente',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: temCnh ? AppColors.green : const Color(0xFFF59E0B),
          ),
        ),
      ),
      children: [
        _CredencialRow(
          icon: Icons.badge_outlined,
          title: 'CNH Categoria ${store.categoriaExibicao}',
          subtitle: temCnh
              ? 'Registro ${store.cnh} • CNH Digital'
              : 'Nenhuma CNH cadastrada',
          status: temCnh ? 'Verificado' : 'Pendente',
          statusColor: temCnh ? AppColors.green : const Color(0xFFF59E0B),
        ),
        const _CredencialRow(
          icon: Icons.health_and_safety_outlined,
          title: 'Exame Toxicológico Periódico',
          subtitle: 'Não informado no cadastro',
          status: 'Pendente',
          statusColor: Color(0xFFF59E0B),
        ),
        const _CredencialRow(
          icon: Icons.local_shipping_outlined,
          title: 'Transporte Coletivo de Passageiros',
          subtitle: 'Não informado no cadastro',
          status: 'Pendente',
          statusColor: Color(0xFFF59E0B),
        ),
        const _CredencialRow(
          icon: Icons.shield_outlined,
          title: 'Direção Defensiva Universitária',
          subtitle: 'Não informado no cadastro',
          status: 'Pendente',
          statusColor: Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildDesempenho(MotoristaDataStore store) {
    final viagens = store.viagensConcluidas;
    final ocupacao = store.lotacao;
    return _SectionCard(
      title: 'Desempenho Acadêmico',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.softBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Sessão atual',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricBox(
                valor: '$viagens',
                label: 'Viagens Concluídas',
                nota: viagens > 0 ? 'Nesta sessão' : 'Ainda sem viagens',
                cor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricBox(
                valor: '${store.rotasHoje}',
                label: 'Rotas Atribuídas',
                nota: store.rotasHoje > 0 ? 'Escalas ativas' : 'Sem escala',
                cor: AppColors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricBox(
                valor: '$ocupacao',
                label: 'Embarques Hoje',
                nota: 'Capacidade ${MotoristaDataStore.capacidadeTotal}',
                cor: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricBox(
                valor: '${store.alertasNaoLidos}',
                label: 'Alertas Abertos',
                nota: store.alertasNaoLidos > 0
                    ? 'Requer atenção'
                    : 'Tudo em dia',
                cor: const Color(0xFF4F46E5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVeiculo(MotoristaDataStore store) {
    final rotas = store.rotas;
    return _SectionCard(
      title: 'Veículo & Linhas Atribuídas',
      trailing: Text(
        rotas.isNotEmpty ? 'Frota Ativa' : 'Sem frota',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: rotas.isNotEmpty ? AppColors.green : AppColors.textGray,
        ),
      ),
      children: [
        if (rotas.isEmpty)
          const Column(
            children: [
              Icon(
                Icons.directions_bus_outlined,
                size: 32,
                color: AppColors.hintGray,
              ),
              SizedBox(height: 8),
              Text(
                'Nenhum veículo ou linha atribuído.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGray,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Atribuições da central aparecem em Viagens.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.hintGray),
              ),
            ],
          )
        else ...[
          for (var i = 0; i < rotas.length; i++) ...[
            if (i > 0) const SizedBox(height: 7),
            _RotaTag(
              linha: rotas[i].linha,
              descricao: '${rotas[i].origem} • ${rotas[i].destino}',
              turno: rotas[i].status,
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _mostrarCnh(MotoristaDataStore store) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CNH Digital'),
        content: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.badge_outlined, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                store.nomeCompleto,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Registro CNH: ${store.cnh.isEmpty ? 'Não informado' : store.cnh}',
              ),
              Text('Categoria: ${store.categoriaExibicao}'),
              const SizedBox(height: 8),
              const Text(
                'Validade não cadastrada',
                style: TextStyle(color: AppColors.textGray, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarEscala(MotoristaDataStore store) async {
    var selectedDay = DateUtils.dateOnly(DateTime.now());
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Folha de Escala'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CalendarDatePicker(
                  initialDate: selectedDay,
                  firstDate: DateTime(DateTime.now().year - 1),
                  lastDate: DateTime(DateTime.now().year + 2),
                  onDateChanged: (day) => setDialogState(
                    () => selectedDay = DateUtils.dateOnly(day),
                  ),
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${selectedDay.day.toString().padLeft(2, '0')}/'
                    '${selectedDay.month.toString().padLeft(2, '0')}/'
                    '${selectedDay.year} • ${store.turno.isEmpty ? 'Turno não definido' : store.turno}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                if (store.rotas.isEmpty)
                  const Text(
                    'Nenhuma rota atribuída para este motorista.',
                    style: TextStyle(color: AppColors.textGray),
                  )
                else
                  for (final route in store.rotas)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.directions_bus_outlined),
                      title: Text('${route.linha} • ${route.onibus}'),
                      subtitle: Text('${route.origem} → ${route.destino}'),
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _trocarTurno(MotoristaDataStore store) async {
    const shifts = ['Manhã', 'Tarde', 'Noite'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Solicitar troca de turno',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            for (final shift in shifts)
              ListTile(
                leading: Icon(
                  store.turno == shift
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                ),
                title: Text(shift),
                onTap: () => Navigator.pop(context, shift),
              ),
          ],
        ),
      ),
    );
    if (selected == null || selected == store.turno) return;
    await SupabaseAuthService.updateCurrentProfileData({'turno': selected});
    final profile = await MotoristaStorage.getMotorista();
    await MotoristaStorage.updateProfile(
      fields: {'turno': selected},
      profilePhoto: profile['profilePhoto'] ?? '',
    );
    await MotoristaDataStore.instance.load();
    if (mounted) _snack('Turno atualizado para $selected.');
  }

  Widget _buildEscala(MotoristaDataStore store) {
    final turno = store.turno.isNotEmpty ? store.turno : 'Não definido';
    return _SectionCard(
      title: 'Escala & Jornada',
      trailing: Text(
        store.rotas.isNotEmpty ? 'Com escala' : 'Sem escala',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: store.rotas.isNotEmpty ? AppColors.green : AppColors.textGray,
        ),
      ),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Turno Alocado',
                    style: TextStyle(fontSize: 11, color: AppColors.textGray),
                  ),
                  SizedBox(height: 3),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.softBlueBorder),
              ),
              child: Text(
                turno,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: OutlinedButton.icon(
                  onPressed: () => _mostrarEscala(store),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month, size: 15),
                  label: const Text(
                    'Folha de Escala',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: SizedBox(
                height: 38,
                child: OutlinedButton.icon(
                  onPressed: () => _trocarTurno(store),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.swap_horiz, size: 15),
                  label: const Text(
                    'Trocar Turno',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfiguracoes() {
    return _SectionCard(
      title: 'Configurações & Suporte',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.security_outlined,
            color: AppColors.primary,
          ),
          title: const Text(
            'Segurança, senha e sessões',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const SecuritySettingsScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SwitchRow(
          icon: Icons.notifications_active_outlined,
          title: 'Alertas de Tráfego & Rota',
          subtitle: 'Ativos via notificação e CCB',
          value: _alertasTrafego,
          onChanged: (v) {
            setState(() => _alertasTrafego = v);
            _snack(
              v
                  ? 'Alertas de tráfego ativados.'
                  : 'Alertas de tráfego desativados.',
            );
          },
        ),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: AppSettings.instance,
          builder: (context, _) => _SwitchRow(
            icon: Icons.dark_mode_outlined,
            title: 'Tema escuro',
            subtitle: 'Aplicado em todas as telas',
            value: AppSettings.instance.darkMode,
            onChanged: AppSettings.instance.setDarkMode,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _snack('Ligando para a Central de Tráfego (CCB)...'),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.softBlueBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent, size: 19, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Central de Tráfego (CCB)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Canal de Emergência e Rádio Direto',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.phone, size: 19, color: AppColors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRodape() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _snack('Termo de Responsabilidade e LGPD aberto.'),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Termo de Responsabilidade e LGPD',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            key: const ValueKey('encerrar-sessao-motorista'),
            onPressed: _encerrarSessao,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE2E2),
              foregroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout, size: 17),
            label: const Text(
              'Encerrar Sessão do Motorista',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'BusFlow Mobile Estação • v2.4.1\n'
          'Terminal Sul 2024 • CBO • Conexão & Mobilidade Acadêmica',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            height: 1.5,
            color: AppColors.hintGray,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 13),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 11),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softBlueBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CredencialRow extends StatelessWidget {
  const _CredencialRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status == 'Pendente' ? Icons.warning_amber : Icons.check,
                size: 11,
                color: statusColor,
              ),
              const SizedBox(width: 3),
              Text(
                status,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.valor,
    required this.label,
    required this.nota,
    required this.cor,
  });

  final String valor;
  final String label;
  final String nota;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: cor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            nota,
            style: const TextStyle(fontSize: 9.5, color: AppColors.hintGray),
          ),
        ],
      ),
    );
  }
}

class _RotaTag extends StatelessWidget {
  const _RotaTag({
    required this.linha,
    required this.descricao,
    required this.turno,
  });

  final String linha;
  final String descricao;
  final String turno;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              linha,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              descricao,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            turno,
            style: const TextStyle(fontSize: 10, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }
}
