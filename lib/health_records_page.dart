import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'core/secure_vault.dart';

/// Expediente V6: registros complementarios protegidos y separados por paciente.
class HealthRecordsPage extends StatefulWidget {
  final String patientName;
  const HealthRecordsPage({super.key, required this.patientName});
  @override
  State<HealthRecordsPage> createState() => _HealthRecordsPageState();
}

class _HealthRecordsPageState extends State<HealthRecordsPage> {
  final Map<String, List<Map<String, dynamic>>> records = {
    'pressure': [], 'body': [], 'symptoms': [], 'medicines': [], 'labs': [],
  };
  bool loading = true;
  String? error;
  String? selectedPatient;
  List<String> familyNames = [];
  String get patient => selectedPatient ?? (widget.patientName.trim().isEmpty ? 'Paciente' : widget.patientName.trim());

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final familyRaw = await SecureVault.read('workspace_v5');
      if (familyRaw != null) {
        final familyData = jsonDecode(familyRaw) as Map<String, dynamic>;
        familyNames = (familyData['family'] as List? ?? []).map((e) => (e as Map)['name'].toString()).where((name) => name.isNotEmpty).toSet().toList();
      }
      final raw = await SecureVault.read('workspace_v6_health');
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        for (final key in records.keys) {
          records[key]!.addAll((data[key] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .where((e) => (e['patient'] ?? 'Paciente') == patient));
          records[key]!.sort((a,b) => (b['date'] ?? '').toString().compareTo((a['date'] ?? '').toString()));
        }
      }
    } catch (_) { error = 'No se pudieron leer los datos protegidos. No se modificaron.'; }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _save() async {
    try {
      final raw = await SecureVault.read('workspace_v6_health');
      final data = raw == null ? <String,dynamic>{} : Map<String,dynamic>.from(jsonDecode(raw) as Map);
      for (final key in records.keys) {
        final others = (data[key] as List? ?? []).map((e) => Map<String,dynamic>.from(e as Map))
          .where((e) => (e['patient'] ?? 'Paciente') != patient).toList();
        data[key] = [...others, ...records[key]!];
      }
      await SecureVault.write('workspace_v6_health', jsonEncode(data));
    } catch (_) { _msg('No se pudo guardar el expediente protegido. Revisa el almacenamiento.'); }
  }

  Future<void> _changePatient(String? value) async {
    if (value == null || value == patient) return;
    setState(() { selectedPatient = value; loading = true; for (final list in records.values) { list.clear(); } });
    await _load();
  }

  void _msg(String value) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value))); }
  Future<String?> _ask(String title, String label, {String initial = '', TextInputType keyboard = TextInputType.text, int lines = 1}) async {
    final c = TextEditingController(text: initial);
    return showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(controller: c, autofocus: true, keyboardType: keyboard, maxLines: lines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Guardar')),
      ],
    ));
  }

  Future<void> _add(String kind) async {
    final item = <String,dynamic>{'patient': patient, 'date': DateTime.now().toIso8601String()};
    if (kind == 'pressure') {
      final s = await _ask('Presión arterial', 'Sistólica (número superior)', keyboard: TextInputType.number); if (s == null) return;
      final d = await _ask('Presión arterial', 'Diastólica (número inferior)', keyboard: TextInputType.number); if (d == null) return;
      final p = await _ask('Pulso', 'Latidos por minuto (opcional)', keyboard: TextInputType.number) ?? '';
      final note = await _ask('Nota', 'Síntomas o circunstancias (opcional)') ?? '';
      final sv = int.tryParse(s), dv = int.tryParse(d), pv = p.isEmpty ? null : int.tryParse(p);
      if (sv == null || dv == null || sv < 40 || sv > 300 || dv < 20 || dv > 200 || (p.isNotEmpty && (pv == null || pv < 20 || pv > 250))) { _msg('Revisa los números capturados.'); return; }
      item.addAll({'systolic': sv, 'diastolic': dv, 'pulse': pv, 'note': note});
    } else if (kind == 'body') {
      final w = await _ask('Peso', 'Peso en kg', keyboard: const TextInputType.numberWithOptions(decimal: true)); if (w == null) return;
      final h = await _ask('Estatura', 'Estatura en cm (opcional)', keyboard: const TextInputType.numberWithOptions(decimal: true)) ?? '';
      final c = await _ask('Cintura', 'Cintura en cm (opcional)', keyboard: const TextInputType.numberWithOptions(decimal: true)) ?? '';
      final weight = double.tryParse(w.replaceAll(',', '.')), height = h.isEmpty ? null : double.tryParse(h.replaceAll(',', '.')), waist = c.isEmpty ? null : double.tryParse(c.replaceAll(',', '.'));
      if (weight == null || weight < 1 || weight > 500 || (h.isNotEmpty && (height == null || height < 30 || height > 250)) || (c.isNotEmpty && (waist == null || waist < 20 || waist > 250))) { _msg('Revisa las medidas.'); return; }
      item.addAll({'weight': weight, 'heightCm': height, 'waistCm': waist});
    } else if (kind == 'symptoms') {
      final name = await _ask('Diario de síntomas', '¿Qué síntoma o molestia presentas?'); if (name == null || name.isEmpty) return;
      final intensity = await _ask('Intensidad', 'Del 1 al 10 (opcional)', keyboard: TextInputType.number) ?? '';
      final duration = await _ask('Duración', '¿Desde cuándo o cuánto dura?') ?? '';
      final note = await _ask('Detalles', 'Otros detalles (opcional)', lines: 2) ?? '';
      final n = intensity.isEmpty ? null : int.tryParse(intensity);
      if (intensity.isNotEmpty && (n == null || n < 1 || n > 10)) { _msg('La intensidad debe estar entre 1 y 10.'); return; }
      item.addAll({'name': name, 'intensity': n, 'duration': duration, 'note': note});
    } else if (kind == 'medicines') {
      final name = await _ask('Medicamento indicado', 'Nombre del medicamento'); if (name == null || name.isEmpty) return;
      final instruction = await _ask('Indicación profesional', 'Dosis y horario tal como fueron recetados', lines: 2); if (instruction == null) return;
      final schedule = await _ask('Horario', 'Frecuencia indicada (opcional)') ?? '';
      item.addAll({'name': name, 'instruction': instruction, 'schedule': schedule, 'taken': <String>[]});
    } else if (kind == 'labs') {
      final name = await _ask('Estudio de laboratorio', 'Nombre (ej. HbA1c, colesterol)'); if (name == null || name.isEmpty) return;
      final value = await _ask('Resultado', 'Valor y unidad'); if (value == null || value.isEmpty) return;
      final date = await _ask('Fecha del estudio', 'Fecha (opcional)') ?? '';
      final note = await _ask('Referencia', 'Rango del laboratorio o comentario (opcional)', lines: 2) ?? '';
      item.addAll({'name': name, 'value': value, 'studyDate': date, 'note': note});
    }
    setState(() => records[kind]!.insert(0, item));
    await _save();
  }

  Future<void> _logTaken(Map<String,dynamic> item) async {
    final list = List<String>.from((item['taken'] as List? ?? []).map((e) => e.toString()));
    list.insert(0, DateTime.now().toIso8601String());
    item['taken'] = list;
    setState(() {});
    await _save();
    _msg('Toma anotada. La app no confirma que el medicamento se haya ingerido.');
  }

  String _date(dynamic value) {
    try { final d = DateTime.parse(value.toString()).toLocal(); return d.day.toString().padLeft(2,'0') + '/' + d.month.toString().padLeft(2,'0') + '/' + d.year.toString() + ' ' + d.hour.toString().padLeft(2,'0') + ':' + d.minute.toString().padLeft(2,'0'); }
    catch (_) { return value.toString(); }
  }
  Widget _section(String title, IconData icon, List<Widget> children) => Card(child: Padding(
    padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: const Color(0xFF087E8B)), const SizedBox(width: 9), Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))]),
      const SizedBox(height: 10), ...children,
    ])));
  Widget _empty(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(text, style: const TextStyle(color: Colors.black54)));

  Future<void> _backup() async {
    final payload = <String,dynamic>{'format':'tu_doctor_familiar_v6_backup','version':1,'patient':patient,'exportedAt':DateTime.now().toIso8601String(), ...records};
    await Share.share('Respaldo TU DOCTOR FAMILIAR V6.0. Contiene datos sensibles; guárdalo en un lugar privado.\n' + jsonEncode(payload));
  }

  Future<void> _restore() async {
    final raw = await _ask('Restaurar respaldo', 'Pega el JSON del respaldo V6', lines: 6); if (raw == null || raw.isEmpty) return;
    try {
      final payload = jsonDecode(raw) as Map<String,dynamic>;
      if (payload['format'] != 'tu_doctor_familiar_v6_backup' || payload['patient'] != patient) { _msg('El respaldo no corresponde a este perfil o no es válido.'); return; }
      for (final key in records.keys) {
        final incoming = (payload[key] as List? ?? []).map((e) => Map<String,dynamic>.from(e as Map));
        for (final entry in incoming) {
          if (!records[key]!.any((old) => old['date'] == entry['date'] && old['name'] == entry['name'] && old['value'] == entry['value'])) records[key]!.add(entry);
        }
      }
      await _save(); if (mounted) setState(() {});
      _msg('Respaldo restaurado sin borrar registros existentes.');
    } catch (_) { _msg('El archivo no es un respaldo V6 válido. No se modificaron los registros.'); }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final pressure = records['pressure']!, body = records['body']!, symptoms = records['symptoms']!, medicines = records['medicines']!, labs = records['labs']!;
    return ListView(padding: const EdgeInsets.fromLTRB(16,8,16,24), children: [
      Text('Expediente familiar', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
      DropdownButtonFormField<String>(value: patient, decoration: const InputDecoration(labelText: 'Paciente', border: OutlineInputBorder()), items: [widget.patientName.trim().isEmpty ? 'Paciente' : widget.patientName.trim(), ...familyNames].toSet().map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(), onChanged: _changePatient),
      const SizedBox(height: 8),
      const Text('Datos de salud protegidos en este teléfono.', style: TextStyle(color: Colors.black54)),
      if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
      _section('Presión arterial y pulso', Icons.monitor_heart_outlined, [
        const Text('Registra las cifras de tu monitor. No es un diagnóstico de hipertensión.'),
        FilledButton.icon(onPressed: () => _add('pressure'), icon: const Icon(Icons.add), label: const Text('Registrar presión')),
        if (pressure.isEmpty) _empty('Sin registros de presión.'),
        ...pressure.take(12).map((r) => ListTile(contentPadding: EdgeInsets.zero, title: Text(r['systolic'].toString() + '/' + r['diastolic'].toString() + ' mmHg' + (r['pulse'] == null ? '' : ' · ' + r['pulse'].toString() + ' lpm')), subtitle: Text(_date(r['date']) + ((r['note'] ?? '').toString().isEmpty ? '' : ' · ' + r['note'].toString())))),
      ]),
      _section('Peso y medidas corporales', Icons.monitor_weight_outlined, [
        FilledButton.icon(onPressed: () => _add('body'), icon: const Icon(Icons.add), label: const Text('Registrar peso y medidas')),
        if (body.isEmpty) _empty('Sin registros de peso.'),
        ...body.take(12).map((r) => ListTile(contentPadding: EdgeInsets.zero, title: Text(r['weight'].toString() + ' kg' + (r['heightCm'] == null ? '' : ' · ' + r['heightCm'].toString() + ' cm')), subtitle: Text(_date(r['date']) + (r['waistCm'] == null ? '' : ' · Cintura ' + r['waistCm'].toString() + ' cm')))),
        if (body.length >= 2) Text('Cambio entre los dos registros más recientes: ' + (((body[0]['weight'] as num).toDouble()) - ((body[1]['weight'] as num).toDouble())).toStringAsFixed(1) + ' kg.'),
      ]),
      _section('Diario de síntomas', Icons.note_alt_outlined, [
        FilledButton.icon(onPressed: () => _add('symptoms'), icon: const Icon(Icons.add), label: const Text('Registrar síntoma')),
        if (symptoms.isEmpty) _empty('Sin síntomas registrados.'),
        ...symptoms.take(15).map((r) => ListTile(contentPadding: EdgeInsets.zero, title: Text(r['name'].toString()), subtitle: Text(_date(r['date']) + (r['intensity'] == null ? '' : ' · Intensidad ' + r['intensity'].toString() + '/10') + ((r['duration'] ?? '').toString().isEmpty ? '' : ' · ' + r['duration'].toString()) + ((r['note'] ?? '').toString().isEmpty ? '' : ' · ' + r['note'].toString())))),
      ]),
      _section('Medicamentos indicados', Icons.medication_outlined, [
        const Text('Anota las instrucciones de tu profesional. No cambies dosis ni horarios por indicación de esta app.'),
        FilledButton.icon(onPressed: () => _add('medicines'), icon: const Icon(Icons.add), label: const Text('Agregar medicamento')),
        if (medicines.isEmpty) _empty('Sin medicamentos registrados.'),
        ...medicines.map((m) => Card(color: const Color(0xFFF3F8F8), child: ListTile(
          title: Text(m['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(m['instruction'].toString() + '\nTomas anotadas: ' + ((m['taken'] as List? ?? []).length).toString()),
          isThreeLine: true,
          trailing: IconButton(tooltip: 'Anotar toma', onPressed: () => _logTaken(m), icon: const Icon(Icons.check_circle_outline)),
        ))),
      ]),
      _section('Laboratorios y estudios', Icons.biotech_outlined, [
        FilledButton.icon(onPressed: () => _add('labs'), icon: const Icon(Icons.add), label: const Text('Agregar resultado')),
        if (labs.isEmpty) _empty('Sin resultados registrados.'),
        ...labs.take(20).map((r) => ListTile(contentPadding: EdgeInsets.zero, title: Text(r['name'].toString() + ': ' + r['value'].toString()), subtitle: Text((r['studyDate'] ?? '').toString().isEmpty ? _date(r['date']) : r['studyDate'].toString() + ' · ' + (r['note'] ?? '').toString()))),
      ]),
      _section('Resumen', Icons.insights_outlined, [
        Text('Registros: ' + pressure.length.toString() + ' de presión · ' + body.length.toString() + ' de peso · ' + symptoms.length.toString() + ' síntomas · ' + medicines.length.toString() + ' medicamentos · ' + labs.length.toString() + ' estudios.'),
        if (pressure.isNotEmpty) Text('Última presión: ' + pressure.first['systolic'].toString() + '/' + pressure.first['diastolic'].toString() + ' mmHg.'),
        const Text('El resumen describe los datos capturados; no es una valoración clínica.', style: TextStyle(fontSize: 12, color: Colors.black54)),
      ]),
      _section('Respaldo y recuperación', Icons.enhanced_encryption_outlined, [
        const Text('El respaldo se comparte como texto JSON sin cifrado fuera de la app. Contiene información médica sensible: guárdalo de forma privada.'),
        Wrap(spacing: 8, children: [
          FilledButton.icon(onPressed: _backup, icon: const Icon(Icons.ios_share), label: const Text('Crear respaldo')),
          OutlinedButton.icon(onPressed: _restore, icon: const Icon(Icons.restore), label: const Text('Restaurar respaldo')),
        ]),
      ]),
      const Padding(padding: EdgeInsets.only(top: 8), child: Text('La app no diagnostica, no prescribe ni ajusta tratamientos. Ante síntomas graves o una emergencia, busca atención médica inmediata.', style: TextStyle(fontSize: 12, color: Colors.black54))),
    ]);
  }
}
