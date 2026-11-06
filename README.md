# KCM Kity — Módulo de Preferencias del Sistema de Plasma

Módulo nativo de configuración (**KCM**) para **Kity**, el asistente de inteligencia artificial y voz estilo Siri para **KDE Plasma 6** en CachyOS Linux.

Aparece integrado en **Preferencias del Sistema** (*System Settings*) en la categoría **Aplicaciones**, o puede ejecutarse de forma independiente con:

```bash
systemsettings kcm_kity
# o directamente:
kcmshell6 kcm_kity
```

## Características

- **🎙️ Voz y Escucha Activa**: Configuración de «¡Hola Kity!» en segundo plano, modos de respuesta de voz, avisos acústicos Siri, detección de silencio VAD, selección de modelos Whisper GGML (`.bin`) y voces neuronales Piper TTS (`.onnx`).
- **🧠 Inteligencia Artificial Local (Ollama)**: Verificación de estado en tiempo real, selector dinámico de modelos de lenguaje (`llama3.2:3b`, `mistral:7b`, `llama3.1:8b`, `gemma2:9b`), control de temperatura, editor de instrucciones del sistema (*System Prompt*) y parámetros avanzados optimizados para Intel Core i5-13600K (hilos, tokens, permanencia de memoria RAM `24h`).
- **📚 Base de Conocimiento Local (RAG)**: Integración con notas privadas en `~/.local/share/kity/knowledge/` con acceso directo a Dolphin.
- **📮 Servicios y Productividad**: Selección de cliente de correo (Proton Mail, Gmail, Sistema) y calendario (Proton Calendar, Google Calendar).
- **🪟 Ventana y Apariencia**: Estilo de icono en panel (simbólico/color) y anclaje de ventana.
- **⚡ Recarga en vivo**: Sincronización instantánea en `~/.config/kityrc` y notificación por D-Bus a la aplicación Kity en ejecución.

## Compilación e Instalación

### Requisitos

- KDE Plasma 6 / KF6 (`kcmutils`, `kconfig`, `kcoreaddons`, `ki18n`)
- Qt 6 (Core, DBus, Gui, Network, Quick)
- Extra CMake Modules (`ECM`)

### Pasos

```bash
cmake -B build -S . -DCMAKE_INSTALL_PREFIX=$HOME/.local -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cmake --install build
```

## Licencia

GPL-3.0-or-later.
