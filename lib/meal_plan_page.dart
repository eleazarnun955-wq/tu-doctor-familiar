import 'package:flutter/material.dart';

/// Recetario educativo con un menú de 7 días y 21 preparaciones caseras.
/// Las porciones de carbohidratos deben individualizarse con el equipo de salud.
class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});
  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  int day = 0;
  String meal = 'Todas';
  final days = const [
    {
      'name':'Lunes',
      'meals':[
        {'type':'Almuerzo','name':'Tostadas horneadas de frijol y pico de gallo','ingredients':'2 tostadas horneadas de maíz; 1/3 taza de frijoles de olla machacados; jitomate, cebolla, cilantro y limón; 1/4 de aguacate; lechuga.','steps':'Unta los frijoles en las tostadas. Añade lechuga, pico de gallo, aguacate y limón. Acompaña con agua simple.','tip':'Cuenta las tostadas y los frijoles dentro de tu porción de carbohidratos.'},
        {'type':'Comida','name':'Pollo a la mexicana con calabacitas','ingredients':'120 g de pechuga de pollo; 1 taza de calabacita; jitomate, cebolla y chile al gusto; 1 tortilla de maíz; 1 cucharadita de aceite.','steps':'Cocina el pollo en tiras con aceite. Agrega jitomate, cebolla y calabacita; tapa hasta que esté cocido. Sirve con la tortilla.','tip':'Llena aproximadamente la mitad del plato con verduras.'},
        {'type':'Cena','name':'Ensalada de atún con garbanzos','ingredients':'1 lata de atún en agua escurrida; 1/3 taza de garbanzos cocidos; pepino, jitomate, hojas verdes; limón y 1 cucharadita de aceite de oliva.','steps':'Mezcla todos los ingredientes y adereza con limón y aceite. Refrigera unos minutos antes de servir.','tip':'Los garbanzos aportan carbohidratos y fibra; ajusta la cantidad a tu plan.'}
      ]
    },
    {
      'name':'Martes',
      'meals':[
        {'type':'Almuerzo','name':'Avena con manzana, canela y nuez','ingredients':'1/3 taza de avena seca; 3/4 taza de leche natural sin azúcar; 1/2 manzana picada; canela; 1 cucharada de nuez picada.','steps':'Cuece la avena con la leche y canela. Añade la manzana y termina con nuez. No agregues azúcar ni miel.','tip':'La fruta entera aporta fibra; la leche y la avena también cuentan como carbohidratos.'},
        {'type':'Comida','name':'Pescado al limón con nopales','ingredients':'120–150 g de filete de pescado; 1 taza de nopales; jitomate, cebolla, cilantro, limón; 1/2 taza de arroz integral cocido.','steps':'Hornea o cocina el pescado en sartén antiadherente con limón y hierbas. Cuece los nopales y mézclalos con jitomate y cebolla. Sirve con arroz.','tip':'Prefiere pescado al horno o a la plancha, no empanizado.'},
        {'type':'Cena','name':'Quesadillas de champiñones','ingredients':'2 tortillas pequeñas de maíz; 1 taza de champiñones; 40 g de queso panela; epazote y salsa casera.','steps':'Saltea champiñones con epazote. Rellena las tortillas con champiñones y panela; calienta en comal sin freír.','tip':'Acompaña con ensalada de hojas verdes y evita añadir crema.'}
      ]
    },
    {
      'name':'Miércoles',
      'meals':[
        {'type':'Almuerzo','name':'Huevos con espinaca y tortilla','ingredients':'1 huevo y 2 claras; 1 taza de espinaca; jitomate y cebolla; 1 tortilla de maíz; 1/4 de aguacate.','steps':'Saltea cebolla, jitomate y espinaca. Agrega huevo y claras batidos y cocina completamente. Sirve con tortilla y aguacate.','tip':'Usa poco aceite y acompaña con agua o café sin azúcar.'},
        {'type':'Comida','name':'Tazón de carne magra con verduras','ingredients':'100–120 g de bistec magro; 1 taza de brócoli y pimiento; 1/3 taza de frijoles de olla; ajo, limón y comino.','steps':'Asa la carne. Cocina al vapor el brócoli y saltea el pimiento con ajo. Sirve con frijoles y limón.','tip':'Los frijoles son nutritivos, pero cuentan como alimento con carbohidratos.'},
        {'type':'Cena','name':'Sopa de lentejas con verduras','ingredients':'1/2 taza de lentejas cocidas; zanahoria, apio, jitomate y espinaca; ajo, laurel y caldo bajo en sodio.','steps':'Hierve las verduras con ajo y laurel. Añade lentejas cocidas y espinaca; cocina hasta suavizar.','tip':'No agregues embutidos ni cubitos concentrados con mucho sodio.'}
      ]
    },
    {
      'name':'Jueves',
      'meals':[
        {'type':'Almuerzo','name':'Yogur natural con frutos rojos y semillas','ingredients':'3/4 taza de yogur natural sin azúcar; 1/2 taza de fresas o moras; 1 cucharada de chía; 2 cucharadas de avena.','steps':'Sirve el yogur y agrega fruta lavada, chía y avena. Deja reposar 5 minutos.','tip':'Elige yogur sin azúcar añadida y revisa la etiqueta.'},
        {'type':'Comida','name':'Tinga de pollo en hojas de lechuga','ingredients':'120 g de pollo cocido deshebrado; jitomate, cebolla y chipotle al gusto; hojas grandes de lechuga; 1/3 taza de frijoles.','steps':'Cocina jitomate y cebolla, agrega pollo y chipotle. Sirve la tinga sobre hojas de lechuga con frijoles al lado.','tip':'Si agregas tostadas o tortillas, considera su aporte de carbohidratos.'},
        {'type':'Cena','name':'Ensalada de huevo y aguacate','ingredients':'1 huevo cocido y 2 claras; lechuga, pepino y jitomate; 1/4 de aguacate; limón y pimienta.','steps':'Pica el huevo y las verduras. Mezcla con aguacate, limón y pimienta.','tip':'Si necesitas más energía, ajusta una porción de cereal integral con tu nutriólogo.'}
      ]
    },
    {
      'name':'Viernes',
      'meals':[
        {'type':'Almuerzo','name':'Mollete integral ligero','ingredients':'1/2 bolillo integral; 1/4 taza de frijoles; 30 g de queso bajo en grasa; pico de gallo.','steps':'Tuesta el pan, unta frijoles y agrega queso. Gratina y termina con pico de gallo.','tip':'El pan y los frijoles aportan carbohidratos; cuida la porción.'},
        {'type':'Comida','name':'Albóndigas de pavo en caldillo','ingredients':'120 g de pavo molido; jitomate, ajo, cebolla, calabacita y zanahoria; 1/3 taza de arroz integral cocido.','steps':'Forma albóndigas pequeñas con pavo y especias. Cocina en caldillo de jitomate; añade verduras y cuece por completo. Sirve con arroz.','tip':'Evita sazonadores altos en sodio y verifica que el pavo esté bien cocido.'},
        {'type':'Cena','name':'Tacos de nopal con queso panela','ingredients':'2 nopales medianos; 50 g de panela; salsa de jitomate; 1 tortilla de maíz; cilantro y cebolla.','steps':'Asa los nopales y el queso. Sirve en tiras con salsa y cilantro; acompaña con una tortilla.','tip':'El nopal suma verduras; la tortilla cuenta como carbohidrato.'}
      ]
    },
    {
      'name':'Sábado',
      'meals':[
        {'type':'Almuerzo','name':'Tacos de huevo con nopales','ingredients':'1 huevo y 2 claras; 1/2 taza de nopales cocidos; 2 tortillas pequeñas; salsa y cebolla.','steps':'Saltea nopales y cebolla, añade huevo y claras y cocina bien. Sirve en tortillas calientes.','tip':'Ajusta el número de tortillas a tu plan personal.'},
        {'type':'Comida','name':'Fajitas de pollo con pimientos','ingredients':'120–150 g de pollo; pimiento rojo y verde, cebolla; 1/2 taza de quinoa cocida; limón y especias.','steps':'Corta pollo y verduras en tiras. Cocina en sartén con poco aceite hasta que el pollo esté bien cocido. Sirve con quinoa.','tip':'La quinoa también contiene carbohidratos; mide la porción.'},
        {'type':'Cena','name':'Crema ligera de brócoli sin crema','ingredients':'1 1/2 tazas de brócoli; 1/4 taza de leche sin azúcar; cebolla, ajo y pimienta; 40 g de queso panela opcional.','steps':'Cuece brócoli, cebolla y ajo. Licúa con un poco del agua de cocción y leche; calienta sin hervir fuerte.','tip':'Acompaña con proteína si tu plan lo requiere; evita crema y exceso de sal.'}
      ]
    },
    {
      'name':'Domingo',
      'meals':[
        {'type':'Almuerzo','name':'Enfrijoladas horneadas de pollo','ingredients':'2 tortillas de maíz; 1/3 taza de frijoles licuados con agua; 80 g de pollo deshebrado; cebolla, lechuga y queso fresco bajo en grasa.','steps':'Pasa las tortillas por comal, rellena con pollo y cubre con frijoles calientes. Termina con lechuga y poca cantidad de queso.','tip':'No añadas crema; tortillas y frijoles suman carbohidratos.'},
        {'type':'Comida','name':'Pescado en papillote con verduras','ingredients':'150 g de pescado; calabacita, jitomate, cebolla y pimiento; limón, orégano; 1/2 taza de camote asado.','steps':'Coloca pescado y verduras en papel para hornear, sazona con limón y orégano y hornea hasta que el pescado se desmenuce fácilmente. Sirve con camote.','tip':'El camote es nutritivo, pero cuenta como carbohidrato.'},
        {'type':'Cena','name':'Ensalada tibia de garbanzos y verduras','ingredients':'1/3 taza de garbanzos cocidos; espinaca, pepino, jitomate y champiñones; limón y 1 cucharadita de aceite de oliva.','steps':'Saltea ligeramente los champiñones. Mezcla con garbanzos y verduras; adereza con limón y aceite.','tip':'Ajusta la ración de garbanzos según tus metas de carbohidratos.'}
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    final meals = List<Map<String,String>>.from(days[day]['meals'] as List);
    final visible = meal == 'Todas' ? meals : meals.where((m) => m['type'] == meal).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(16,12,16,28), children: [
      const Text('Menú saludable de 7 días',style:TextStyle(fontSize:23,fontWeight:FontWeight.w800)),
      const SizedBox(height:5),
      const Text('21 recetas caseras: almuerzo, comida y cena. Elige un día y abre cada receta para ver ingredientes y preparación.',style:TextStyle(color:Colors.black54)),
      const SizedBox(height:12),
      Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Guía visual del plato',style:TextStyle(fontWeight:FontWeight.w800,fontSize:17)),
        const SizedBox(height:8),
        ClipRRect(borderRadius:BorderRadius.circular(12),child:Row(children:[
          Expanded(flex:2,child:Container(height:18,color:const Color(0xFF54A879))),
          Expanded(child:Container(height:18,color:const Color(0xFF4389C8))),
          Expanded(child:Container(height:18,color:const Color(0xFFE6B64C))),
        ])),
        const SizedBox(height:8),
        const Text('Como orientación general: ½ verduras sin almidón, ¼ proteína magra y ¼ alimentos con carbohidratos. Las necesidades individuales pueden cambiar esta distribución.',style:TextStyle(fontSize:13)),
      ]))),
      const SizedBox(height:10),
      Wrap(spacing:6,runSpacing:6,children:List.generate(days.length,(i)=>ChoiceChip(label:Text(days[i]['name'] as String),selected:day==i,onSelected:(_)=>setState(()=>day=i)))),
      const SizedBox(height:10),
      SegmentedButton<String>(segments:const[
        ButtonSegment(value:'Todas',label:Text('Todas')),
        ButtonSegment(value:'Almuerzo',label:Text('Almuerzo')),
        ButtonSegment(value:'Comida',label:Text('Comida')),
        ButtonSegment(value:'Cena',label:Text('Cena')),
      ],selected:{meal},onSelectionChanged:(s)=>setState(()=>meal=s.first)),
      const SizedBox(height:8),
      ...visible.map((r)=>Card(child:ExpansionTile(
        leading:const Icon(Icons.restaurant_menu,color:Color(0xFF087E8B)),
        title:Text(r['name']!,style:const TextStyle(fontWeight:FontWeight.w700)),
        subtitle:Text(r['type']!),
        childrenPadding:const EdgeInsets.fromLTRB(16,0,16,16),
        children:[
          const Align(alignment:Alignment.centerLeft,child:Text('Ingredientes',style:TextStyle(fontWeight:FontWeight.w800))),
          Align(alignment:Alignment.centerLeft,child:Text(r['ingredients']!)),
          const SizedBox(height:10),
          const Align(alignment:Alignment.centerLeft,child:Text('Preparación',style:TextStyle(fontWeight:FontWeight.w800))),
          Align(alignment:Alignment.centerLeft,child:Text(r['steps']!)),
          const SizedBox(height:10),
          Container(width:double.infinity,padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:const Color(0xFFEAF5F4),borderRadius:BorderRadius.circular(10)),child:Text('Consejo: ${r['tip']}',style:const TextStyle(fontSize:13))),
        ],
      ))),
      const SizedBox(height:12),
      const Text('Aviso importante: este menú es educativo y no sustituye un plan nutricional individual. Si utilizas insulina o medicamentos que pueden causar hipoglucemia, no reduzcas ni omitas comidas ni cambies dosis por seguir estas recetas. Consulta porciones y horarios con tu profesional de salud. Si tienes enfermedad renal, alergias, embarazo u otra condición, pide adaptar el menú.',style:TextStyle(fontSize:12,color:Colors.black54)),
      const SizedBox(height:10),
      const Text('Fuentes consultadas: American Diabetes Association (Diabetes Food Hub), CDC, IMSS-Bienestar y MedlinePlus. Las recetas son adaptaciones caseras inspiradas en recomendaciones de alimentación equilibrada.',style:TextStyle(fontSize:11,color:Colors.black54)),
    ]);
  }
}
