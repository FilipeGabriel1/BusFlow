import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../services/motorista_data_store.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';

class MotoristaValidarScreen extends StatefulWidget {
  const MotoristaValidarScreen({super.key, this.active = false});

  final bool active;

  @override
  State<MotoristaValidarScreen> createState() => _MotoristaValidarScreenState();
}

class _MotoristaValidarScreenState extends State<MotoristaValidarScreen> {
  bool _embarqueAtivo = true;
  bool _scannerLendo = false;
  String? _studentQrId;
  String? _lastRejectedValue;

  void _snack(String message, {Color? cor}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: cor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _aprovarValidacao() {
    final store = MotoristaDataStore.instance;
    if (!_embarqueAtivo) {
      _snack(
        'Embarque pausado. Reative para validar.',
        cor: const Color(0xFFF59E0B),
      );
      return;
    }
    if (store.lotacao >= MotoristaDataStore.capacidadeTotal) {
      _snack(
        'Ônibus lotado. Não é possível validar novos embarques.',
        cor: const Color(0xFFDC2626),
      );
      return;
    }
    final qrId = _studentQrId;
    if (qrId == null) {
      _snack(
        'Leia o QR Code da carteirinha antes de aprovar.',
        cor: const Color(0xFFF59E0B),
      );
      return;
    }
    setState(() => _scannerLendo = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final ok = store.validarEmbarque(
        iniciais: 'AL',
        nomePassageiro: 'Aluno ${qrId.substring(0, 8)}',
        ra: 'Passe ${qrId.substring(0, 8)}',
        curso: 'Carteirinha BusFlow',
        portao: 'Embarque QR',
        cor: const Color(0xFFDBEAFE),
        corTexto: const Color(0xFF17457F),
      );
      setState(() {
        _scannerLendo = false;
        if (ok) _studentQrId = null;
      });
      if (ok) {
        _snack('QR Code BusFlow validado ✓', cor: AppColors.green);
      } else {
        _snack(
          'Ônibus lotado. Validação recusada.',
          cor: const Color(0xFFDC2626),
        );
      }
    });
  }

  void _simularRecusa() {
    if (_studentQrId == null) {
      _snack(
        'Leia um QR Code antes de recusar a validação.',
        cor: const Color(0xFFF59E0B),
      );
      return;
    }
    setState(() => _scannerLendo = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      MotoristaDataStore.instance.recusarEmbarque();
      setState(() {
        _scannerLendo = false;
        _studentQrId = null;
      });
      _snack(
        'Passe recusado: carteirinha inválida ou vencida.',
        cor: const Color(0xFFDC2626),
      );
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (_studentQrId != null || _scannerLendo) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      final match = value == null
          ? null
          : RegExp(
              r'^BUSFLOW:STUDENT:([a-f0-9-]{36})$',
              caseSensitive: false,
            ).firstMatch(value);
      if (match != null) {
        setState(() => _studentQrId = match.group(1));
        _snack(
          'QR Code BusFlow lido. Revise e aprove o embarque.',
          cor: AppColors.green,
        );
        return;
      }
      if (value != null && value != _lastRejectedValue) {
        _lastRejectedValue = value;
        _snack(
          'QR Code incompatível com a carteirinha BusFlow.',
          cor: const Color(0xFFDC2626),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = MotoristaDataStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildViagemCard(store),
              const SizedBox(height: 14),
              _buildCapacidade(store),
              const SizedBox(height: 14),
              _buildLeitor(),
              const SizedBox(height: 14),
              _buildEmbarques(store),
              const SizedBox(height: 14),
              _buildRodape(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.directions_bus,
            size: 19,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Minha Viagem',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                'ACADÊMICO • VALIDAÇÃO',
                style: TextStyle(fontSize: 10, color: AppColors.textGray),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.softBlueBorder),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner, size: 12, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Validação',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const BusFlowAvatar(radius: 14),
      ],
    );
  }

  Widget _buildViagemCard(MotoristaDataStore store) {
    final rota = store.viagemAtual;
    if (rota == null) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.route_outlined, size: 30, color: AppColors.hintGray),
            SizedBox(height: 8),
            Text(
              'Nenhuma viagem ativa',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Inicie uma viagem em Início ou Viagens para ver o itinerário.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textGray),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(15),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  rota.linha.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rota.onibus,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.badgeBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 7,
                      color: store.viagemIniciada
                          ? AppColors.greenDot
                          : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      store.viagemIniciada ? 'Em Trânsito' : 'Aguardando',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: store.viagemIniciada
                            ? AppColors.green
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${rota.origem} → ${rota.destino}',
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Partida: ${rota.saida} • Previsto: ${rota.chegada}',
            style: const TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.softBlueBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'ITINERÁRIO',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  rota.origemNota,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rota.destino} • ${rota.destinoNota} ${rota.chegada}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacidade(MotoristaDataStore store) {
    final total = MotoristaDataStore.capacidadeTotal;
    final ocupados = store.lotacao;
    final percentual = store.lotacaoFraction;
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
              const Icon(
                Icons.airline_seat_recline_extra,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Capacidade & Lotação',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _embarqueAtivo = !_embarqueAtivo),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _embarqueAtivo
                        ? const Color(0xFFDCFCE7)
                        : AppColors.tabBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _embarqueAtivo
                        ? 'Embarque em Andamento'
                        : 'Embarque Pausado',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: _embarqueAtivo
                          ? AppColors.green
                          : AppColors.textGray,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$ocupados',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    TextSpan(
                      text: ' / $total lugares',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${(percentual * 100).round()}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: percentual,
              minHeight: 9,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentual >= 0.9 ? const Color(0xFFF59E0B) : AppColors.green,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '0',
                style: TextStyle(fontSize: 10.5, color: AppColors.hintGray),
              ),
              Text(
                store.faixaLotacao,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textGray,
                ),
              ),
              Text(
                '$total Máx',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.hintGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '${store.assentosLivres} assentos livres',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeitor() {
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
              const Icon(
                Icons.qr_code_scanner,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Leitor Digital de Bordo',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.face_retouching_natural,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: widget.active
                        ? MobileScanner(onDetect: _onDetect)
                        : const ColoredBox(
                            color: Color(0xFF0F172A),
                            child: Center(
                              child: Text(
                                'Abra a aba Validar para ativar a câmera',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _scannerLendo ? 0.4 : 1,
                        child: Icon(
                          Icons.qr_code_2,
                          size: 54,
                          color: _scannerLendo
                              ? AppColors.greenDot
                              : const Color(0xFF93C5FD),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _scannerLendo
                            ? 'VALIDANDO...'
                            : _studentQrId != null
                            ? 'QR CODE LIDO'
                            : 'APONTE A CARTEIRINHA',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: _scannerLendo
                              ? AppColors.greenDot
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: _ScannerCorner(alignment: Alignment.topLeft),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: _ScannerCorner(alignment: Alignment.topRight),
                ),
                Positioned(
                  left: 14,
                  bottom: 14,
                  child: _ScannerCorner(alignment: Alignment.bottomLeft),
                ),
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: _ScannerCorner(alignment: Alignment.bottomRight),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 7, color: AppColors.greenDot),
                      SizedBox(width: 5),
                      Text(
                        'Câmera do dispositivo ativa',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF93C5FD),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'LEITURA DE QR CODE EM TEMPO REAL',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: AppColors.hintGray,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    key: const ValueKey('aprovar-validacao'),
                    onPressed: _scannerLendo ? null : _aprovarValidacao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF86EFAC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 17),
                    label: const Text(
                      'Aprovar Validação',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    key: const ValueKey('simular-recusa'),
                    onPressed: _scannerLendo ? null : _simularRecusa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEE2E2),
                      foregroundColor: const Color(0xFFDC2626),
                      disabledBackgroundColor: const Color(0xFFFECACA),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 17),
                    label: const Text(
                      'Recusar leitura',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
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

  Widget _buildEmbarques(MotoristaDataStore store) {
    final embarques = store.embarques;
    final ultimos = embarques.take(6).toList();
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
              const Icon(Icons.groups, size: 17, color: AppColors.primary),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Últimos Embarques',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.badgeBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: AppColors.greenDot),
                    SizedBox(width: 4),
                    Text(
                      'Tempo Real',
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
          const SizedBox(height: 12),
          if (ultimos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 30,
                    color: AppColors.hintGray,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Nenhum embarque validado ainda.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            )
          else
            for (var i = 0; i < ultimos.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _EmbarqueRow(passageiro: ultimos[i]),
            ],
          const SizedBox(height: 13),
          SizedBox(
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () => _snack(
                'Lista completa: ${store.lotacao} passageiros a bordo.',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                backgroundColor: AppColors.softBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              icon: const Icon(Icons.list_alt, size: 16),
              label: Text(
                'Ver Lista Completa de Passageiros (${store.lotacao})',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRodape() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBlueBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi, size: 14, color: AppColors.green),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Sincronização offline ativa • Dados criptografados pelo BusFlow Zero-Knowledge',
              style: TextStyle(
                fontSize: 10.5,
                height: 1.35,
                color: AppColors.textGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  const _ScannerCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        border: Border(
          top: alignment.y < 0
              ? const BorderSide(color: Color(0xFF38BDF8), width: 3)
              : BorderSide.none,
          bottom: alignment.y > 0
              ? const BorderSide(color: Color(0xFF38BDF8), width: 3)
              : BorderSide.none,
          left: alignment.x < 0
              ? const BorderSide(color: Color(0xFF38BDF8), width: 3)
              : BorderSide.none,
          right: alignment.x > 0
              ? const BorderSide(color: Color(0xFF38BDF8), width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}

class _EmbarqueRow extends StatelessWidget {
  const _EmbarqueRow({required this.passageiro});

  final EmbarquePassageiro passageiro;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: passageiro.cor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              passageiro.iniciais,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: passageiro.corTexto,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                passageiro.nome,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${passageiro.ra} • ${passageiro.curso}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 13,
                  color: AppColors.green,
                ),
                const SizedBox(width: 3),
                Text(
                  passageiro.hora,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              passageiro.portao,
              style: const TextStyle(fontSize: 10, color: AppColors.hintGray),
            ),
          ],
        ),
      ],
    );
  }
}
