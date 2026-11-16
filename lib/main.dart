import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'core/secure_vault.dart';

void main() => runApp(const TuDoctorFamiliarApp());

class TuDoctorFamiliarApp extends StatelessWidget {
  const TuDoctorFamiliarApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TU DOCTOR FAMILIAR',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087E8B), brightness: Brightness.light),
      scaffoldBackgroundColor: const Color(0xFFF4F8FA),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF4F8FA), foregroundColor: Color(0xFF15343B), elevation: 0),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    ),
    home: const HomePage(),
  );
}

class Reading {
  final double value;
  final DateTime date;
  final String context;
  final String note;
  Reading({required this.value, required this.date, required this.context, this.note = ''});
  Map<String, dynamic> toJson() => {'value': value, 'date': date.toIso8601String(), 'context': context, 'note': note};
  factory Reading.fromJson(Map<String, dynamic> j) => Reading(value: (j['value'] as num).toDouble(), date: DateTime.parse(j['date']), context: j['context'] ?? 'Otro', note: j['note'] ?? '');
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  List<Reading> readings = [];
  double lowTarget = 80;
  double highTarget = 130;
  bool loading = true;
  bool _storageError = false;
  final contexts = ['En ayunas', 'Antes de comer', '1–2 h después de comer', 'Antes de dormir', 'Otro'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    // Prioriza el almacén cifrado. Si es una instalación anterior, migra
    // los valores heredados y conserva los originales hasta confirmar escritura.
    try {
      final encryptedReadings = await SecureVault.read('readings');
      final raw = encryptedReadings ?? p.getString('readings') ?? '[]';
      readings = (jsonDecode(raw) as List)
          .map((e) => Reading.fromJson(Map<String,dynamic>.from(e)))
          .toList()..sort((a,b)=>b.date.compareTo(a.date));
      final encryptedLow = await SecureVault.read('lowTarget');
      final encryptedHigh = await SecureVault.read('highTarget');
      lowTarget = double.tryParse(encryptedLow ?? '') ?? p.getDouble('lowTarget') ?? 80;
      highTarget = double.tryParse(encryptedHigh ?? '') ?? p.getDouble('highTarget') ?? 130;
      if (encryptedReadings == null && p.containsKey('readings')) {
        await SecureVault.write('readings', jsonEncode(readings.map((e)=>e.toJson()).toList()));
        await SecureVault.write('lowTarget', lowTarget.toString());
        await SecureVault.write('highTarget', highTarget.toString());
        await p.remove('readings');
        await p.remove('lowTarget');
        await p.remove('highTarget');
      }
    } catch (_) {
      // Si el almacén cifrado falla, bloquea escrituras para no sobrescribir datos.
      _storageError = true;
      readings = [];
      lowTarget = 80;
      highTarget = 130;
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _save() async {
    if (_storageError) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se guardó: el almacén protegido necesita revisión. Tus datos anteriores se conservaron.')));
      return;
    }
    final p = await SharedPreferences.getInstance();
    await SecureVault.write('readings', jsonEncode(readings.map((e)=>e.toJson()).toList()));
    await SecureVault.write('lowTarget', lowTarget.toString());
    await SecureVault.write('highTarget', highTarget.toString());
    await p.remove('readings');
    await p.remove('lowTarget');
    await p.remove('highTarget');
  }

  String _date(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  String _status(double v) => v < 70 ? 'Baja: revisa el plan indicado por tu profesional' : v < lowTarget ? 'Por debajo de tu meta configurada' : v > highTarget ? 'Por encima de tu meta configurada' : 'Dentro de tu meta configurada';
  Color _statusColor(double v) => v < 70 ? const Color(0xFFB3261E) : (v < lowTarget || v > highTarget) ? const Color(0xFFB66A00) : const Color(0xFF087E8B);

  Future<void> _addReading() async {
    final value = TextEditingController();
    final note = TextEditingController();
    String contextValue = contexts.first;
    final ok = await showDialog<bool>(context: context, builder: (ctx)=>StatefulBuilder(builder:(ctx,setD)=>AlertDialog(
      title: const Text('Registrar glucosa'),
      content: SingleChildScrollView(child: Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:value,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Resultado en mg/dL',border:OutlineInputBorder())),
        const SizedBox(height:12),
        DropdownButtonFormField<String>(value:contextValue,decoration:const InputDecoration(labelText:'Momento de medición'),items:contexts.map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setD(()=>contextValue=v??contexts.first)),
        const SizedBox(height:12),
        TextField(controller:note,maxLines:2,decoration:const InputDecoration(labelText:'Nota opcional (comida, síntomas, etc.)',border:OutlineInputBorder())),
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancelar')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Guardar'))],
    )));
    if (ok == true) {
      final v = double.tryParse(value.text.trim().replaceAll(',','.'));
      if (v == null || v <= 0 || v > 1500) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Escribe un valor válido en mg/dL.'))); return; }
      setState(()=>readings.insert(0,Reading(value:v,date:DateTime.now(),context:contextValue,note:note.text.trim())));
      await _save();
    }
  }

  Future<void> _editTargets() async {
    final lo=TextEditingController(text:lowTarget.toStringAsFixed(0));
    final hi=TextEditingController(text:highTarget.toStringAsFixed(0));
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Mis metas personales'),content:Column(mainAxisSize:MainAxisSize.min,children:[
      const Text('Configura los límites que te indicó tu profesional de salud. No uses valores genéricos como tratamiento.',style:TextStyle(fontSize:13)),
      TextField(controller:lo,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Límite inferior (mg/dL)')),
      TextField(controller:hi,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Límite superior (mg/dL)')),
    ]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancelar')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Guardar'))]));
    if(ok==true){final a=double.tryParse(lo.text),b=double.tryParse(hi.text);if(a==null||b==null||a<40||b>500||a>=b){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Revisa los límites. El inferior debe ser menor al superior.')));return;}setState((){lowTarget=a;highTarget=b;});await _save();}
  }

  Future<void> _shareReport() async {
    if(readings.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Todavía no hay mediciones para compartir.')));return;}
    final sorted=[...readings]..sort((a,b)=>a.date.compareTo(b.date));
    final avg=sorted.map((e)=>e.value).reduce((a,b)=>a+b)/sorted.length;
    final lines=sorted.map((e)=>'${_date(e.date)} | ${e.value.toStringAsFixed(0)} mg/dL | ${e.context} | ${e.note}').join('\n');
    await Share.share('TU DOCTOR FAMILIAR — Reporte personal\nMediciones: ${sorted.length}\nPromedio simple: ${avg.toStringAsFixed(1)} mg/dL\nMeta configurada: ${lowTarget.toStringAsFixed(0)}–${highTarget.toStringAsFixed(0)} mg/dL\n\nFecha | Resultado | Contexto | Nota\n$lines\n\nEste reporte es informativo y no sustituye una valoración médica.');
  }

  @override
  Widget build(BuildContext context) {
    final pages=[_dashboard(),_history(),_education(),_habits(),_profile()];
    return Scaffold(
      appBar: AppBar(title: Row(children:[Container(width:38,height:38,decoration:BoxDecoration(color:const Color(0xFFD9F1F1),borderRadius:BorderRadius.circular(12)),child:const Icon(Icons.favorite_rounded,color:Color(0xFF087E8B))),const SizedBox(width:10),const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('TU DOCTOR FAMILIAR',style:TextStyle(fontSize:16,fontWeight:FontWeight.w800)),Text('Salud y acompañamiento',style:TextStyle(fontSize:11,color:Colors.black54))])]),actions:[IconButton(tooltip:'Registrar glucosa',onPressed:_addReading,icon:const Icon(Icons.add_circle_outline))]),
      body: loading ? const Center(child:CircularProgressIndicator()) : SafeArea(child:IndexedStack(index:tab,children:pages)),
      floatingActionButton: tab<2 ? FloatingActionButton.extended(onPressed:_addReading,icon:const Icon(Icons.add),label:const Text('Glucosa')) : null,
      bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const[
        NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'Inicio'),
        NavigationDestination(icon:Icon(Icons.show_chart),label:'Historial'),
        NavigationDestination(icon:Icon(Icons.menu_book_outlined),label:'Aprender'),
        NavigationDestination(icon:Icon(Icons.eco_outlined),label:'Hábitos'),
        NavigationDestination(icon:Icon(Icons.person_outline),label:'Mi perfil'),
      ]),
    );
  }

  Widget _page(Widget child)=>SingleChildScrollView(padding:const EdgeInsets.fromLTRB(16,8,16,28),child:child);
  Widget _section(String title,{Widget? trailing})=>Padding(padding:const EdgeInsets.only(top:22,bottom:10),child:Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:Color(0xFF173B43)))),if(trailing!=null)trailing]));
  Widget _dashboard(){
    final last=readings.isEmpty?null:readings.first;
    final recent=readings.take(7).toList();
    return _page(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Container(width:double.infinity,padding:const EdgeInsets.all(20),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF087E8B),Color(0xFF35A6A0)]),borderRadius:BorderRadius.circular(24)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Tu salud, paso a paso',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w800)),
        SizedBox(height:8),Text('Registra, aprende y comparte información útil con tu equipo de salud.',style:TextStyle(color:Colors.white,fontSize:14)),
      ])),
      _section('Última medición',trailing:TextButton(onPressed:_editTargets,child:const Text('Mis metas'))),
      Card(child:Padding(padding:const EdgeInsets.all(18),child:last==null?const Text('Aún no tienes mediciones. Registra tu primera lectura para comenzar.'):Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(crossAxisAlignment:CrossAxisAlignment.end,children:[Text(last.value.toStringAsFixed(0),style:const TextStyle(fontSize:42,fontWeight:FontWeight.w800,color:Color(0xFF173B43))),const Padding(padding:EdgeInsets.only(bottom:8,left:6),child:Text('mg/dL'))]),
        Text(_status(last.value),style:TextStyle(fontWeight:FontWeight.w700,color:_statusColor(last.value))),
        const SizedBox(height:6),Text('${_date(last.date)} · ${last.context}',style:const TextStyle(color:Colors.black54,fontSize:12)),
        if(last.value<70)const Padding(padding:EdgeInsets.only(top:12),child:Text('Una lectura menor de 70 mg/dL puede indicar hipoglucemia. Sigue tu plan personal de actuación. Si hay desmayo, convulsiones, confusión intensa o no puede tragar, busca ayuda de emergencia.',style:TextStyle(color:Color(0xFFB3261E),fontWeight:FontWeight.w600))),
      ]))),
      _section('Tu rango configurado'),
      Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[const Icon(Icons.tune,color:Color(0xFF087E8B),size:28),const SizedBox(width:12),Expanded(child:Text('${lowTarget.toStringAsFixed(0)} – ${highTarget.toStringAsFixed(0)} mg/dL\nSegún las indicaciones de tu profesional de salud',style:const TextStyle(fontWeight:FontWeight.w600))),TextButton(onPressed:_editTargets,child:const Text('Editar'))]))),
      _section('Últimos registros',trailing:TextButton(onPressed:()=>setState(()=>tab=1),child:const Text('Ver todos'))),
      if(recent.isEmpty)const Text('Tus registros aparecerán aquí.') else ...recent.map((r)=>_readingTile(r)),
      _section('Recuerda'),
      const _InfoCard(icon:Icons.health_and_safety,title:'Información, no diagnóstico',body:'La interpretación depende de la hora, comidas, tratamiento y metas individuales. Consulta tus dudas con tu equipo médico.'),
      const SizedBox(height:10),const _InfoCard(icon:Icons.lock_outline,title:'Privacidad en esta versión',body:'Los registros se guardan localmente en el dispositivo. Esta versión inicial no cifra los datos ni sincroniza con la nube; evita guardar información médica identificable.'),
    ]));
  }
  Widget _readingTile(Reading r)=>Card(child:ListTile(leading:CircleAvatar(backgroundColor:_statusColor(r.value).withOpacity(.12),child:Icon(Icons.water_drop,color:_statusColor(r.value))),title:Text('${r.value.toStringAsFixed(0)} mg/dL',style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${r.context} · ${_date(r.date)}'),trailing:const Icon(Icons.chevron_right)));
  Widget _history()=>_page(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('Tu historial',style:TextStyle(fontSize:23,fontWeight:FontWeight.w800)),
    const Text('Observa tus registros y compártelos con tu profesional de salud.',style:TextStyle(color:Colors.black54)),
    _section('Resumen'),
    Card(child:Padding(padding:const EdgeInsets.all(16),child:readings.isEmpty?const Text('Sin datos todavía.'):Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('${readings.length} mediciones registradas',style:const TextStyle(fontWeight:FontWeight.bold)),
      const SizedBox(height:8),Text('Promedio simple: ${(readings.map((e)=>e.value).reduce((a,b)=>a+b)/readings.length).toStringAsFixed(1)} mg/dL'),
      const SizedBox(height:12),SizedBox(height:150,width:double.infinity,child:CustomPaint(painter:MiniChart(readings.take(14).toList().reversed.toList()))),
    ]))),
    _section('Mediciones',trailing:TextButton.icon(onPressed:_shareReport,icon:const Icon(Icons.share),label:const Text('Compartir'))),
    if(readings.isEmpty)const Text('No hay mediciones para mostrar.') else ...readings.map(_readingTile),
    if(readings.isNotEmpty)Align(alignment:Alignment.centerRight,child:TextButton.icon(onPressed:()async{final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Borrar historial'),content:const Text('Esta acción elimina las mediciones guardadas en este dispositivo.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancelar')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Borrar'))]));if(yes==true){setState(()=>readings.clear());await _save();}},icon:const Icon(Icons.delete_outline),label:const Text('Borrar historial'))),
  ]));
  Widget _education()=>_page(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('Aprende sobre tu salud',style:TextStyle(fontSize:23,fontWeight:FontWeight.w800)),
    const Text('Material educativo general. Confirma siempre las indicaciones con personal de salud.',style:TextStyle(color:Colors.black54)),
    _section('Glucosa y diabetes'),
    const _InfoCard(icon:Icons.bloodtype,title:'¿Qué es la glucosa?',body:'La glucosa es una fuente de energía. La glucemia cambia durante el día y puede variar según alimentos, actividad física, estrés, enfermedad y medicamentos.'),
    const _InfoCard(icon:Icons.monitor_heart,title:'Cómo medir y registrar',body:'Lávate y seca las manos, utiliza el equipo según sus instrucciones y anota el resultado, hora, contexto y síntomas. Si el resultado no coincide con cómo te sientes, repite la medición siguiendo las indicaciones del dispositivo y consulta.'),
    const _InfoCard(icon:Icons.warning_amber,title:'Glucosa baja',body:'Menos de 70 mg/dL suele considerarse una lectura baja. Sigue el plan que te haya dado tu equipo médico. Si la persona está inconsciente, convulsiona o no puede tragar, no le des alimentos ni bebidas por boca y llama a emergencias.'),
    const _InfoCard(icon:Icons.medication_outlined,title:'Insulina y medicamentos',body:'Nunca cambies ni suspendas dosis por una recomendación de esta app. La técnica de aplicación, conservación y dosis deben aprenderse con un profesional y las instrucciones del producto.'),
    _section('Fuentes para ampliar'),
    const _InfoCard(icon:Icons.public,title:'Organización Mundial de la Salud (OMS)',body:'Consulta who.int para información general y materiales de prevención y atención de la diabetes.'),
    const _InfoCard(icon:Icons.public,title:'Federación Internacional de Diabetes (IDF)',body:'Consulta idf.org para recursos educativos, prevención y orientación para personas y familias.'),
    const _InfoCard(icon:Icons.info_outline,title:'Contenido pendiente de revisión clínica',body:'Los módulos detallados, videos de aplicación de insulina y protocolos locales se incorporarán después de una revisión por profesionales de salud.'),
  ]));
  Widget _habits()=>_page(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('Hábitos saludables',style:TextStyle(fontSize:23,fontWeight:FontWeight.w800)),
    const Text('Ideas generales que deben adaptarse a tu edad, condición y plan médico.',style:TextStyle(color:Colors.black54)),
    _section('Alimentación'),
    const _InfoCard(icon:Icons.restaurant,title:'Plato equilibrado',body:'Como orientación general, combina verduras, una fuente de proteína y alimentos con fibra. Las porciones y los carbohidratos adecuados son individuales; un nutriólogo puede ayudarte a planearlos.'),
    const _InfoCard(icon:Icons.water_drop_outlined,title:'Hidratación',body:'Elige agua con frecuencia, salvo que tu equipo médico te haya indicado limitar líquidos. Evita usar bebidas azucaradas como hidratación habitual.'),
    _section('Actividad física'),
    const _InfoCard(icon:Icons.directions_walk,title:'Muévete de forma segura',body:'Caminar y realizar actividad adaptada puede ayudar al bienestar. Comienza gradualmente y consulta antes de iniciar ejercicio si tienes complicaciones, síntomas o dudas sobre hipoglucemia.'),
    const _InfoCard(icon:Icons.bedtime_outlined,title:'Sueño y rutina',body:'Mantener horarios regulares de sueño y comidas puede facilitar el seguimiento. Registra cambios que notes y coméntalos en consulta.'),
    _section('Recetas y rutinas personalizadas'),
    const _InfoCard(icon:Icons.construction_outlined,title:'Próxima ampliación',body:'Estamos preparando biblioteca de recetas, planes de actividad y videos revisados. No se mostrarán planes personalizados hasta contar con criterios clínicos y revisión profesional.'),
  ]));
  Widget _profile()=>_page(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('Mi perfil',style:TextStyle(fontSize:23,fontWeight:FontWeight.w800)),
    _section('Metas de glucosa'),
    Card(child:ListTile(leading:const Icon(Icons.tune,color:Color(0xFF087E8B)),title:Text('${lowTarget.toStringAsFixed(0)}–${highTarget.toStringAsFixed(0)} mg/dL'),subtitle:const Text('Configura el rango indicado por tu profesional'),trailing:const Icon(Icons.edit),onTap:_editTargets)),
    _section('Herramientas'),
    Card(child:ListTile(leading:const Icon(Icons.ios_share),title:const Text('Compartir reporte'),subtitle:const Text('Enviar historial y promedio simple'),onTap:_shareReport)),
    const _InfoCard(icon:Icons.family_restroom,title:'Acompañamiento familiar',body:'La gestión de perfiles familiares con permisos y consentimiento se añadirá en una versión posterior. Por ahora, esta instalación guarda un único perfil local.'),
    const _InfoCard(icon:Icons.notifications_active_outlined,title:'Recordatorios',body:'Los avisos automáticos de medicamentos y mediciones todavía no están activos. No dependas de esta versión para recordar tratamientos.'),
    const _InfoCard(icon:Icons.shield_outlined,title:'Seguridad y límites',body:'No es un servicio de urgencias, no diagnostica y no prescribe. No introduzcas datos identificables. Para síntomas graves o una emergencia, contacta los servicios de emergencia locales.'),
    const SizedBox(height:12),Center(child:Text('TU DOCTOR FAMILIAR · versión 0.2.0',style:TextStyle(color:Colors.black45,fontSize:12))),
  ]));
}

class _InfoCard extends StatelessWidget {
  final IconData icon; final String title; final String body;
  const _InfoCard({required this.icon,required this.title,required this.body});
  @override
  Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:40,height:40,decoration:BoxDecoration(color:const Color(0xFFE3F3F2),borderRadius:BorderRadius.circular(12)),child:Icon(icon,color:const Color(0xFF087E8B))),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:15)),const SizedBox(height:5),Text(body,style:const TextStyle(height:1.4,color:Color(0xFF52666B),fontSize:13))]))])));
}

class MiniChart extends CustomPainter {
  final List<Reading> data;
  MiniChart(this.data);
  @override
  void paint(Canvas canvas,Size size){
    final axis=Paint()..color=const Color(0xFFE1E9EB)..strokeWidth=1;
    for(int i=0;i<4;i++){final y=size.height*i/3;canvas.drawLine(Offset(0,y),Offset(size.width,y),axis);}
    if(data.isEmpty)return;
    final maxV=(data.map((e)=>e.value).reduce((a,b)=>a>b?a:b)*1.15).clamp(100,500).toDouble();
    final minV=0.0;
    final path=Path();
    for(int i=0;i<data.length;i++){final x=data.length==1?size.width/2:size.width*i/(data.length-1);final y=size.height-(data[i].value-minV)/(maxV-minV)*size.height;if(i==0)path.moveTo(x,y);else path.lineTo(x,y);}
    final p=Paint()..color=const Color(0xFF087E8B)..style=PaintingStyle.stroke..strokeWidth=3..strokeCap=StrokeCap.round;
    canvas.drawPath(path,p);
    final dot=Paint()..color=const Color(0xFF087E8B);
    for(int i=0;i<data.length;i++){final x=data.length==1?size.width/2:size.width*i/(data.length-1);final y=size.height-(data[i].value-minV)/(maxV-minV)*size.height;canvas.drawCircle(Offset(x,y),3.5,dot);}
  }
  @override
  bool shouldRepaint(covariant MiniChart old)=>old.data!=data;
}
