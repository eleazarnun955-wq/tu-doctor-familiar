# TU DOCTOR FAMILIAR 2.0

Aplicación Flutter independiente para seguimiento educativo de glucosa y acompañamiento familiar.

## Mejoras de esta etapa
- Versión de aplicación 2.0.0.
- Capa de almacenamiento cifrado AES-256-GCM con clave protegida por Android Keystore/iOS Keychain.
- Dependencias preparadas para informes PDF y apertura de fuentes institucionales.
- Se mantienen las metas personales y la interpretación educativa existentes.

## Alcance que requiere integración y validación adicional
- El cifrado debe conectarse a todos los flujos de lectura/escritura y probarse en dispositivos reales antes de introducir datos identificables.
- Perfiles familiares deben separar historiales y permisos; no se deben presentar como aislados hasta completar esa integración.
- Los recordatorios deben usar notificaciones locales y permisos explícitos; no deben considerarse activos hasta probarlos en Android.
- El modelo de IA local requiere seleccionar un modelo compatible, licencia, cuantización y pruebas de memoria, batería y seguridad. No se simula un modelo con reglas fijas.
- La búsqueda externa es opcional y debe mostrar fecha, fuente y enlace institucional.
- Videos, recetas y ejercicios individualizados requieren revisión profesional.

## Seguridad clínica
Las metas son configuradas por cada persona según su profesional de salud. La app no diagnostica, prescribe ni cambia insulina o medicamentos. Ante signos de emergencia, se debe buscar atención inmediata. No es un servicio de urgencias.

## Compilación
GitHub Actions ejecuta análisis, pruebas y compilación Android. La APK solo se considera lista cuando la ejecución y el artefacto se verifican.
