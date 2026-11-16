# TU DOCTOR FAMILIAR

Aplicación Flutter independiente para seguimiento educativo de glucosa y acompañamiento familiar.

## Estado del proyecto
La versión actual es una base funcional de seguimiento local: registros de glucosa, metas personales configurables, historial, resumen y reporte compartible. Los datos de esta versión se guardan en el dispositivo mediante SharedPreferences; todavía no hay cifrado de datos médicos ni sincronización segura multiusuario.

## Principios de producto
- **Local primero:** el registro y las funciones básicas deben operar sin conexión.
- **IA local sin cuotas:** el modelo se ejecutará en el dispositivo, sin API de pago ni tokens. La integración del modelo y su evaluación de seguridad son trabajo pendiente; no se simula una IA con reglas fijas.
- **Internet opcional:** ampliar información con fuentes institucionales, distinguiendo claramente contenido local de páginas externas y permitiendo compartir enlaces.
- **Seguridad clínica:** no diagnosticar, prescribir ni modificar tratamientos. Las metas son personales y deben proceder del profesional de salud.
- **Privacidad:** no subir mediciones a terceros sin consentimiento explícito. Antes de almacenar datos identificables, implementar cifrado local, control de acceso y exportación/borrado seguro.

## Compilar Android
El workflow de GitHub Actions compila el APK de release y lo publica como artefacto de la ejecución. La APK solo se considera lista después de que la ejecución termine correctamente y el artefacto se verifique.

## Próximas etapas
1. Cifrado local, PIN/biometría y exportación/importación cifrada.
2. Integrar un modelo pequeño cuantizado en el dispositivo y medir RAM, latencia, batería y precisión; sin conexión ni servicios de pago.
3. Interfaz de búsqueda web opcional con fuentes institucionales, fecha de consulta y enlaces compartibles.
4. Recordatorios locales configurables con permisos claros.
5. Perfiles de familiares con consentimiento y separación de datos.
6. Revisión clínica y regulatoria en México antes de distribuir funciones que puedan considerarse software como dispositivo médico.

Esta aplicación es educativa y de seguimiento. No es un servicio de urgencias ni sustituye a profesionales de salud.
