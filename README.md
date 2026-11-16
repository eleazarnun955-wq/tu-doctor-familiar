# TU DOCTOR FAMILIAR 4.0

Rama de trabajo independiente basada en TU DOCTOR FAMILIAR 3.0. Esta versión conserva la base funcional anterior y se prepara como una aplicación Android separada.

## Identidad y compilación
- Rama: `doctor-familiar-4.0`.
- Versión Flutter: `4.0.0+1`.
- La automatización crea el proyecto Android con el identificador de organización `com.tudoctorfamiliar.v4` cuando la carpeta móvil no existe, para que V4.0 no reemplace V3.0.
- Artefacto esperado: `TU-DOCTOR-FAMILIAR-4.0-Android`.
- La APK solo se considera lista cuando GitHub Actions termina correctamente y el artefacto se puede descargar y verificar.

## Base heredada de V3.0
- Registro de glucosa con contexto y notas.
- Nombre del paciente, metas personales y dictado de voz con revisión editable.
- Historial, resumen e informes PDF.
- Capa de almacenamiento cifrado y recursos educativos.
- Las funciones heredadas deben volver a analizarse y probarse en la nueva compilación.

## Objetivos de V4.0
- Perfiles familiares realmente separados, con consentimiento y permisos.
- Estadísticas y tendencias ampliadas.
- Diario de alimentos relacionado con mediciones.
- Registros de presión arterial, peso y síntomas.
- Recordatorios locales con permisos y controles claros.
- Informes PDF ampliados para consulta.
- Asistente educativo local, sin diagnóstico ni cambios de tratamiento.
- Copia de seguridad y restauración protegidas.

## Estado de implementación
Los objetivos anteriores son alcance de desarrollo, no funciones que deban darse por terminadas por aparecer en esta lista. Cada módulo debe implementarse y probarse antes de anunciarse como disponible. El modelo local requiere elegir un modelo compatible y con licencia adecuada, y validar rendimiento, memoria, batería y seguridad.

## Seguridad clínica y privacidad
Las metas deben configurarse según las indicaciones del profesional de salud. La app no diagnostica, prescribe ni modifica insulina o medicamentos. No sustituye atención médica ni servicios de emergencia. Los datos médicos requieren protección, consentimiento y pruebas de seguridad antes de usarse con información real.

