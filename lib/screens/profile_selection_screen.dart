import 'package:flutter/material.dart';

import '../theme.dart';
import 'registration/admin_registration_screen.dart';
import 'registration/aluno_registration_screen.dart';
import 'registration/motorista_registration_screen.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _Profile {
  const _Profile({
    required this.icon,
    required this.title,
    required this.badgeLabel,
    required this.badgeIcon,
    required this.badgeGreen,
    required this.description,
    required this.chip1,
    required this.chip1Icon,
    required this.chip2,
    required this.chip2Icon,
  });

  final IconData icon;
  final String title;
  final String badgeLabel;
  final IconData badgeIcon;
  final bool badgeGreen;
  final String description;
  final String chip1;
  final IconData chip1Icon;
  final String chip2;
  final IconData chip2Icon;
}

const _profiles = [
  _Profile(
    icon: Icons.school,
    title: 'Aluno Universitário',
    badgeLabel: 'Acesso Rápido com CPF/Matrícula',
    badgeIcon: Icons.bolt,
    badgeGreen: true,
    description: 'Acesso a reservas de vaga, consulta de rotas em tempo real, biometria facial e avisos institucionais do campus.',
    chip1: 'Biometria Instantânea',
    chip1Icon: Icons.fingerprint,
    chip2: 'Passe Digital',
    chip2Icon: Icons.confirmation_number_outlined,
  ),
  _Profile(
    icon: Icons.directions_bus,
    title: 'Motorista Operacional',
    badgeLabel: 'CNH Profissional',
    badgeIcon: Icons.badge_outlined,
    badgeGreen: false,
    description: 'Acesso ao painel da rota diária, contagem de passageiros, validação de embarque biométrico e status do veículo.',
    chip1: 'Checklist Diário',
    chip1Icon: Icons.checklist,
    chip2: 'GPS Ativo',
    chip2Icon: Icons.gps_fixed,
  ),
  _Profile(
    icon: Icons.account_balance,
    title: 'Gestão Pública / ADM',
    badgeLabel: 'Acesso Governamental',
    badgeIcon: Icons.lock_outline,
    badgeGreen: false,
    description: 'Painel de gestão da frota municipal, relatórios de lotação da prefeitura, controle de escalas e faturamento do convênio.',
    chip1: 'Métricas de Frota',
    chip1Icon: Icons.bar_chart,
    chip2: 'Auditoria',
    chip2Icon: Icons.fact_check,
  ),
];

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  int _selected = 0;

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
              _buildTopBar(),
              const SizedBox(height: 20),
              _buildStepPill(),
              const SizedBox(height: 22),
              _buildHeroIcon(),
              const SizedBox(height: 22),
              _buildTitle(),
              const SizedBox(height: 24),
              for (var i = 0; i < _profiles.length; i++) ...[
                _buildProfileCard(i),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 10),
              _buildContinueButton(),
              const SizedBox(height: 18),
              _buildLoginLink(),
              const SizedBox(height: 22),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Escolha De Perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            Text(
              'BusFlow',
              style: TextStyle(fontSize: 11, color: AppColors.textGray),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: const [
            _ProgressSegment(active: true),
            SizedBox(width: 3),
            _ProgressSegment(active: false),
            SizedBox(width: 3),
            _ProgressSegment(active: false),
          ],
        ),
        const SizedBox(width: 12),
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
    );
  }

  Widget _buildStepPill() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDBEAFE)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 8, color: AppColors.primary),
            SizedBox(width: 7),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                children: [
                  TextSpan(text: 'Passo 1 de 3'),
                  TextSpan(
                    text: '  —  Identificação',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroIcon() {
    return Center(
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 36,
              ),
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Icon(Icons.edit, size: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: const [
        Text(
          'Selecione o seu perfil',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Escolha como você utilizará o ecossistema BusFlow para personalizar sua experiência.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textGray,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(int index) {
    final p = _profiles[index];
    final selected = _selected == index;

    return GestureDetector(
      onTap: () => setState(() => _selected = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? Colors.white : AppColors.fieldBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selected)
                Container(
                  width: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFE2E8F0),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              p.icon,
                              size: 19,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textGray,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                p.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 8),
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: p.badgeGreen
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              p.badgeIcon,
                              size: 13,
                              color: p.badgeGreen
                                  ? AppColors.green
                                  : AppColors.textGray,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              p.badgeLabel,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: p.badgeGreen
                                    ? AppColors.green
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        p.description,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.textGray,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _Chip(icon: p.chip1Icon, label: p.chip1),
                          const SizedBox(width: 16),
                          _Chip(icon: p.chip2Icon, label: p.chip2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          final Widget next;
          switch (_selected) {
            case 1:
              next = const MotoristaRegistrationScreen();
              break;
            case 2:
              next = const AdminRegistrationScreen();
              break;
            default:
              next = const AlunoRegistrationScreen();
          }
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => next));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continuar Cadastro',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Já possui uma conta? ',
          style: TextStyle(fontSize: 13.5, color: AppColors.textGray),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Text(
            'Fazer Login',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 14, color: AppColors.textGray),
            SizedBox(width: 6),
            Text(
              'Ambiente Unificado • Mobilidade Universitária',
              style: TextStyle(fontSize: 11.5, color: AppColors.textGray),
            ),
            SizedBox(width: 4),
            Icon(Icons.info_outline, size: 14, color: AppColors.textGray),
          ],
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Proteção de dados sob conformidade com a LGPD e Diretrizes Municipais',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.hintGray),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textGray),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  const _ProgressSegment({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 5,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
