import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tu_doctor_familiar/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('muestra la pantalla principal de TU DOCTOR FAMILIAR',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TuDoctorFamiliarApp());
    await tester.pumpAndSettle();

    expect(find.text('TU DOCTOR FAMILIAR'), findsOneWidget);
    expect(find.text('Tu salud, paso a paso'), findsOneWidget);
  });
}
