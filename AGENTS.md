# Reglas y Directrices de Desarrollo - KCM Kity

## 1. Política Estricta de Instalación: ÚNICAMENTE `/usr`

> [!IMPORTANT]
> **NUNCA instalar ni duplicar archivos en `~/.local`**.
> La instalación de KCM Kity y todos sus componentes asociados (módulo de ajustes, archivos `.desktop`, iconos) **DEBE realizarse EXCLUSIVAMENTE en `/usr`**.

- **Comando de instalación autorizado**:
  ```bash
  sudo -n cmake --install build --prefix /usr
  ```
- **Prohibido**:
  - `cmake --install build --prefix ~/.local`
  - Copiar librerías `.so` o archivos `.desktop` a `~/.local`.
- **Motivo**: Duplicar en `~/.local` y `/usr` provoca sombreado (*shadowing*) de bibliotecas en Qt6/KDE, desincronización de versiones e inconsistencias en `systemsettings`.
