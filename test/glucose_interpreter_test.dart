import 'package:flutter_test/flutter_test.dart';
import 'package:tu_doctor_familiar/core/glucose_interpreter.dart';

void main() {
  group('GlucoseInterpreter', () {
    test('prioriza síntomas graves', () {
      final a = GlucoseInterpreter.assess(valueMgDl: 110, personalLow: 80,
        personalHigh: 130, context: GlucoseContext.other, severeSymptoms: true);
      expect(a.flag, GlucoseFlag.urgentReview);
    });
    test('marca lectura menor de 70 como posible baja', () {
      final a = GlucoseInterpreter.assess(valueMgDl: 65, personalLow: 80,
        personalHigh: 130, context: GlucoseContext.fasting);
      expect(a.flag, GlucoseFlag.low);
    });
    test('respeta metas personales', () {
      final a = GlucoseInterpreter.assess(valueMgDl: 145, personalLow: 90,
        personalHigh: 140, context: GlucoseContext.afterMeal);
      expect(a.flag, GlucoseFlag.abovePersonalTarget);
    });
    test('rechaza metas inconsistentes', () {
      expect(() => GlucoseInterpreter.assess(valueMgDl: 100, personalLow: 140,
        personalHigh: 90, context: GlucoseContext.other), throwsArgumentError);
    });
  });
}
