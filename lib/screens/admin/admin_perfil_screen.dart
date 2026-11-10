import 'package:flutter/material.dart';

import '../../services/account_profile.dart';
import '../../services/admin_data_store.dart';
import '../../services/admin_storage.dart';
import '../../services/supabase_auth_service.dart';
import '../../theme.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/profile_photo_picker.dart';
import '../dados_pessoais_screen.dart';
import '../login_screen.dart';

class AdminPerfilScreen extends StatefulWidget {
  const AdminPerfilScreen({super.key});

  @override
  State<AdminPerfilScreen> createState() => _AdminPerfilScreenState();
}

class _AdminPerfilScreenState extends State<AdminPerfilScreen> {
  bool _lotacao = true;
  bool _demandas = true;
  bool _atrasos = true;
  bool _aparencia = false;
  bool _saindo = false;
  String _profilePhoto = '';

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    final data = await AdminStorage.getAdmin();
    if (mounted) setState(() => _profilePhoto = data['profilePhoto'] ?? '');
  }

  Future<void> _editarDados() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            const DadosPessoaisScreen(profileKind: ProfileKind.admin),
      ),
    );
    await AdminDataStore.instance.load();
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
        title: const Text(
          'Encerrar Sessão Segura?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        content: const Text(
          'Você voltará para a tela de login do BusFlow. '
          'Os dados institucionais continuarão salvos neste dispositivo.',
          style: TextStyle(fontSize: 13, height: 1.45),
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
    if (confirmar != true || !mounted) return;
    setState(() => _saindo = true);
    await SupabaseAuthService.signOut();
    await AdminStorage.clear();
    AdminDataStore.instance.limparTudo();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
              const AdminTopBar(subtitle: 'Perfil'),
              const SizedBox(height: 18),
              _buildPerfilCard(store),
              const SizedBox(height: 14),
              _buildMetricas(store),
              const SizedBox(height: 14),
              _buildSecaoGovernanca(),
              const SizedBox(height: 14),
              _buildPreferencias(),
              const SizedBox(height: 14),
              _buildSuporte(),
              const SizedBox(height: 18),
              _buildBotaoSaida(),
              const SizedBox(height: 16),
              const Column(
                children: [
                  Text(
                    'BusFlow Enterprise v3.6.1 (Build 2026.2)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textGray,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'PRAE • Departamento de Mobilidade Universitária',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10.5, color: AppColors.hintGray),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerfilCard(AdminDataStore store) {
    final nome = store.nome.isNotEmpty ? store.nome : 'Administrador CCO';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _profilePhoto.isNotEmpty
                      ? ProfilePhotoAvatar(photo: _profilePhoto, size: 56)
                      : Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            store.iniciaisAvatar,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  Positioned(
                    right: 1,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.greenDot,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'ID: ADM-102 • ${store.cargoExibicao} • ${store.orgaoExibicao}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textGray,
                      ),
                    ),
                    if (store.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        store.email,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.hintGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: _editarDados,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.softBlueBorder),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.softBlueBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'SUPER ADMIN CCO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.badgeBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: AppColors.greenDot),
                    SizedBox(width: 5),
                    Text(
                      'Em Serviço Ativo',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricas(AdminDataStore store) {
    return Container(
      padding: const EdgeInsets.all(15),
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
                child: Text(
                  'ESCOPO & MÉTRICAS SUPERVISIONADAS',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.hintGray,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tabBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'Ciclo Mensal',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricaItem(
                  icone: Icons.directions_bus_outlined,
                  titulo: 'Frotas Supervisionadas',
                  valor: '${store.onibusTotal} ônibus',
                  sub: '8 rotas universitárias',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricaItem(
                  icone: Icons.school_outlined,
                  titulo: 'Alunos Cadastrados',
                  valor: '4.845',
                  sub: '✓ 98.2% validados',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricaItem(
                  icone: Icons.fact_check_outlined,
                  titulo: 'Auditorias no Mês',
                  valor: '142',
                  sub: 'Em conformidade plena',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricaItem(
                  icone: Icons.admin_panel_settings_outlined,
                  titulo: 'Permissões Sistemáticas',
                  valor: 'Tier 1 Master',
                  sub: 'Acesso irrestrito CCO',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoGovernanca() {
    const itens = [
      (
        Icons.lock_person_outlined,
        'Autenticação 2FA Univer...',
        'Sincronizado via DuoSafe',
        'Ativada',
        Color(0xFF16A34A),
      ),
      (
        Icons.draw_outlined,
        'Assinatura de Passe Digit...',
        'Certificado SHA-256 válido',
        'Até 12/2027',
        Color(0xFF17457F),
      ),
      (
        Icons.history_toggle_off,
        'Trilha de Auditoria & Logs de Ac...',
        'Último registro há 8 minutos',
        '',
        Color(0xFF64748B),
      ),
      (
        Icons.api_outlined,
        'Chaves de API & Telemetria GPS',
        '4 nós CCO conectados ao tempo real',
        '',
        Color(0xFF64748B),
      ),
    ];
    return _Secao(
      titulo: 'Governança & Segurança Institucional',
      icone: Icons.shield_outlined,
      child: Column(
        children: [
          for (var i = 0; i < itens.length; i++) ...[
            if (i > 0) const SizedBox(height: 9),
            _LinhaGovernanca(
              icone: itens[i].$1,
              titulo: itens[i].$2,
              sub: itens[i].$3,
              tag: itens[i].$4,
              tagCor: itens[i].$5,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencias() {
    return _Secao(
      titulo: 'Preferências Operacionais & Alertas',
      icone: Icons.tune,
      child: Column(
        children: [
          _PreferenciaRow(
            icone: Icons.directions_bus_filled,
            cor: const Color(0xFFDC2626),
            titulo: 'Lotação Crítica (>90%)',
            sub: 'Notificar reforço operacional',
            value: _lotacao,
            onChanged: (v) => setState(() => _lotacao = v),
          ),
          const SizedBox(height: 10),
          _PreferenciaRow(
            icone: Icons.groups_outlined,
            cor: const Color(0xFFF59E0B),
            titulo: 'Demandas & Passeis Estudantis',
            sub: 'Fila de espera ativada',
            value: _demandas,
            onChanged: (v) => setState(() => _demandas = v),
          ),
          const SizedBox(height: 10),
          _PreferenciaRow(
            icone: Icons.timer_off_outlined,
            cor: const Color(0xFFDC2626),
            titulo: 'Atrasos de Linha (>10 min)',
            sub: 'Push direto na central de despacho',
            value: _atrasos,
            onChanged: (v) => setState(() => _atrasos = v),
          ),
          const SizedBox(height: 10),
          _PreferenciaRow(
            icone: Icons.brightness_6_outlined,
            cor: AppColors.textGray,
            titulo: 'Aparência do Painel',
            sub: 'Tema claro do sistema ativo',
            value: _aparencia,
            onChanged: (v) => setState(() => _aparencia = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSuporte() {
    return _Secao(
      titulo: 'Suporte Institucional & Termos',
      icone: Icons.support_agent_outlined,
      child: Column(
        children: [
          _LinhaGovernanca(
            icone: Icons.phone_outlined,
            titulo: 'Canal Direto CCO & DTI Campus',
            sub: 'Ramal 3300, planos.mobilidade@depar...',
            tag: '',
            tagCor: AppColors.textGray,
            onTap: () => _snack('Abrindo canal direto com o DTI Campus.'),
          ),
          const SizedBox(height: 9),
          _LinhaGovernanca(
            icone: Icons.privacy_tip_outlined,
            titulo: 'Diretrizes LGPD & Termos Estud...',
            sub: 'Proteção de dados biométricos e mobi...',
            tag: '',
            tagCor: AppColors.textGray,
            onTap: () => _snack('Abrindo diretrizes LGPD e termos.'),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoSaida() {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        key: const ValueKey('encerrar-sessao'),
        onPressed: _saindo ? null : _encerrarSessao,
        icon: const Icon(Icons.logout, size: 18),
        label: const Text(
          'Encerrar Sessão Segura',
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE2E2),
          foregroundColor: const Color(0xFFDC2626),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: const BorderSide(color: Color(0xFFFECACA)),
          ),
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({
    required this.titulo,
    required this.icone,
    required this.child,
  });

  final String titulo;
  final IconData icone;
  final Widget child;

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
              Icon(icone, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _MetricaItem extends StatelessWidget {
  const _MetricaItem({
    required this.icone,
    required this.titulo,
    required this.valor,
    required this.sub,
  });

  final IconData icone;
  final String titulo;
  final String valor;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 17, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textGray),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.hintGray),
          ),
        ],
      ),
    );
  }
}

class _LinhaGovernanca extends StatelessWidget {
  const _LinhaGovernanca({
    required this.icone,
    required this.titulo,
    required this.sub,
    required this.tag,
    required this.tagCor,
    this.onTap,
  });

  final IconData icone;
  final String titulo;
  final String sub;
  final String tag;
  final Color tagCor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 15, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
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
            if (tag.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: tagCor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: tagCor,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.hintGray,
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  const _ToggleSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreferenciaRow extends StatelessWidget {
  const _PreferenciaRow({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.sub,
    required this.value,
    required this.onChanged,
  });

  final IconData icone;
  final Color cor;
  final String titulo;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 15, color: cor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  sub,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            height: 24,
            child: _ToggleSwitch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}
