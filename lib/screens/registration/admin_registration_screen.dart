import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/registration_widgets.dart';

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  State<AdminRegistrationScreen> createState() =>
      _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  bool _sigilo = false;
  bool _lgpd = false;

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
              const RegistrationTopBar(title: 'Cadastro De Administrador'),
              const SizedBox(height: 18),
              const TopBadge(
                label: 'ACESSO RESTRITO MUNICIPAL • CHEFE DE SETOR/SECRETARIA',
                icon: Icons.domain,
              ),
              const SizedBox(height: 16),
              const Text(
                'Cadastro Institucional ADM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crie sua conta administrativa para monitorar a frota, rotas e comunicações universitárias municipais em tempo real.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 18),
              const InfoCard(
                icon: Icons.verified_user_outlined,
                title: 'Autenticação Controlada',
                body: 'Este módulo exige credenciamento formal prévio junto à Secretaria de Trânsito & Mobilidade Urbana.',
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                icon: Icons.person_outline,
                title: 'Dados do Gestor',
              ),
              const SizedBox(height: 16),
              const LabeledField(
                label: 'Nome Completo do Gestor',
                child: BusFlowTextField(
                  hint: 'Ex: Carlos Eduardo de Almeida',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'E-mail Institucional Oficial',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'gov ou convênio',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                child: const BusFlowTextField(
                  hint: 'gestor@prefeitura.sp.gov.br',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 14),
              const LabeledField(
                label: 'CPF',
                child: BusFlowTextField(
                  hint: '000.000.000-00',
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 26),
              const SectionHeader(
                icon: Icons.apartment,
                title: 'Vínculo Municipal e Autorização',
              ),
              const SizedBox(height: 16),
              const LabeledField(
                label: 'Órgão / Município Vinculado',
                child: BusFlowTextField(
                  hint: 'Ex: Prefeitura Municipal de Campinas • SP',
                  icon: Icons.location_city_outlined,
                  suffix: Icon(
                    Icons.keyboard_arrow_down,
                    size: 22,
                    color: AppColors.textGray,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const LabeledField(
                label: 'Cargo / Função Institucional',
                child: BusFlowTextField(
                  hint: 'Ex: Coordenador de Mobilidade Estudantil',
                  icon: Icons.work_outline,
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Chave de Acesso ADM Municipal',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: const Text(
                    'CÓDIGO ÚNICO',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                child: const BusFlowTextField(
                  hint: 'ADM-XXXX-XXXX-XXX',
                  icon: Icons.vpn_key_outlined,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chave criptográfica fornecida na oficina de homologação da prefeitura.',
                style: TextStyle(fontSize: 11.5, color: AppColors.hintGray),
              ),
              const SizedBox(height: 26),
              const SectionHeader(
                icon: Icons.lock_outline,
                title: 'Credenciais de Autenticação Segura',
              ),
              const SizedBox(height: 16),
              const LabeledField(
                label: 'Senha de Acesso Mestra',
                child: PasswordField(hint: '••••••'),
              ),
              const SizedBox(height: 14),
              const LabeledField(
                label: 'Confirmar Senha',
                child: PasswordField(hint: 'Repita a senha'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Critérios de Rigor e Compliança',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Text(
                    'Aprovação obrigatória',
                    style: TextStyle(fontSize: 11, color: AppColors.hintGray),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MiniCheck(
                      value: _sigilo,
                      label: 'Assinatura Termo',
                      onChanged: (v) => setState(() => _sigilo = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniCheck(
                      value: _lgpd,
                      label: 'LGPD Municipal',
                      onChanged: (v) => setState(() => _lgpd = v ?? false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const SectionHeader(
                icon: Icons.description_outlined,
                title: 'Compromisso e Termo de Sigilo LGPD',
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Termo de Confidencialidade e Responsabilidade Administrativa (Lei Federal 13.709/2018)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '1. O gestor declara ciência de que o sistema é restrito aos servidores autorizados e que os dados universitários institucionais e mobilidade são de acesso restrito.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textGray,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. Eu concordo e assumo responsabilidade pelo uso do Sistema de Sigilo e LGPD no meu cargo de diretor.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const PrimarySubmitButton(
                label: 'Cadastrar Administrador',
                icon: Icons.admin_panel_settings,
              ),
              const SizedBox(height: 18),
              Column(
                children: [
                  const Text(
                    'Não possui acesso ADM do município?',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Solicitar ao Controle de Tecnologia ↗',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCheck extends StatelessWidget {
  const _MiniCheck({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: value
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
