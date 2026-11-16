import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'core/secure_vault.dart';

class AdvancedToolsPage extends StatefulWidget {
  final List<Map<String, String>> readings;
  final double lowTarget;
  final double highTarget;
  final String patientName;

  const AdvancedToolsPage({super.key, required this.readings, required this.lowTarget, required this.highTarget, required this.patientName});

  @override
  State<AdvancedToolsPage> createState() => _AdvancedToolsPageState();
}

class _AdvancedToolsPageState extends State<AdvancedToolsPage> {
  final _notifications = FlutterLocalNotificationsPlugin();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final _family = <Map<String, dynamic>>[];
  final _meals = <Map<String, dynamic>>[];
  final _activities = <Map<String, dynamic>>[];
  final _reminders = <Map<String, dynamic>>[];
  bool _loaded = false;
  bool _notificationsReady = false;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      tzdata.initializeTimeZones();
      try { tz.setLocalLocation(tz.getLocation('America/Ciudad_Juarez')); } catch (_) { tz.setLocalLocation(tz.UTC); }
      await _notifications.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
      final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final permission = await android?.requestNotificationsPermission();
      _notificationsReady = permission ?? true;
      final saved = await SecureVault.read('workspace_v5');
      if (saved != null) {
        final data = jsonDecode(saved) as Map<String, dynamic>;
        _family.addAll((data['family'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)));
        _meals.addAll((data['meals'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)));
        _activities.addAll((data['activities'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)));
        _reminders.addAll((data['reminders'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)));
      }
    } catch (e) { _error = 'No se pudieron cargar los datos protegidos: $e'; }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    await SecureVault.write('workspace_v5', jsonEncode({'family': _family, 'meals': _meals, 'activities': _activities, 'reminders': _reminders}));
  }

  void _message(String value) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _dictate(TextEditingController controller, StateSetter setDialog) async {
    final available = await _speech.initialize(
      onError: (error) => _message('No se pudo usar el micrófono: ${error.errorMsg}'),
    );
    if (!available) {
      _message('El reconocimiento de voz no está disponible. Puedes escribir el dato.');
      return;
    }
    await _speech.listen(
      localeId: 'es_MX',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (!mounted) return;
        setDialog(() {
          controller.value = TextEditingValue(
            text: result.recognizedWords,
            selection: TextSelection.collapsed(offset: result.recognizedWords.length),
          );
        });
      },
    );
  }

  Future<String?> _askText(String title, String label, {String initial = ''}) async {
    final c = TextEditingController(text: initial);
    return showDialog<String>(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialog) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: IconButton(
              tooltip: 'Dictar por voz',
              icon: const Icon(Icons.mic),
              onPressed: () => _dictate(c, setDialog),
            ),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () { _speech.stop(); Navigator.pop(ctx); }, child: const Text('Cancelar')),
          FilledButton(onPressed: () { _speech.stop(); Navigator.pop(ctx, c.text.trim()); }, child: const Text('Guardar')),
        ],
      ),
    ));
  }

  Future<void> _addFamily() async {
    final name = await _askText('Nuevo perfil familiar', 'Nombre o alias');
    if (name == null || name.isEmpty) return;
    final relation = await _askText('Relación familiar', 'Ej. mamá, hijo, pareja', initial: 'Familiar') ?? 'Familiar';
    setState(() => _family.add({'id': DateTime.now().microsecondsSinceEpoch.toString(), 'name': name, 'relation': relation, 'created': DateTime.now().toIso8601String(), 'readings': <dynamic>[]}));
    await _save();
  }

  Future<void> _addFamilyReading(Map<String, dynamic> profile) async {
    final value = await _askText('Medición de ${profile['name']}', 'Glucosa en mg/dL');
    if (value == null) return;
    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null || number <= 0 || number > 1500) { _message('Escribe un valor válido en mg/dL.'); return; }
    final contextText = await _askText('Contexto de la medición', 'Ayuno, después de comer, antes de dormir...');
    if (contextText == null) return;
    final entries = List<Map<String, dynamic>>.from((profile['readings'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)));
    entries.insert(0, {'value': number, 'context': contextText, 'date': DateTime.now().toIso8601String()});
    profile['readings'] = entries;
    setState(() {});
    await _save();
  }

  Future<void> _addMeal() async {
    final name = await _askText('Registrar alimentación', 'Alimentos o comida');
    if (name == null || name.isEmpty) return;
    final detail = await _askText('Detalles de alimentación', 'Porción, bebida o nota (opcional)') ?? '';
    setState(() => _meals.insert(0, {'name': name, 'detail': detail, 'date': DateTime.now().toIso8601String()}));
    await _save();
  }

  Future<void> _addActivity() async {
    final name = await _askText('Registrar actividad', 'Actividad (ej. caminata)');
    if (name == null || name.isEmpty) return;
    final duration = await _askText('Duración', 'Minutos');
    if (duration == null) return;
    final minutes = int.tryParse(duration);
    if (minutes == null || minutes < 1 || minutes > 1440) { _message('Indica una duración válida entre 1 y 1440 minutos.'); return; }
    final note = await _askText('Cómo te sentiste', 'Nota opcional') ?? '';
    setState(() => _activities.insert(0, {'name': name, 'minutes': minutes, 'note': note, 'date': DateTime.now().toIso8601String()}));
    await _save();
  }

  Future<void> _addReminder() async {
    if (!_notificationsReady) {
      _message('Activa el permiso de notificaciones de TU DOCTOR FAMILIAR en Ajustes de Android e inténtalo de nuevo.');
      return;
    }
    final title = await _askText('Nuevo recordatorio diario', 'Título (ej. medir glucosa)');
    if (title == null || title.isEmpty) return;
    final body = await _askText('Mensaje del recordatorio', 'Mensaje', initial: 'Es momento de tu seguimiento personal.') ?? '';
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    final id = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
    try {
      await _notifications.zonedSchedule(
        id, title, body, when,
        const NotificationDetails(android: AndroidNotificationDetails('tdf_v7_reminders', 'Recordatorios de salud', channelDescription: 'Avisos personales de seguimiento', importance: Importance.high, priority: Priority.high)),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      setState(() => _reminders.insert(0, {'id': id, 'title': title, 'body': body, 'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'}));
      await _save();
      _message('Recordatorio diario programado.');
    } catch (_) { _message('Android no permitió programar el aviso. Revisa permisos y ahorro de batería.'); }
  }

  Future<void> _deleteReminder(Map<String, dynamic> reminder) async {
    await _notifications.cancel(reminder['id'] as int);
    setState(() => _reminders.remove(reminder));
    await _save();
  }

  String _localBrain() {
    if (widget.readings.isEmpty) return 'Aún no hay lecturas para interpretar. Registra una medición con hora y contexto.';
    final values = widget.readings.map((r) => double.tryParse(r['value'] ?? '') ?? 0).where((v) => v > 0).toList();
    if (values.isEmpty) return 'No hay valores válidos para analizar.';
    final latest = values.first;
    final average = values.reduce((a, b) => a + b) / values.length;
    final above = values.where((v) => v > widget.highTarget).length;
    final below = values.where((v) => v < widget.lowTarget).length;
    final result = <String>[];
    if (latest < 54) {
      result.add('ALERTA: lectura menor de 54 mg/dL. Sigue tu plan de emergencia indicado por tu equipo médico. Si hay desmayo, convulsiones, confusión intensa o no puede tragar, llama a emergencias.');
    } else if (latest < 70) {
      result.add('Lectura menor de 70 mg/dL: puede indicar hipoglucemia. Sigue el plan personal que te indicó tu profesional de salud; no esperes a que la app te indique un tratamiento.');
    } else if (latest > 250) {
      result.add('Lectura superior a 250 mg/dL. Sigue las instrucciones de tu equipo médico para valores altos. Si tienes vómitos, respiración anormal, somnolencia o empeoramiento, busca atención urgente.');
    } else if (latest > widget.highTarget) {
      result.add('La última lectura está por encima de tu meta personal configurada.');
    } else if (latest < widget.lowTarget) {
      result.add('La última lectura está por debajo de tu meta personal configurada.');
    } else {
      result.add('La última lectura está dentro de tu meta personal configurada.');
    }
    result.add('Promedio simple de ${values.length} lecturas: ${average.toStringAsFixed(1)} mg/dL.');
    result.add('Historial revisado: $above lecturas por encima y $below por debajo de tus límites configurados.');
    result.add('Contexto más reciente: ${widget.readings.first['context'] ?? 'no especificado'}. La interpretación depende también de comidas, medicamentos, enfermedad, ejercicio y hora.');
    result.add('Este cerebro local utiliza reglas transparentes sin internet. No es un modelo de IA clínica, no diagnostica y nunca modifica medicamentos ni dosis.');
    return result.join('\n\n');
  }

  Future<void> _exportPdf() async {
    if (widget.readings.isEmpty) { _message('Agrega mediciones antes de crear el informe.'); return; }
    final values = widget.readings.map((r) => double.tryParse(r['value'] ?? '') ?? 0).toList();
    final average = values.reduce((a, b) => a + b) / values.length;
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(build: (_) => [
      pw.Header(level: 0, child: pw.Text('TU DOCTOR FAMILIAR 6.0')),
      pw.Text('Informe de seguimiento · ${widget.patientName}'),
      pw.Text('Mediciones: ${values.length}'),
      pw.Text('Promedio simple: ${average.toStringAsFixed(1)} mg/dL'),
      pw.Text('Meta personal: ${widget.lowTarget.toStringAsFixed(0)}–${widget.highTarget.toStringAsFixed(0)} mg/dL'),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(headers: ['Fecha', 'Paciente', 'mg/dL', 'Contexto', 'Nota'], data: widget.readings.map((r) => [r['date'] ?? '', r['patientName'] ?? widget.patientName, r['value'] ?? '', r['context'] ?? '', r['note'] ?? '']).toList()),
      pw.SizedBox(height: 12),
      pw.Text('Documento informativo. No constituye diagnóstico ni indicación de tratamiento.'),
    ]));
    await Printing.sharePdf(bytes: await doc.save(), filename: 'tu_doctor_familiar_7_informe.pdf');
  }

  Widget _section(String title, IconData icon, List<Widget> children) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: const Color(0xFF087E8B)), const SizedBox(width: 9), Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))]),
      const SizedBox(height: 10), ...children,
    ])),
  );

  String _date(dynamic value) {
    try { final d = DateTime.parse(value.toString()).toLocal(); return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}'; } catch (_) { return value.toString(); }
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
    const Text('TU DOCTOR FAMILIAR 7.0', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
    Text('Paciente principal: ${widget.patientName}', style: const TextStyle(color: Colors.black54)),
    const SizedBox(height: 5),
    if (!_loaded) const LinearProgressIndicator(),
    if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
    _section('Cerebro local', Icons.psychology_alt, [
      Text(_loaded ? _localBrain() : 'Cargando motor local...', style: const TextStyle(height: 1.45)),
      const SizedBox(height: 8),
      const Text('Análisis local por reglas, sin conexión. Es apoyo informativo, no diagnóstico ni sustituto del médico.', style: TextStyle(fontSize: 12, color: Colors.black54)),
    ]),
    _section('Perfiles familiares', Icons.family_restroom, [
      const Text('Perfiles y mediciones separados en este dispositivo. Pide consentimiento antes de registrar información de otra persona.'),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: _addFamily, icon: const Icon(Icons.person_add), label: const Text('Agregar integrante')),
      if (_family.isEmpty) const Text('Aún no hay integrantes agregados.'),
      ..._family.map((p) => Card(color: const Color(0xFFF3F8F8), child: ExpansionTile(
        title: Text(p['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${p['relation']} · ${(p['readings'] as List? ?? []).length} mediciones'),
        children: [
          Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => _addFamilyReading(p), icon: const Icon(Icons.add), label: const Text('Registrar glucosa'))),
          ...((p['readings'] as List? ?? []).take(8).map((r) => ListTile(dense: true, title: Text('${r['value']} mg/dL · ${r['context']}'), subtitle: Text(_date(r['date']))))),
        ],
      ))),
    ]),
    _section('Recordatorios', Icons.notifications_active, [
      const Text('Programa avisos diarios en el teléfono. No reemplazan recetas, instrucciones ni alarmas médicas.'),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: _addReminder, icon: const Icon(Icons.add_alarm), label: const Text('Programar recordatorio')),
      if (_reminders.isEmpty) const Text('No hay recordatorios programados.'),
      ..._reminders.map((r) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.alarm), title: Text(r['title'].toString()), subtitle: Text('Diario · ${r['time']}'), trailing: IconButton(tooltip: 'Eliminar', icon: const Icon(Icons.delete_outline), onPressed: () => _deleteReminder(r)))),
      Text(_notificationsReady ? 'Permiso de notificaciones concedido.' : 'Notificaciones no autorizadas o no disponibles. Revisa Ajustes de Android.', style: const TextStyle(fontSize: 12, color: Colors.black54)),
    ]),
    _section('Alimentación', Icons.restaurant, [
      const Text('Registra comidas y notas para revisar patrones con tu profesional o nutriólogo.'),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: _addMeal, icon: const Icon(Icons.add), label: const Text('Registrar comida')),
      if (_meals.isEmpty) const Text('Todavía no hay comidas registradas.'),
      ..._meals.take(12).map((m) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.restaurant_menu), title: Text(m['name'].toString()), subtitle: Text('${m['detail']} · ${_date(m['date'])}'))),
    ]),
    _section('Actividad física', Icons.directions_walk, [
      const Text('Registra el tipo de actividad, duración y cómo te sentiste. Adapta el ejercicio a tu condición y recomendaciones médicas.'),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: _addActivity, icon: const Icon(Icons.add), label: const Text('Registrar actividad')),
      if (_activities.isEmpty) const Text('Todavía no hay actividades registradas.'),
      ..._activities.take(12).map((a) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.fitness_center), title: Text('${a['name']} · ${a['minutes']} min'), subtitle: Text('${a['note']} · ${_date(a['date'])}'))),
      if (_activities.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Total registrado: ${_activities.fold<int>(0, (sum, a) => sum + (a['minutes'] as int))} minutos', style: const TextStyle(fontWeight: FontWeight.w700))),
    ]),
    _section('Informe de seguimiento', Icons.picture_as_pdf, [
      const Text('Genera un PDF con las mediciones del paciente principal para compartir en consulta.'),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: _exportPdf, icon: const Icon(Icons.ios_share), label: const Text('Exportar informe PDF')),
    ]),
    const Padding(padding: EdgeInsets.only(top: 10), child: Text('Importante: esta aplicación no diagnostica, no prescribe y nunca modifica dosis de insulina o medicamentos. Ante una emergencia, busca atención médica inmediata.', style: TextStyle(fontSize: 12, color: Colors.black54))),
  ]);
}
