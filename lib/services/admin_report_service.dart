import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'admin_data_store.dart';

class AdminReportService {
  AdminReportService._();

  static Future<Uint8List> createPdf(AdminDataStore store) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'BusFlow • Relatório Geral',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#17457F'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Gerado em ${DateTime.now().toLocal()}'),
          pw.SizedBox(height: 18),
          pw.Text(
            'Indicadores',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.TableHelper.fromTextArray(
            headers: const ['Indicador', 'Quantidade'],
            data: [
              ['Alunos cadastrados', '${store.alunosCadastrados}'],
              ['Motoristas ativos', '${store.motoristasAtivos}'],
              ['Ônibus operacionais', '${store.onibusOperacionais}'],
              ['Viagens em curso', '${store.viagensEmCurso}'],
              ['Usuários na lista', '${store.usuarios.length}'],
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Frota',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.TableHelper.fromTextArray(
            headers: const ['Veículo', 'Placa', 'Status', 'Motorista', 'Rota'],
            data: store.veiculos
                .map(
                  (vehicle) => [
                    vehicle.id,
                    vehicle.placa,
                    vehicle.status,
                    vehicle.motorista,
                    vehicle.linha,
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    return Uint8List.fromList(await document.save());
  }
}
