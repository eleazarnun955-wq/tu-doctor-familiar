/// Reglas educativas locales; no diagnostican ni indican cambios de tratamiento.
enum GlucoseContext { fasting, beforeMeal, afterMeal, bedtime, other }
enum GlucoseFlag { low, belowPersonalTarget, abovePersonalTarget, withinPersonalTarget, urgentReview }

class GlucoseAssessment {
  final GlucoseFlag flag;
  final String title;
  final String guidance;
  const GlucoseAssessment(this.flag,this.title,this.guidance);
}

class GlucoseInterpreter {
  /// Los límites personales deben venir del plan acordado con el profesional.
  /// El umbral <70 mg/dL se muestra como señal de posible hipoglucemia,
  /// sin reemplazar el plan individual de actuación.
  static GlucoseAssessment assess({
    required double valueMgDl,
    required double personalLow,
    required double personalHigh,
    required GlucoseContext context,
    bool severeSymptoms = false,
  }) {
    if (valueMgDl <= 0 || valueMgDl > 1500 || personalLow >= personalHigh) {
      throw ArgumentError('Medición o metas no válidas.');
    }
    if (severeSymptoms) {
      return const GlucoseAssessment(
        GlucoseFlag.urgentReview,
        'Busca atención de emergencia',
        'Si hay desmayo, convulsiones, dificultad para respirar, confusión intensa o incapacidad para tragar, llama a emergencias. No esperes a que la app interprete la lectura.',
      );
    }
    if (valueMgDl < 70) {
      return const GlucoseAssessment(
        GlucoseFlag.low,
        'Posible glucosa baja',
        'Sigue el plan de hipoglucemia que te indicó tu profesional de salud. Si la persona está inconsciente o no puede tragar, no le des nada por boca y llama a emergencias.',
      );
    }
    if (valueMgDl < personalLow) {
      return const GlucoseAssessment(
        GlucoseFlag.belowPersonalTarget,
        'Por debajo de tu meta',
        'Compara esta lectura con el momento de medición y tu plan personal. Si se repite o tienes síntomas, contacta a tu equipo de salud.',
      );
    }
    if (valueMgDl > personalHigh) {
      return const GlucoseAssessment(
        GlucoseFlag.abovePersonalTarget,
        'Por encima de tu meta',
        'Una lectura aislada no permite diagnosticar ni ajustar dosis. Registra el contexto y sigue las indicaciones de tu equipo médico; busca ayuda si te encuentras mal.',
      );
    }
    return const GlucoseAssessment(
      GlucoseFlag.withinPersonalTarget,
      'Dentro de tu meta configurada',
      'Esta lectura está dentro del rango personal que guardaste. Continúa registrando el contexto y sigue tu plan de cuidado.',
    );
  }
}
