import 'package:flutter/material.dart';

import '../services/admin_storage.dart';
import '../services/api_service.dart';
import '../services/motorista_storage.dart';
import '../services/student_storage.dart';
import '../theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/logo.dart';
import 'admin/admin_main_screen.dart';
import 'aluno/aluno_main_screen.dart';
import 'motorista/motorista_main_screen.dart';
import 'profile_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _loginTab = true;

  final _email = TextEditingController();
  final _senha = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _entrar() async {
    final identificador = _email.text.trim();
    final senha = _senha.text;
    if (identificador.isEmpty || senha.isEmpty) {
      _snack('Informe seu e-mail/CPF e senha para entrar.');
      return;
    }
    final idNormal = identificador.toLowerCase();
    final idDigitos = idNormal.replaceAll(RegExp(r'[^0-9]'), '');
    final isEmail = identificador.contains('@');
    final isCpf = !isEmail && idDigitos.isNotEmpty && idDigitos.length >= 11;

    // Tentar login via API primeiro
    final apiOnline = await ApiService.isApiOnline();
    if (apiOnline) {
      if (isEmail) {
        // Tentar admin
        final result = await ApiService.loginAdmin(email: idNormal, senha: senha);
        if (result['sucesso'] == true) {
          final dados = result['dados'] as Map<String, dynamic>;
          await AdminStorage.saveAdmin(
            nome: dados['nome'] ?? '',
            email: dados['email'] ?? '',
            cpf: dados['cpf'] ?? '',
            senha: senha,
            cargo: dados['cargo'] ?? '',
            orgao: dados['orgao'] ?? '',
            chave: dados['chave_adm'] ?? '',
          );
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AdminMainScreen()),
            (route) => false,
          );
          return;
        }
        // Tentar motorista
        final resultM = await ApiService.loginMotorista(email: idNormal, senha: senha);
        if (resultM['sucesso'] == true) {
          final dados = resultM['dados'] as Map<String, dynamic>;
          await MotoristaStorage.saveMotorista(
            nome: dados['nome'] ?? '',
            email: dados['email'] ?? '',
            cpf: dados['cpf'] ?? '',
            senha: senha,
            cnh: dados['cnh'] ?? '',
            empresa: dados['empresa'] ?? '',
            telefone: dados['telefone'] ?? '',
            categoria: dados['categoria_cnh'] ?? '',
            turno: dados['turno_operacao'] ?? '',
          );
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MotoristaMainScreen()),
            (route) => false,
          );
          return;
        }
        // Tentar aluno
        final resultA = await ApiService.loginAluno(email: idNormal, senha: senha);
        if (resultA['sucesso'] == true) {
          final dados = resultA['dados'] as Map<String, dynamic>;
          await StudentStorage.saveAluno(
            nome: dados['nome'] ?? '',
            email: dados['email'] ?? '',
            cpf: dados['cpf'] ?? '',
            senha: senha,
            ra: dados['ra'] ?? '',
            instituicao: dados['instituicao'] ?? '',
            whatsapp: dados['telefone'] ?? '',
            turno: dados['turno'] ?? '',
          );
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AlunoMainScreen()),
            (route) => false,
          );
          return;
        }
        if (!mounted) return;
        _snack('Conta não encontrada. Crie sua conta para continuar.');
        return;
      }
      if (isCpf) {
        // Tentar admin com CPF
        final result = await ApiService.loginAdmin(cpf: idDigitos, senha: senha);
        if (result['sucesso'] == true) {
          final dados = result['dados'] as Map<String, dynamic>;
          await AdminStorage.saveAdmin(
            nome: dados['nome'] ?? '',
            email: dados['email'] ?? '',
            cpf: dados['cpf'] ?? '',
            senha: senha,
            cargo: dados['cargo'] ?? '',
            orgao: dados['orgao'] ?? '',
            chave: dados['chave_adm'] ?? '',
          );
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AdminMainScreen()),
            (route) => false,
          );
          return;
        }
        // Tentar motorista com CPF
        final resultM = await ApiService.loginMotorista(cpf: idDigitos, senha: senha);
        if (resultM['sucesso'] == true) {
          final dados = resultM['dados'] as Map<String, dynamic>;
          await MotoristaStorage.saveMotorista(
            nome: dados['nome'] ?? '',
            email: dados['email'] ?? '',
            cpf: dados['cpf'] ?? '',
            senha: senha,
            cnh: dados['cnh'] ?? '',
            empresa: dados['empresa'] ?? '',
            telefone: dados['telefone'] ?? '',
            categoria: dados['categoria_cnh'] ?? '',
            turno: dados['turno_operacao'] ?? '',
          );
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MotoristaMainScreen()),
            (route) => false,
          );
          return;
        }
        // Tentar aluno com CPF
        final resultA = await ApiService.loginAluno(cpf: idDigitos, senha: senha);
        if (resultA['sucesso'] == true) {
          final dados = resultA['dados'] as Map<String, dynamic>;
          await StudentStorage.saveAluno(
            nome: dados['nome'] ?? '',
            email: dados['email'] ?? '',
            cpf: dados['cpf'] ?? '',
            senha: senha,
            ra: dados['ra'] ?? '',
            instituicao: dados['instituicao'] ?? '',
            whatsapp: dados['telefone'] ?? '',
            turno: dados['turno'] ?? '',
          );
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AlunoMainScreen()),
            (route) => false,
          );
          return;
        }
        if (!mounted) return;
        _snack('Conta não encontrada. Crie sua conta para continuar.');
        return;
      }
    }

    // Fallback: verificar SharedPreferences localmente
    bool corresponde(Map<String, String> dados) {
      final email = (dados['email'] ?? '').trim().toLowerCase();
      final cpf = (dados['cpf'] ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      if (email.isNotEmpty && email == idNormal) return true;
      if (cpf.isNotEmpty && idDigitos.isNotEmpty && cpf == idDigitos) {
        return true;
      }
      return false;
    }

    bool senhaOk(Map<String, String> dados) {
      final salva = dados['senha'] ?? '';
      return salva.isEmpty || salva == senha;
    }

    if (await AdminStorage.isRegistered()) {
      final dados = await AdminStorage.getAdmin();
      if (corresponde(dados)) {
        if (!mounted) return;
        if (!senhaOk(dados)) {
          _snack('Senha incorreta.');
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminMainScreen()),
          (route) => false,
        );
        return;
      }
    }
    if (await MotoristaStorage.isRegistered()) {
      final dados = await MotoristaStorage.getMotorista();
      if (corresponde(dados)) {
        if (!mounted) return;
        if (!senhaOk(dados)) {
          _snack('Senha incorreta.');
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MotoristaMainScreen()),
          (route) => false,
        );
        return;
      }
    }
    if (await StudentStorage.isRegistered()) {
      final dados = await StudentStorage.getAluno();
      if (corresponde(dados)) {
        if (!mounted) return;
        if (!senhaOk(dados)) {
          _snack('Senha incorreta.');
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AlunoMainScreen()),
          (route) => false,
        );
        return;
      }
    }
    if (!mounted) return;
    _snack('Conta não encontrada. Crie sua conta para continuar.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(),
            const SizedBox(height: 18),
            _buildBackRow(),
            const SizedBox(height: 22),
            Center(child: _buildLogoCard()),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 22),
            _buildTabs(),
            const SizedBox(height: 22),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 22),
            _buildPrimaryButton(),
            const SizedBox(height: 20),
            _buildDivider(),
            const SizedBox(height: 16),
            _buildGovButton(),
            const SizedBox(height: 16),
            _buildRegisterCard(),
            const SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
        ),
      ),
      bottomNavigationBar: const BusFlowBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        const BusFlowMark(size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'BusFlow',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            Text(
              'Início',
              style: TextStyle(fontSize: 11, color: AppColors.textGray),
            ),
          ],
        ),
        const Spacer(),
        const Icon(
          Icons.notifications_none,
          size: 26,
          color: AppColors.textDark,
        ),
        const SizedBox(width: 18),
        const BusFlowAvatar(radius: 16),
      ],
    );
  }

  Widget _buildBackRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Row(
            children: [
              Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: AppColors.primary,
              ),
              SizedBox(width: 4),
              Text(
                'Voltar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
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
                'PASSAPORTE ATIVO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const BusFlowAvatar(radius: 13),
      ],
    );
  }

  Widget _buildLogoCard() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(child: BusFlowLogo(markSize: 30, fontSize: 15)),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: const [
        Text(
          'Acesse o BusFlow.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Conecte-se para garantir sua viagem e acompanhar rotas universitárias.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tabBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Entrar na Conta',
              icon: Icons.swap_horiz,
              active: _loginTab,
              onTap: () => setState(() => _loginTab = true),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Criar Conta',
              icon: Icons.auto_awesome,
              active: false,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileSelectionScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clearButton(TextEditingController controller) {
    if (controller.text.isEmpty) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Limpar',
      icon: const Icon(Icons.cancel, size: 18, color: AppColors.hintGray),
      onPressed: () {
        controller.clear();
        setState(() {});
      },
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'E-mail ou CPF',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          enableSuggestions: false,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'seu@email.com ou 000.000.000-00',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.hintGray,
            ),
            prefixIcon: const Icon(
              Icons.mail_outline,
              size: 20,
              color: AppColors.hintGray,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 46),
            suffixIcon: _clearButton(_email),
            suffixIconConstraints: const BoxConstraints(minWidth: 46),
            filled: true,
            fillColor: AppColors.fieldBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Senha',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: () => _snack(
                'Link de recuperação enviado para o e-mail cadastrado.',
              ),
              child: const Text(
                'Esqueceu a senha?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _senha,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'Digite sua senha',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.hintGray),
            prefixIcon: const Icon(
              Icons.lock_outline,
              size: 20,
              color: AppColors.hintGray,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 46),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_senha.text.isNotEmpty) ...[
                  IconButton(
                    tooltip: 'Limpar',
                    icon: const Icon(
                      Icons.cancel,
                      size: 18,
                      color: AppColors.hintGray,
                    ),
                    onPressed: () {
                      _senha.clear();
                      setState(() {});
                    },
                  ),
                ],
                IconButton(
                  tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.hintGray,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ],
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 46),
            filled: true,
            fillColor: AppColors.fieldBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _entrar,
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
              'Entrar no Aplicativo',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OU CONECTE-SE COM',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.hintGray,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }

  Widget _buildGovButton() {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: () => _snack('Login com gov.br disponível em breve.'),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                children: [
                  TextSpan(
                    text: 'gov',
                    style: TextStyle(color: AppColors.govBlue),
                  ),
                  TextSpan(
                    text: '.br',
                    style: TextStyle(color: AppColors.govYellow),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Entrar com gov.br',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.registerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.registerBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.teal,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ainda não tem conta?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Cadastre-se em menos de 1 minuto.',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileSelectionScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cadastrar',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, size: 16, color: AppColors.green),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'Ambiente Seguro Criptografado • Programa Mobilidade Universitária',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textGray),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? AppColors.primary : AppColors.textGray,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? AppColors.primary : AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
