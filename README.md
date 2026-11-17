# TU DOCTOR FAMILIAR 8.0

Aplicación Flutter gratuita de seguimiento personal y educación para la salud, con compilación Android, preparación iOS y versión web instalable.

## Identidad y versiones
- Rama de trabajo: `doctor-familiar-8.0`.
- Versión Flutter: `8.0.0+1`.
- Android: APK independiente, identificador `com.tudoctorfamiliar.v8.tu_doctor_familiar`.
- iOS nativo: identificador previsto `com.eleazarcompany.tudoctorfamiliar.v8`.
- Marca: **ELEAZAR COMPANY**.

## Plataformas y distribución gratuita
- Android: workflow `.github/workflows/android.yml`, genera el APK de V8.0.
- iOS nativo: workflow `.github/workflows/ios.yml`, compila sin firma para validar. El ZIP resultante no se instala directamente en iPhone; generar un IPA firmado para App Store/TestFlight requiere los procesos y credenciales de Apple.
- Web para iPhone, iPad, Android y computadora: workflow `.github/workflows/web.yml`. Genera la versión web de Flutter y la publica en GitHub Pages cuando Pages está disponible para el repositorio. En iPhone se abre con Safari y se puede agregar a la pantalla de inicio desde el menú Compartir.
- La versión web no es un IPA ni una publicación de App Store. Es una alternativa web instalable (PWA) que evita la cuenta Apple Developer.
- La publicación automática necesita que GitHub Pages esté habilitado/permitido en la configuración del repositorio. La dirección pública se informa en el resultado del despliegue de GitHub Actions.
- En iPhone: abre el enlace publicado con **Safari**, toca **Compartir** y selecciona **Agregar a pantalla de inicio**. Después abre el icono **TU DOCTOR** desde la pantalla de inicio.
- En Android: abre el enlace con Chrome y usa **Instalar aplicación** o **Agregar a pantalla de inicio** cuando el navegador lo ofrezca.
- La PWA abre en modo independiente y usa el almacenamiento local del navegador; no equivale a una app IPA ni garantiza que todas las funciones nativas estén disponibles en Safari.

## Privacidad y uso entre dispositivos
- Los registros guardados localmente en Android no se transfieren automáticamente a la versión web ni a otro teléfono.
- En la versión web, los datos quedan sujetos al almacenamiento y a las políticas del navegador del dispositivo. No borres los datos del sitio ni el almacenamiento del navegador sin exportar antes un respaldo.
- No se debe asumir que los datos se sincronizan entre familiares o dispositivos: no se ha configurado una base de datos compartida.
- Antes de distribuir ampliamente la versión web, deben probarse el guardado y recuperación de registros, dictado por voz, informes PDF, recordatorios y respaldo en Safari y Chrome. Algunas funciones nativas pueden tener limitaciones en navegador.

## Funciones
- Seguimiento de glucosa con metas personales, contexto, historial y orientación educativa.
- Perfiles familiares y registros separados por paciente.
- Expediente de salud y herramientas de seguimiento.
- Dictado por voz con transcripción editable.
- Historial, informes PDF y herramientas de respaldo.
- Agenda y recordatorios locales.
- Recursos educativos sobre técnica de inyección de insulina.
- Menú semanal con 21 recetas: almuerzo, comida y cena durante siete días.

## Privacidad y seguridad
Los registros de salud son información sensible. Mantén protegido el dispositivo y cualquier respaldo exportado. La aplicación ofrece herramientas de seguimiento y educación; no diagnostica, no prescribe, no calcula dosis ni modifica tratamientos. Confirma las decisiones médicas con un profesional de salud.

## Validación
Los workflows ejecutan `dart analyze` y `flutter test`. La compilación automatizada no sustituye las pruebas funcionales en dispositivos Android, iPhone y navegadores reales.
