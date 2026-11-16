# TU DOCTOR FAMILIAR 7.0

Versión Android independiente construida desde la versión funcional 6.0. V6.0 permanece intacta; V7.0 usa un identificador de paquete distinto para instalar ambas aplicaciones en el mismo teléfono.

## Identidad y compilación
- Rama: `doctor-familiar-7.0`.
- Versión Flutter: `7.0.0+1`.
- Android applicationId: `com.tudoctorfamiliar.v7.tu_doctor_familiar`.
- Artefacto: `TU-DOCTOR-FAMILIAR-7.0-Android`.
- La APK solo se considera lista cuando GitHub Actions termina correctamente y el artefacto puede descargarse y verificarse.

## Funciones incluidas y heredadas
- Registro de glucosa con metas personales, contexto, voz a texto editable, historial y gráficas.
- Cerebro local transparente basado en reglas; funciona sin conexión y no diagnostica ni modifica tratamientos.
- Perfiles familiares adicionales y registros separados por paciente.
- Expediente con presión arterial, pulso, peso, estatura, cintura, síntomas, medicamentos y resultados de laboratorio.
- Registro de tomas anotadas, recordatorios locales, alimentación y actividad física.
- Informes PDF, respaldo/restauración validada y almacenamiento local cifrado AES-256-GCM.
- Agenda médica para consultas, estudios y revisiones con avisos locales cuando Android concede permisos.
- Sección educativa con enlaces a videos y guías en español para aprender la técnica de inyección de insulina.

## Recursos educativos sobre insulina
- Asociación Mexicana de Diabetes: https://www.youtube.com/watch?v=h9lPncyzePQ
- Campus Sanofi: https://pro.campus.sanofi/es/otras-tematicas-diabetes/recursos/videos-sobre-el-manejo-y-administracion-de-la-insulina
- Sociedad Española de Diabetes: https://www.sediabetes.org/pacientes/materiales/video-tecnica-de-inyeccion-de-insulina/
- IMSS, guía de insulinización: https://educacionensalud.imss.gob.mx/modelopreventivo/infografias/material_complementario/PDF-Tutorial-Insulinizacion.pdf

## Datos, privacidad y seguridad
Los registros se guardan cifrados localmente en el dispositivo; no hay sincronización automática en la nube. Los respaldos exportados contienen información médica sensible y deben conservarse de forma privada. Usa el bloqueo del teléfono y no compartas expedientes sin consentimiento. No se agregan identificadores personales innecesarios.

## Seguridad clínica
La app es educativa y de seguimiento. No diagnostica, prescribe, calcula dosis ni modifica insulina o medicamentos. Los videos son material general: la técnica correcta depende del tipo de insulina y del dispositivo (pluma o jeringa); confirma el procedimiento con el médico o educador en diabetes y sigue las instrucciones del fabricante. Nunca uses los videos para decidir una dosis. Ante una emergencia, busca atención médica inmediata.

## Validación
GitHub Actions ejecuta `dart analyze`, `flutter test` y `flutter build apk --release`. La compilación no sustituye la prueba funcional en un teléfono Android real.
