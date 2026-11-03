import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/registration_widgets.dart';

class MotoristaRegistrationScreen extends StatefulWidget {
  const MotoristaRegistrationScreen({super.key});

  @override
  State<MotoristaRegistrationScreen> createState() =>
      _MotoristaRegistrationScreenState();
}

class _MotoristaRegistrationScreenState
    extends State<MotoristaRegistrationScreen> {
  final Set<int> _turnos = {1};

  static const _turnoData = [
    (Icons.wb_sunny, 'Manhã', '06h - 12h'),
    (Icons.wb_sunny, 'Tarde', '12h - 18h'),
    (Icons.nightlight_round, 'Noite', '18h - 23h50'),
  ];

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
              const RegistrationTopBar(title: 'Cadastro De Motorista'),
              const SizedBox(height: 18),
              const TopBadge(
                label: 'CADASTRO OPERACIONAL',
                icon: Icons.verified_outlined,
              ),
              const SizedBox(height: 12),
              const Text(
                'Cadastre suas informações profissionais para operar as rotas universitárias.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 22),
              _buildPhotoSection(),
              const SizedBox(height: 24),
              const LabeledField(
                label: 'Nome Completo',
                child: BusFlowTextField(
                  hint: 'Ex: Marcos Silva Pereira',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 14),
              const LabeledField(
                label: 'E-mail Profissional ou Pessoal',
                child: BusFlowTextField(
                  hint: 'motorista@consorcio.com.br',
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
              const SizedBox(height: 14),
              const LabeledField(
                label: 'Telefone para Contato',
                child: BusFlowTextField(
                  hint: '(00) 00000-0000',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Registro da CNH',
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
                    'CATEGORIA D/E',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                child: const BusFlowTextField(
                  hint: 'Número do registro (11 dígitos)',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Exige qualificação profissional para transporte coletivo de passageiros.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const LabeledField(
                label: 'Senha de Acesso',
                child: PasswordField(hint: 'Mínimo 6 dígitos'),
              ),
              const SizedBox(height: 14),
              const LabeledField(
                label: 'Confirmar Senha',
                child: PasswordField(hint: 'Repita a senha'),
              ),
              const SizedBox(height: 24),
              LabeledField(
                label: 'Turno de Operação Principal',
                trailing: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'SELECIONE 1 OU MAIS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _turnoData.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      TurnTile(
                        icon: _turnoData[i].$1,
                        title: _turnoData[i].$2,
                        time: _turnoData[i].$3,
                        selected: _turnos.contains(i),
                        onTap: () => setState(() {
                          _turnos.contains(i)
                              ? _turnos.remove(i)
                              : _turnos.add(i);
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const LabeledField(
                label: 'Empresa, Consórcio ou Vínculo do Transporte',
                child: BusFlowTextField(
                  hint: 'Selecione seu consórcio ou modalidade',
                  icon: Icons.directions_bus_outlined,
                  suffix: Icon(
                    Icons.keyboard_arrow_down,
                    size: 22,
                    color: AppColors.textGray,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const InfoCard(
                icon: Icons.shield_outlined,
                title: 'Validação de Segurança e Trafegabilidade',
                body: 'O cadastro passará por validação cadastral da fiscalização de trânsito em até 24 horas. Você receberá notificação por e-mail e SMS assim que aprovado.',
              ),
              const SizedBox(height: 24),
              const PrimarySubmitButton(
                label: 'Cadastrar Motorista',
                icon: Icons.directions_bus,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.person,
                  size: 44,
                  color: AppColors.textGray,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 4,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text(
                'Foto de Perfil do Motorista',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Para identificação dos estudantes no momento do embarque.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.check_circle, size: 15, color: AppColors.green),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Rosto nítido e bem iluminado',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
