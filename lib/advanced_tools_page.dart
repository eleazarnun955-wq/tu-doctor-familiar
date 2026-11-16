import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvancedToolsPage extends StatelessWidget {
  final List<Map<String, String>> readings;
  final double lowTarget;
  final double highTarget;
  final String patientName;

  const AdvancedToolsPage({
    super.key,
    required this.readings,
    required this.lowTarget,
    required this.highTarget,
    required this.patientName,
  });

  Future<void> _exportPdf(BuildContext context) async {
    if (readings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega mediciones antes de crear el informe.')),
      );
      return;
    }
    final values = readings.map((r) => double.tryParse(r['value'] ?? '') ?? 0).toList();
    final average = values.reduce((a, b) => a + b) / values.length;
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(build: (_) => [
      pw.Header(level: 0, child: pw.Text('TU DOCTOR FAMILIAR')),
      pw.Text('Informe de seguimiento de glucosa'),
      pw.Text('Paciente: $patientName'),
      pw.SizedBox(height: 8),
      pw.Text('Mediciones: ${readings.length}'),
      pw.Text('Promedio simple: ${average.toStringAsFixed(1)} mg/dL'),
      pw.Text('Meta personal configurada: ${lowTarget.toStringAsFixed(0)}–${highTarget.toStringAsFixed(0)} mg/dL'),
      pw.SizedBox(height: 14),
      pw.TableHelper.fromTextArray(
        headers: ['Fecha y hora', 'mg/dL', 'Contexto', 'Nota'],
        data: readings.map((r) => [r['date'] ?? '', r['value'] ?? '', r['context'] ?? '', r['note'] ?? '']).toList(),
      ),
      pw.SizedBox(height: 16),
      pw.Text('Documento informativo. No constituye diagnóstico ni indicación de tratamiento. Comparte estos datos con tu profesional de salud.'),
    ]));
    await Printing.sharePdf(bytes: await doc.save(), filename: 'tu_doctor_familiar_informe.pdf');
  }

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
    children: [
      const Text('Herramientas avanzadas', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text('Paciente: $patientName', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      const Text('Funciones de apoyo para tu seguimiento personal.', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 16),
      Card(child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Color(0xFF087E8B), size: 30),
        title: const Text('Informe médico en PDF', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Exporta tus mediciones, promedio y metas para compartirlas en consulta.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _exportPdf(context),
      )),
      const SizedBox(height: 8),
      const _FeatureCard(
        icon: Icons.psychology_alt_outlined,
        title: 'Cerebro local inteligente',
        body: 'La interpretación segura por reglas continúa disponible sin internet. El modelo de IA local todavía requiere integrar un modelo cuantizado compatible y validar memoria, batería y precisión; esta pantalla no simula que ya está instalado.',
        status: 'En preparación',
      ),
      const _FeatureCard(
        icon: Icons.family_restroom,
        title: 'Perfiles familiares',
        body: 'La separación de historiales, permisos y consentimiento debe completarse antes de activar perfiles compartidos. No introduzcas datos de otras personas en el perfil actual.',
        status: 'En desarrollo',
      ),
      const _FeatureCard(
        icon: Icons.notifications_active_outlined,
        title: 'Recordatorios',
        body: 'Los avisos del sistema para mediciones y medicamentos aún no están activos. No dependas de esta versión para recordar tratamientos.',
        status: 'En desarrollo',
      ),
      const _FeatureCard(
        icon: Icons.restaurant_menu,
        title: 'Alimentación y actividad',
        body: 'Prioriza verduras, fibra, agua si no tienes restricción médica y actividad gradual adaptada a tu condición. Los planes individualizados requieren valoración profesional.',
        status: 'Educación general',
      ),
      const SizedBox(height: 14),
      const Text('Fuentes médicas institucionales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Card(child: Column(children: [
        ListTile(leading: const Icon(Icons.public), title: const Text('Organización Mundial de la Salud'), subtitle: const Text('Información sobre diabetes'), trailing: const Icon(Icons.open_in_new), onTap: () => _open('https://www.who.int/health-topics/diabetes')),
        const Divider(height: 1),
        ListTile(leading: const Icon(Icons.public), title: const Text('Federación Internacional de Diabetes'), subtitle: const Text('Recursos educativos'), trailing: const Icon(Icons.open_in_new), onTap: () => _open('https://idf.org/')),
        const Divider(height: 1),
        ListTile(leading: const Icon(Icons.public), title: const Text('Instituto Nacional de Diabetes (NIDDK)'), subtitle: const Text('Información para pacientes'), trailing: const Icon(Icons.open_in_new), onTap: () => _open('https://www.niddk.nih.gov/health-information/diabetes')),
      ])),
      const SizedBox(height: 12),
      const Text('La app no diagnostica, no prescribe y nunca modifica dosis de insulina o medicamentos. Ante una emergencia, busca atención médica inmediata.', style: TextStyle(fontSize: 12, color: Colors.black54)),
    ],
  );
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String status;
  const _FeatureCard({required this.icon, required this.title, required this.body, required this.status});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFF087E8B), size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.4)),
          const SizedBox(height: 7),
          Text(status, style: const TextStyle(color: Color(0xFF087E8B), fontWeight: FontWeight.w700, fontSize: 12)),
        ])),
      ]),
    ),
  );
}
