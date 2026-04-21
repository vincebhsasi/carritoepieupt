# carritoepieupt

## Auto sync Git (casi en tiempo real)

Este proyecto incluye un script para hacer commit y push automatico cada pocos segundos.

1. Configura identidad Git (una sola vez):
	- git config user.name "Tu Nombre"
	- git config user.email "tu_correo@ejemplo.com"
2. Ejecuta el auto-sync:
	- powershell -ExecutionPolicy Bypass -File .\auto_sync_git.ps1 -IntervalSeconds 8 -Branch main
3. Detenlo con Ctrl+C.

Notas:
- No es tiempo real exacto, es sincronizacion periodica.
- Si hay conflictos de merge, el script pausa la sincronizacion.