/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: tabRoot

    Layout.fillWidth: true

    property bool showAdvancedOllama: false

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Arquitectura Dual-Brain")
    }

    QQC2.ComboBox {
        id: aiBackendCombo
        Kirigami.FormData.label: i18n("Arquitectura:")
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.maximumWidth: 380
        textRole: "text"
        valueRole: "value"
        model: [
            {
                value: "hybrid",
                text: i18n("Híbrido Inteligente (Ollama + Gemini)")
            },
            {
                value: "gemini",
                text: i18n("Google Gemini (Nube)")
            },
            {
                value: "ollama",
                text: i18n("Ollama (100% Local y Privado)")
            }
        ]
        currentIndex: {
            for (let i = 0; i < model.length; ++i) {
                if (model[i].value === kcm.aiBackend) return i;
            }
            return 0;
        }
        onActivated: kcm.aiBackend = model[currentIndex].value
    }

    Kirigami.InlineMessage {
        visible: kcm.aiBackend === "hybrid"
        Layout.fillWidth: true
        Layout.maximumWidth: 540
        type: Kirigami.MessageType.Information
        text: i18n("Modo Híbrido: procesa tareas del sistema y control local con Ollama en tu equipo, y utiliza Google Gemini para consultas de conocimiento web y razonamiento avanzado.")
    }

    // --- Google Gemini Cloud Settings ---
    Kirigami.Separator {
        visible: kcm.aiBackend === "gemini" || kcm.aiBackend === "hybrid"
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Google Gemini (Nube)")
    }

    QQC2.ComboBox {
        visible: kcm.aiBackend === "gemini" || kcm.aiBackend === "hybrid"
        Kirigami.FormData.label: i18n("Modelo Gemini:")
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.maximumWidth: 380
        editable: true
        textRole: "text"
        valueRole: "value"
        model: [
            { value: "gemini-2.0-flash", text: i18n("Gemini 2.0 Flash (Recomendado)") },
            { value: "gemini-4-argon", text: i18n("Gemini 4 (Argon)") },
            { value: "gemini-2.0-pro-exp-02-05", text: i18n("Gemini 2.0 Pro") },
            { value: "gemini-1.5-pro", text: i18n("Gemini 1.5 Pro") },
            { value: "gemini-1.5-flash", text: i18n("Gemini 1.5 Flash") }
        ]
        editText: kcm.geminiModel
        currentIndex: {
            for (let i = 0; i < model.length; ++i) {
                if (model[i].value === kcm.geminiModel) return i;
            }
            return -1;
        }
        onActivated: {
            if (currentIndex >= 0 && currentIndex < model.length) {
                kcm.geminiModel = model[currentIndex].value;
            }
        }
        onAccepted: {
            if (editText.trim().length > 0) {
                kcm.geminiModel = editText.trim();
            }
        }
    }

    RowLayout {
        visible: kcm.aiBackend === "gemini" || kcm.aiBackend === "hybrid"
        Kirigami.FormData.label: i18n("Clave API Gemini:")
        Layout.fillWidth: true
        Layout.maximumWidth: 440

        QQC2.TextField {
            id: geminiKeyField
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            echoMode: showGeminiKeyBtn.checked ? TextInput.Normal : TextInput.Password
            placeholderText: kcm.googleApiKey.length > 0 ? i18n("Reutilizando clave Google Cloud de TTS") : i18n("Introduce tu clave API de Google AI Studio")
            text: kcm.geminiApiKey
            onTextEdited: kcm.geminiApiKey = text.trim()
        }

        QQC2.ToolButton {
            id: showGeminiKeyBtn
            checkable: true
            checked: false
            icon.name: checked ? "view-visible" : "view-hidden"
        }
    }

    // --- Ollama Settings ---
    Kirigami.Separator {
        visible: kcm.aiBackend === "ollama" || kcm.aiBackend === "hybrid"
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Ollama (Local)")
    }

    RowLayout {
        visible: kcm.aiBackend === "ollama" || kcm.aiBackend === "hybrid"
        Kirigami.FormData.label: i18n("Servidor Ollama:")
        Layout.fillWidth: true
        Layout.maximumWidth: 440

        QQC2.TextField {
            id: urlField
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            placeholderText: "http://127.0.0.1:11434"
            text: kcm.ollamaUrl
            onTextEdited: kcm.ollamaUrl = text.trim()
        }

        QQC2.Button {
            id: checkButton
            enabled: !kcm.ollamaChecking
            text: i18n("Comprobar")
            icon.name: "view-refresh-symbolic"
            onClicked: {
                kcm.checkReadiness();
                kcm.fetchModels();
            }
        }

        Kirigami.Icon {
            source: kcm.ollamaReachable ? "emblem-checked" : "emblem-error"
            implicitWidth: Kirigami.Units.iconSizes.small
            implicitHeight: Kirigami.Units.iconSizes.small
            QQC2.ToolTip.text: kcm.ollamaReachable ? i18n("Servidor activo") : i18n("No se puede conectar a Ollama")
            QQC2.ToolTip.visible: checkHover.hovered
            HoverHandler { id: checkHover }
        }
    }

    RowLayout {
        visible: kcm.aiBackend === "ollama" || kcm.aiBackend === "hybrid"
        Kirigami.FormData.label: i18n("Modelo principal:")
        Layout.fillWidth: true
        Layout.maximumWidth: 440

        QQC2.ComboBox {
            id: modelCombo
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            editable: true
            model: kcm.detectedModels.length > 0 ? kcm.detectedModels : ["llama3.2:3b", "mistral:7b", "llama3.1:8b", "gemma2:9b"]
            editText: kcm.ollamaModel
            currentIndex: {
                const idx = model.indexOf(kcm.ollamaModel);
                return idx >= 0 ? idx : 0;
            }
            onActivated: index => kcm.ollamaModel = model[index]
            onAccepted: {
                if (editText.trim().length > 0) {
                    kcm.ollamaModel = editText.trim();
                }
            }
        }

        QQC2.Button {
            id: refreshModelsButton
            icon.name: "view-refresh-symbolic"
            text: i18n("Actualizar")
            onClicked: kcm.fetchModels()
        }
    }

    RowLayout {
        visible: kcm.aiBackend === "ollama" || kcm.aiBackend === "hybrid"
        Kirigami.FormData.label: i18n("Temperatura:")
        Layout.fillWidth: true
        Layout.maximumWidth: 380

        QQC2.Slider {
            id: tempSlider
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            from: 0
            to: 100
            stepSize: 5
            value: Math.round(kcm.ollamaTemperature * 100)
            onMoved: kcm.ollamaTemperature = value / 100.0
        }
        QQC2.Label {
            text: kcm.ollamaTemperature <= 0.35 ? i18n("Preciso (%1)", kcm.ollamaTemperature.toFixed(2)) : i18n("Creativo (%1)", kcm.ollamaTemperature.toFixed(2))
            font.pixelSize: 11
            Layout.preferredWidth: 85
        }
    }

    ColumnLayout {
        Kirigami.FormData.label: i18n("Instrucción base:")
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        spacing: 6

        QQC2.TextArea {
            id: promptArea
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            implicitHeight: Math.max(Kirigami.Units.gridUnit * 5.5, contentHeight + topPadding + bottomPadding)
            wrapMode: TextEdit.Wrap
            text: kcm.systemPrompt
            onTextEdited: kcm.systemPrompt = text
        }

        QQC2.Button {
            icon.name: "edit-reset"
            text: i18n("Restaurar instrucción por defecto")
            onClicked: kcm.restoreDefaultPrompt()
        }
    }

    QQC2.CheckBox {
        Kirigami.FormData.label: i18n("Opciones técnicas:")
        text: i18n("Mostrar parámetros avanzados de rendimiento")
        checked: tabRoot.showAdvancedOllama
        onToggled: tabRoot.showAdvancedOllama = checked
    }

    QQC2.SpinBox {
        visible: tabRoot.showAdvancedOllama
        Kirigami.FormData.label: i18n("Ventana contexto:")
        from: 1024
        to: 65536
        stepSize: 1024
        editable: true
        value: kcm.ollamaNumCtx
        onValueModified: kcm.ollamaNumCtx = value
    }

    QQC2.SpinBox {
        visible: tabRoot.showAdvancedOllama
        Kirigami.FormData.label: i18n("Hilos de CPU:")
        from: 1
        to: 20
        stepSize: 1
        editable: true
        value: kcm.ollamaNumThread
        onValueModified: kcm.ollamaNumThread = value
    }

    QQC2.SpinBox {
        visible: tabRoot.showAdvancedOllama
        Kirigami.FormData.label: i18n("Máx tokens respuesta:")
        from: 64
        to: 4096
        stepSize: 64
        editable: true
        value: kcm.ollamaNumPredict
        onValueModified: kcm.ollamaNumPredict = value
    }

    QQC2.TextField {
        visible: tabRoot.showAdvancedOllama
        Kirigami.FormData.label: i18n("Permanencia en RAM:")
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.maximumWidth: 140
        placeholderText: "24h"
        text: kcm.ollamaKeepAlive
        onTextEdited: kcm.ollamaKeepAlive = text.trim()
    }

    RowLayout {
        visible: tabRoot.showAdvancedOllama
        Kirigami.FormData.label: i18n("Modelo de visión:")
        Layout.fillWidth: true
        Layout.maximumWidth: 440

        QQC2.ComboBox {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            editable: true
            model: kcm.detectedModels.length > 0 ? kcm.detectedModels : ["llama3.2:3b", "mistral:7b"]
            editText: kcm.ollamaVisionModel
            currentIndex: {
                const idx = model.indexOf(kcm.ollamaVisionModel);
                return idx >= 0 ? idx : 0;
            }
            onActivated: index => kcm.ollamaVisionModel = model[index]
            onAccepted: {
                if (editText.trim().length > 0) {
                    kcm.ollamaVisionModel = editText.trim();
                }
            }
        }

        QQC2.Label {
            text: i18n("Live Text OCR activo")
            color: Kirigami.Theme.positiveTextColor
            font: Kirigami.Theme.smallFont
        }
    }
}
