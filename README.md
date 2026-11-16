# TU DOCTOR FAMILIAR 6.0

Versión Android independiente basada en la rama funcional 5.0. La V5.0 permanece intacta y ambas versiones usan identificadores de paquete diferentes para poder instalarse por separado.

## Identidad y compilación
- Rama: `doctor-familiar-6.0`.
- Versión Flutter: `6.0.0+1`.
- Android applicationId: `com.tudoctorfamiliar.v6.tu_doctor_familiar`.
- Artefacto: `TU-DOCTOR-FAMILIAR-6.0-Android`.
- El APK solo se considera listo cuando GitHub Actions termina correctamente y el artefacto se puede descargar y verificar.

## Funciones heredadas de V5.0
- Registro de glucosa, metas personales configurables e historial con contexto y notas.
- Nombre del paciente y dictado de voz en español con transcripción editable.
- Cerebro local basado en reglas transparentes, sin internet y sin diagnóstico ni cambios de tratamiento.
- Perfiles familiares, alimentación, actividad física y recordatorios locales.
- Informes PDF, almacenamiento cifrado local y recursos educativos.

## Mejoras integradas en V6.0
- Expediente complementario cifrado para presión arterial, pulso, peso, estatura y cintura.
- Diario de síntomas con intensidad, duración y notas.
- Registro de medicamentos conforme a las instrucciones del profesional y anotaciones personales de tomas; no confirma ingestión.
- Registro de resultados de laboratorio con fecha, unidades y notas de referencia.
- Resumen descriptivo de registros y evolución de peso, sin diagnósticos automáticos.
- Respaldo JSON y restauración con validación de formato y perfil, conservando registros existentes.
- Nueva sección Expediente en la navegación.

## Datos y privacidad
Los nuevos registros V6 se almacenan cifrados en el dispositivo. Los respaldos compartidos se exportan como texto JSON sin cifrado externo y contienen información médica sensible: deben guardarse de forma privada. La V6 tiene un paquete Android independiente. Los datos privados de la instalación V5 no se copian automáticamente entre aplicaciones; conserva V5 y sus datos hasta que verifiques tus respaldos y la nueva versión.

## Seguridad clínica
La aplicación es educativa y de seguimiento personal. No diagnostica, prescribe, interpreta laboratorios como diagnóstico ni modifica dosis de insulina o medicamentos. Las metas y tratamientos deben seguir las indicaciones del profesional de salud. Ante una emergencia, busca atención médica inmediata.

## Validación
La automatización ejecuta `dart analyze`, `flutter test` y `flutter build apk --release`. La compilación exitosa no sustituye la validación en un teléfono Android real.
