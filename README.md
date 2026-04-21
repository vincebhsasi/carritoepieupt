# carritoepieupt

## Auto sync Git (casi en tiempo real)

Este proyecto incluye un script para hacer commit y push automatico cada pocos segundos.

1. Configura identidad Git (una sola vez):
	- git config user.name "Tu Nombre"
	- git config user.email "tu_correo@ejemplo.com"
2. Ejecuta el auto-sync:
	- powershell -ExecutionPolicy Bypass -File .\auto_sync_git.ps1 -IntervalSeconds 8 -QuietSeconds 30 -MinCommitSeconds 120 -Branch main
3. Detenlo con Ctrl+C.

Notas:
- No es tiempo real exacto, es sincronizacion periodica.
- Para no saturar Git, el script espera "calma" (sin cambios nuevos) antes de commitear.
- Tambien respeta un minimo de tiempo entre commits.
- Si hay conflictos de merge, el script pausa la sincronizacion.