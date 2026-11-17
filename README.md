# TU DOCTOR FAMILIAR 8.0

Aplicación Flutter de seguimiento personal y educación para la salud, con compilación Android y preparación de compilación iOS.

## Identidad y versiones
- Rama de trabajo: `doctor-familiar-8.0`.
- Versión Flutter: `8.0.0+1`.
- Android: APK independiente, identificador `com.tudoctorfamiliar.v8.tu_doctor_familiar`.
- iOS: identificador previsto `com.eleazarcompany.tudoctorfamiliar.v8`.
- Marca: **ELEAZAR COMPANY**.

## Plataformas y compilación
- Android: workflow `.github/workflows/android.yml`, genera el APK de V8.0.
- iOS: workflow `.github/workflows/ios.yml`, usa un runner macOS, prepara la estructura iOS si falta, ejecuta análisis y pruebas y compila la app iOS sin firma.
- El artefacto iOS sin firma sirve para validar la compilación, pero no se puede instalar directamente en un iPhone. Para generar un IPA instalable y distribuirlo por TestFlight o App Store se necesita firma, certificados y perfiles de Apple; no se deben guardar credenciales de firma en el repositorio.

## Funciones
- Seguimiento de glucosa con metas personales, contexto, historial y orientación educativa.
- Perfiles familiares y registros separados por paciente.
- Expediente de salud y herramientas de seguimiento.
- Dictado por voz con transcripción editable.
- Historial, informes PDF y herramientas de respaldo.
- Agenda y recordatorios locales.
- Recursos educativos sobre técnica de inyección de insulina.
- Menú semanal con 21 recetas: desayuno, comida y cena durante siete días.

## Privacidad y seguridad
Los registros de salud son información sensible. Mantén protegido el dispositivo y cualquier respaldo exportado. La aplicación ofrece herramientas de seguimiento y educación; no diagnostica, no prescribe, no calcula dosis ni modifica tratamientos. Confirma las decisiones médicas con un profesional de salud.

## Validación
Los workflows ejecutan `dart analyze` y `flutter test`. La compilación automatizada no sustituye las pruebas funcionales en dispositivos Android y iPhone reales.
