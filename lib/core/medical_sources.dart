/// Enlaces de consulta a fuentes institucionales. Requieren conexión a internet.
class MedicalSources {
  static const Map<String, Uri> trusted = {
    'OMS — Diabetes': Uri.parse('https://www.who.int/health-topics/diabetes'),
    'Federación Internacional de Diabetes': Uri.parse('https://idf.org/'),
    'American Diabetes Association': Uri.parse('https://diabetes.org/'),
    'Secretaría de Salud de México': Uri.parse('https://www.gob.mx/salud'),
    'COFEPRIS': Uri.parse('https://www.gob.mx/cofepris'),
  };

  /// Devuelve una búsqueda web acotada a una fuente institucional.
  /// La app debe etiquetar el resultado como contenido externo y mostrar su fecha.
  static Uri search(String query, {String domain = 'who.int'}) {
    final clean = query.trim();
    if (clean.isEmpty) throw ArgumentError('Escribe un tema para buscar.');
    const allowed = {'who.int', 'idf.org', 'diabetes.org', 'gob.mx'};
    if (!allowed.contains(domain)) throw ArgumentError('Fuente no permitida.');
    return Uri.https('www.google.com', '/search', {
      'q': 'site:$domain $clean diabetes',
    });
  }
}
