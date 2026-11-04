import 'package:flutter/material.dart';

import '../../services/admin_data_store.dart';
import '../../theme.dart';
import '../../widgets/admin_top_bar.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  String _busca = '';
  int _filtroCategoria = 0;
  int _filtroStatus = 0;

  static const _categorias = ['Todos', 'Alunos', 'Motoristas', 'Admins'];
  static const _status = ['Todos os status', 'Ativos', 'Bloqueados'];

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<UsuarioAdmin> _filtrados(AdminDataStore store) {
    return store.usuarios.where((u) {
      if (_busca.isNotEmpty &&
          !u.nome.toLowerCase().contains(_busca.toLowerCase()) &&
          !u.detalhe1.toLowerCase().contains(_busca.toLowerCase())) {
        return false;
      }
      if (_filtroCategoria == 1 && u.categoria != 'Aluno') return false;
      if (_filtroCategoria == 2 && u.categoria != 'Motorista') return false;
      if (_filtroCategoria == 3 && u.categoria != 'Admin') return false;
      if (_filtroStatus == 1 && u.bloqueado) return false;
      if (_filtroStatus == 2 && !u.bloqueado) return false;
      return true;
    }).toList();
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
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gerenciar Usuários',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Controle de acessos, validação de vínculos matrículas e permissões',
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
                    key: const ValueKey('novo-usuario'),
                    onPressed: () => _snack(
                      'Formulário de novo usuário aberto na central CCO.',
                    ),
                    icon: const Icon(Icons.person_add_alt_1, size: 15),
                    label: const Text(
                      'Novo',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMetricas(store),
              const SizedBox(height: 14),
              _buildBusca(),
              const SizedBox(height: 12),
              _buildChips(
                itens: _categorias,
                selecionado: _filtroCategoria,
                onTap: (i) => setState(() => _filtroCategoria = i),
              ),
              const SizedBox(height: 8),
              _buildChips(
                itens: _status,
                selecionado: _filtroStatus,
                onTap: (i) => setState(() => _filtroStatus = i),
              ),
              const SizedBox(height: 18),
              _buildSolicitacoes(store),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Diretório Institucional',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  Text(
                    '${_filtrados(store).length} resultado(s)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Mais recentes',
                style: TextStyle(fontSize: 11, color: AppColors.hintGray),
              ),
              const SizedBox(height: 12),
              if (_filtrados(store).isEmpty)
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
                        Icons.person_search_outlined,
                        size: 30,
                        color: AppColors.hintGray,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Nenhum usuário encontrado',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ajuste a busca ou os filtros de categoria/status.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (final u in _filtrados(store)) ...[
                  _UsuarioCard(
                    usuario: u,
                    onDetalhes: () => _snack(
                      'Abrindo cadastro completo de ${u.nome}.',
                    ),
                    onAcao: () {
                      setState(() => store.alternarBloqueio(u));
                      _snack(
                        u.bloqueado
                            ? '${u.nome} bloqueado — motivo registrado no CCO.'
                            : '${u.nome} desbloqueado — acesso restaurado.',
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 16),
              _buildGovernanca(store),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricas(AdminDataStore store) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          _MiniStat(
            valor: '4.862',
            rotulo: 'Usuários',
            titulo: 'TOTAL',
            cor: AppColors.primaryDark,
          ),
          _StatDiv(),
          _MiniStat(
            valor: '4.845',
            rotulo: 'Hoje',
            titulo: 'ATIVOS',
            cor: AppColors.green,
          ),
          _StatDiv(),
          _MiniStat(
            valor: '12',
            rotulo: 'Aprovações',
            titulo: 'PENDENTES',
            cor: Color(0xFFF59E0B),
          ),
          _StatDiv(),
          _MiniStat(
            valor: '5',
            rotulo: 'Relatórios',
            titulo: 'BLOQUEADOS',
            cor: Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }

  Widget _buildBusca() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 19, color: AppColors.hintGray),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: const ValueKey('busca-usuarios'),
              onChanged: (v) => setState(() => _busca = v),
              style: const TextStyle(fontSize: 13.5, color: AppColors.textDark),
              decoration: const InputDecoration(
                hintText: 'Buscar por nome, RA ou identificação funcional...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.hintGray),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_busca.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _busca = ''),
              child: const Icon(
                Icons.cancel,
                size: 17,
                color: AppColors.hintGray,
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildChips({
    required List<String> itens,
    required int selecionado,
    required ValueChanged<int> onTap,
  }) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itens.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (ctx, i) {
          final ativo = selecionado == i;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: ativo ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: ativo ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                itens[i],
                style: TextStyle(
                  fontSize: 11.5,
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

  Widget _buildSolicitacoes(AdminDataStore store) {
    final lista = store.solicitacoes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              'Solicitações Pendentes',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${lista.length}',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'AÇÃO RÁPIDA',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'revisão',
          style: TextStyle(fontSize: 11, color: AppColors.hintGray),
        ),
        const SizedBox(height: 12),
        if (lista.isEmpty)
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
                  size: 28,
                  color: AppColors.green,
                ),
                SizedBox(height: 8),
                Text(
                  'Nenhuma solicitação pendente',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Todas as matrículas foram revisadas.',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
              ],
            ),
          )
        else
          for (final s in lista) ...[
            Container(
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
                      _Avatar(iniciais: s.iniciais, cor: s.cor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.nome,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.detalhe,
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.4,
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        s.hora,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.hintGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => store.recusarSolicitacao(s));
                            _snack('Solicitação de ${s.nome} recusada.');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textGray,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Visualizar / Recusar',
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
                          onPressed: () {
                            setState(() => store.aprovarSolicitacao(s));
                            _snack('Acesso de ${s.nome} aprovado.');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Aprovar Acesso',
                            style: TextStyle(
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
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _buildGovernanca(AdminDataStore store) {
    final selecionado = store.usuarios
        .where((u) => u.bloqueado)
        .toList();
    final alvo = selecionado.isNotEmpty
        ? selecionado.first
        : store.usuarios.first;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBlueBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gavel_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Módulo de Governança & Segurança',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Confirmação administrativa prévia antes de alterar status',
            style: TextStyle(fontSize: 11.5, color: AppColors.textGray),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.softBlueBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'USUÁRIO SELECIONADO',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.hintGray,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${alvo.nome} (${alvo.detalhe1.split('•').first.trim()})',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'MOTIVO INSTITUCIONAL REGISTRADO',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.hintGray,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  alvo.bloqueado && alvo.motivoBloqueio.isNotEmpty
                      ? alvo.motivoBloqueio
                      : 'Suspensão acadêmica / Trancamento de Matrícula',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _snack('Rejeição registrada na trilha CCO.'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textGray,
                    side: const BorderSide(color: AppColors.border),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Rejeitar',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => store.alternarBloqueio(alvo));
                    _snack('Governança registrada para ${alvo.nome}.');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Registrar Governança',
                    style: TextStyle(
                      fontSize: 12.5,
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.valor,
    required this.rotulo,
    required this.titulo,
    required this.cor,
  });

  final String valor;
  final String rotulo;
  final String titulo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: AppColors.hintGray,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: cor,
              ),
            ),
          ),
          Text(
            rotulo,
            style: const TextStyle(fontSize: 9.5, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}

class _StatDiv extends StatelessWidget {
  const _StatDiv();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.border,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.iniciais, required this.cor});

  final String iniciais;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        iniciais,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: cor,
        ),
      ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  const _UsuarioCard({
    required this.usuario,
    required this.onDetalhes,
    required this.onAcao,
  });

  final UsuarioAdmin usuario;
  final VoidCallback onDetalhes;
  final VoidCallback onAcao;

  @override
  Widget build(BuildContext context) {
    final corStatus = usuario.bloqueado
        ? const Color(0xFFDC2626)
        : AppColors.green;
    final textoStatus = usuario.emRota
        ? 'Em Rota'
        : (usuario.bloqueado ? 'Bloqueado' : 'Ativo');
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: usuario.bloqueado
              ? const Color(0xFFFECACA)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(iniciais: usuario.iniciais, cor: usuario.cor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            usuario.nome,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        if (usuario.categoria == 'Admin') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ADMIN CCO',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      usuario.detalhe1,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: corStatus.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: corStatus),
                    const SizedBox(width: 4),
                    Text(
                      textoStatus,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: corStatus,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            usuario.detalhe2,
            style: const TextStyle(
              fontSize: 11,
              height: 1.4,
              color: AppColors.textGray,
            ),
          ),
          if (usuario.bloqueado && usuario.motivoBloqueio.isNotEmpty) ...[
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                usuario.motivoBloqueio,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetalhes,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Ver Detalhes',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetalhes,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text(
                    usuario.categoria == 'Motorista'
                        ? 'Escalas'
                        : 'Permissões',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAcao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: usuario.bloqueado
                        ? AppColors.green
                        : const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text(
                    usuario.bloqueado ? 'Desbloquear' : 'Bloquear',
                    style: const TextStyle(
                      fontSize: 11,
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
