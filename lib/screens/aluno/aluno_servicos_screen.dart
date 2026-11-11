import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/student_action_store.dart';
import '../../theme.dart';

class AlunoServicosScreen extends StatefulWidget {
  const AlunoServicosScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<AlunoServicosScreen> createState() => _AlunoServicosScreenState();
}

class _AlunoServicosScreenState extends State<AlunoServicosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _reason = TextEditingController();
  final _description = TextEditingController();
  final _bus = TextEditingController();
  final _picker = ImagePicker();
  XFile? _photo;
  List<Map<String, dynamic>> _waitRequests = [];
  List<Map<String, dynamic>> _items = [];
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  bool _saving = false;

  static const _routes = [
    (
      'Linha 01',
      'Campus Central → Centro Urbano',
      '06:40 • 07:20 • 13:00 • 16:30',
    ),
    ('Linha 02', 'Campus Sul → Terminal Sul', '07:10 • 08:00 • 11:30 • 17:10'),
    (
      'Linha 03',
      'Politécnica → Bairro Universitário',
      '06:50 • 08:15 • 12:00 • 18:00',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
    _loadSaved();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _reason.dispose();
    _description.dispose();
    _bus.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final results = await Future.wait([
      StudentActionStore.waitRequests(),
      StudentActionStore.lostFoundItems(),
    ]);
    if (!mounted) return;
    setState(() {
      _waitRequests = results[0];
      _items = results[1];
    });
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveWaitRequest() async {
    final reason = _reason.text.trim();
    if (reason.isEmpty) {
      _message('Informe o motivo do pedido de espera.');
      return;
    }
    setState(() => _saving = true);
    try {
      await StudentActionStore.addWaitRequest(
        reason: reason,
        requestedAt: DateTime.now(),
      );
      _reason.clear();
      await _loadSaved();
      if (mounted) {
        _message(
          'Pedido salvo neste aparelho. A notificação ao motorista depende da sincronização com o Supabase.',
        );
      }
    } catch (error) {
      if (mounted) _message('Não foi possível salvar o pedido: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _choosePhoto(ImageSource source) async {
    try {
      final photo = await _picker.pickImage(
        source: source,
        imageQuality: 65,
        maxWidth: 1200,
      );
      if (photo != null && mounted) setState(() => _photo = photo);
    } catch (error) {
      if (mounted) _message('Não foi possível abrir a imagem: $error');
    }
  }

  Future<void> _saveLostFoundItem(String type) async {
    final description = _description.text.trim();
    if (description.isEmpty || _bus.text.trim().isEmpty || _photo == null) {
      _message('Informe a legenda, o ônibus e anexe uma foto.');
      return;
    }
    setState(() => _saving = true);
    try {
      final image = base64Encode(await _photo!.readAsBytes());
      await StudentActionStore.addLostFoundItem(
        type: type,
        description: description,
        bus: _bus.text.trim(),
        imageBase64: image,
        createdAt: DateTime.now(),
      );
      _description.clear();
      _bus.clear();
      setState(() => _photo = null);
      await _loadSaved();
      if (mounted) {
        _message('Registro de $type salvo neste aparelho.');
      }
    } catch (error) {
      if (mounted) _message('Não foi possível salvar o registro: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Serviços do aluno'),
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pedir espera'),
            Tab(text: 'Rotas'),
            Tab(text: 'Achados e perdidos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_waitTab(), _routesTab(), _lostFoundTab()],
      ),
    );
  }

  Widget _waitTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Solicite que o ônibus aguarde quando houver atraso na saída da aula.',
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _reason,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Motivo da espera',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _saving ? null : _saveWaitRequest,
          icon: const Icon(Icons.send_outlined),
          label: const Text('Enviar pedido'),
        ),
        const SizedBox(height: 18),
        const Text(
          'Pedidos salvos',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        for (final item in _waitRequests)
          Card(
            child: ListTile(
              leading: const Icon(Icons.hourglass_top),
              title: Text(item['reason']?.toString() ?? ''),
              subtitle: Text(item['status']?.toString() ?? ''),
            ),
          ),
      ],
    );
  }

  Widget _routesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CalendarDatePicker(
          initialDate: _selectedDate,
          firstDate: DateTime(DateTime.now().year - 1),
          lastDate: DateTime(DateTime.now().year + 2),
          onDateChanged: (date) =>
              setState(() => _selectedDate = DateUtils.dateOnly(date)),
        ),
        const SizedBox(height: 8),
        Text(
          'Rotas disponíveis • ${_selectedDate.day.toString().padLeft(2, '0')}/'
          '${_selectedDate.month.toString().padLeft(2, '0')}/'
          '${_selectedDate.year}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        for (final route in _routes)
          Card(
            child: ListTile(
              leading: const Icon(Icons.directions_bus_outlined),
              title: Text(route.$1),
              subtitle: Text('${route.$2}\n${route.$3}'),
              isThreeLine: true,
            ),
          ),
        const Text(
          'Horários demonstrativos até a conexão com as rotas do Supabase.',
          style: TextStyle(fontSize: 12, color: AppColors.textGray),
        ),
      ],
    );
  }

  Widget _lostFoundTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _description,
          decoration: const InputDecoration(
            labelText: 'Legenda / descrição do item',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _bus,
          decoration: const InputDecoration(
            labelText: 'Ônibus ou linha',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _choosePhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeria'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _choosePhoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Câmera'),
              ),
            ),
          ],
        ),
        if (_photo != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FutureBuilder(
              future: _photo!.readAsBytes(),
              builder: (context, snapshot) => snapshot.hasData
                  ? Image.memory(snapshot.data!, height: 150, fit: BoxFit.cover)
                  : const LinearProgressIndicator(),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : () => _saveLostFoundItem('Perdido'),
                child: const Text('Perdi um item'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : () => _saveLostFoundItem('Achado'),
                child: const Text('Encontrei um item'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Registros neste aparelho',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        for (final item in _items)
          Card(
            child: ListTile(
              leading: _itemImage(item),
              title: Text('${item['type']}: ${item['description']}'),
              subtitle: Text('Ônibus/linha: ${item['bus']}'),
            ),
          ),
      ],
    );
  }

  Widget _itemImage(Map<String, dynamic> item) {
    final image = item['image'];
    if (image is! String || image.isEmpty) {
      return const Icon(Icons.inventory_2_outlined);
    }
    try {
      return Image.memory(
        base64Decode(image),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      );
    } on FormatException {
      return const Icon(Icons.broken_image_outlined);
    }
  }
}
