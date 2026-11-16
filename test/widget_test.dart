import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tu_doctor_familiar/main.dart';

const _secureStorageChannel =
    MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
  });

  testWidgets('muestra la pantalla principal de TU DOCTOR FAMILIAR',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TuDoctorFamiliarApp());
    // La pantalla contiene un indicador animado mientras carga. Esperamos
    // la carga explícitamente en lugar de pumpAndSettle sobre esa animación.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('TU DOCTOR FAMILIAR'), findsOneWidget);
    expect(find.text('Tu salud, paso a paso'), findsOneWidget);
  });
}
