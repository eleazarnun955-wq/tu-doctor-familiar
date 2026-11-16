import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'core/secure_vault.dart';

/// Agenda local de citas. No sustituye la confirmación del consultorio.
class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});
  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final _notifications = FlutterLocalNotificationsPlugin();
  final List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _ready = false;
  bool _storageFailed = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      tzdata.initializeTimeZones();
      try { tz.setLocalLocation(tz.getLocation('America/Ciudad_Juarez')); } catch (_) { tz.setLocalLocation(tz.UTC); }
      await _notifications.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
      final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      _ready = (await android?.requestNotificationsPermission()) ?? true;
      final raw = await SecureVault.read('appointments_v7');
      if (raw != null) {
        final data = jsonDecode(raw) as List;
        _items.addAll(data.map((e) => Map<String, dynamic>.from(e as Map)));
        _items.sort((a,b) => a['when'].toString().compareTo(b['when'].toString()));
      }
    } catch (_) {
      _storageFailed = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_storageFailed) { _message('No se modificaron datos porque el almacén protegido necesita revisión.'); return; }
    await SecureVault.write('appointments_v7', jsonEncode(_items));
  }

  Future<void> _add() async {
    final title = TextEditingController();
    final place = TextEditingController();
    final note = TextEditingController();
    DateTime date = DateTime.now().add(const Duration(days: 1));
    TimeOfDay time = const TimeOfDay(hour: 9, minute: 0);
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => AlertDialog(
      title: const Text('Nueva cita médica'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Especialidad o motivo')),
        TextField(controller: place, decoration: const InputDecoration(labelText: 'Consultorio o lugar (opcional)')),
        TextField(controller: note, maxLines: 2, decoration: const InputDecoration(labelText: 'Notas (opcional)')),
        const SizedBox(height: 8),
        ListTile(contentPadding: EdgeInsets.zero, title: const Text('Fecha'), subtitle: Text(date.day.toString().padLeft(2,'0') + '/' + date.month.toString().padLeft(2,'0') + '/' + date.year.toString()), trailing: const Icon(Icons.calendar_month), onTap: () async {
          final d = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 3650)));
          if (d != null) setD(() => date = DateTime(d.year,d.month,d.day,time.hour,time.minute));
        }),
        ListTile(contentPadding: EdgeInsets.zero, title: const Text('Hora'), subtitle: Text(time.format(ctx)), trailing: const Icon(Icons.access_time), onTap: () async {
          final t = await showTimePicker(context: ctx, initialTime: time);
          if (t != null) setD(() { time = t; date = DateTime(date.year,date.month,date.day,t.hour,t.minute); });
        }),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx,false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(ctx,true), child: const Text('Guardar'))],
    )));
    if (ok != true) return;
    if (title.text.trim().isEmpty) { _message('Escribe el motivo o especialidad de la cita.'); return; }
    final when = DateTime(date.year,date.month,date.day,time.hour,time.minute);
    if (!when.isAfter(DateTime.now())) { _message('Selecciona una fecha y hora futuras.'); return; }
    final id = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    final entry = {'id':id,'title':title.text.trim(),'place':place.text.trim(),'note':note.text.trim(),'when':when.toIso8601String()};
    if (_ready) {
      try {
        await _notifications.zonedSchedule(
          id, 'Cita médica: ' + title.text.trim(), 'Tienes una cita programada.',
          tz.TZDateTime.from(when,tz.local),
          const NotificationDetails(android: AndroidNotificationDetails('tdf_v7_appointments','Citas médicas',channelDescription:'Avisos de citas médicas',importance:Importance.high,priority:Priority.high)),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) { _message('La cita se guardó, pero Android no permitió programar el aviso.'); }
    }
    setState(() { _items.add(entry); _items.sort((a,b) => a['when'].toString().compareTo(b['when'].toString())); });
    await _save();
  }

  Future<void> _delete(Map<String,dynamic> item) async {
    try { await _notifications.cancel(item['id'] as int); } catch (_) {}
    setState(() => _items.remove(item));
    await _save();
  }

  void _message(String text) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text))); }

  String _date(String value) {
    final d = DateTime.parse(value).toLocal();
    return d.day.toString().padLeft(2,'0') + '/' + d.month.toString().padLeft(2,'0') + '/' + d.year.toString() + ' · ' + d.hour.toString().padLeft(2,'0') + ':' + d.minute.toString().padLeft(2,'0');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final now = DateTime.now();
    final upcoming = _items.where((e) => DateTime.tryParse(e['when'].toString())?.isAfter(now) ?? false).toList();
    final past = _items.where((e) => !(DateTime.tryParse(e['when'].toString())?.isAfter(now) ?? false)).toList().reversed.toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Agenda médica',style:TextStyle(fontSize:23,fontWeight:FontWeight.w800)),
      const Text('Organiza consultas, estudios y revisiones. Los avisos dependen de los permisos de Android.',style:TextStyle(color:Colors.black54)),
      const SizedBox(height:12),
      FilledButton.icon(onPressed:_add,icon:const Icon(Icons.add),label:const Text('Agregar cita')),
      if (!_ready) const Padding(padding:EdgeInsets.only(top:8),child:Text('Activa las notificaciones de la app en Ajustes para recibir avisos.',style:TextStyle(fontSize:12,color:Colors.black54))),
      const SizedBox(height:12),
      const Text('Próximas citas',style:TextStyle(fontWeight:FontWeight.w800,fontSize:17)),
      if (upcoming.isEmpty) const ListTile(title:Text('No tienes citas próximas registradas.')),
      ...upcoming.map((e)=>Card(child:ListTile(
        leading:const Icon(Icons.event_available,color:Color(0xFF087E8B)),
        title:Text(e['title'].toString()),
        subtitle:Text(_date(e['when'].toString()) + ((e['place']??'').toString().isEmpty?'':'\n'+e['place'].toString()) + ((e['note']??'').toString().isEmpty?'':'\n'+e['note'].toString())),
        isThreeLine:true,
        trailing:IconButton(tooltip:'Eliminar cita',onPressed:()=>_delete(e),icon:const Icon(Icons.delete_outline)),
      ))),
      const SizedBox(height:16),
      const Text('Citas anteriores',style:TextStyle(fontWeight:FontWeight.w800,fontSize:17)),
      if (past.isEmpty) const ListTile(title:Text('Todavía no hay citas anteriores.')),
      ...past.map((e)=>ListTile(leading:const Icon(Icons.event_note),title:Text(e['title'].toString()),subtitle:Text(_date(e['when'].toString())))),
    ]);
  }
}
