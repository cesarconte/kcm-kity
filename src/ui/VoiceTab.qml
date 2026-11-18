/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs as QtDialogs

import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: tabRoot

    Layout.fillWidth: true

    readonly property var speechModes: [
        { "value": "always", "text": i18n("Hablar siempre en voz alta") },
        { "value": "voice_only", "text": i18n("Solo al preguntar por voz") },
        { "value": "manual", "text": i18n("Solo manual (pulsar altavoz)") }
    ]

    readonly property var chromaticOrbColors: ["#30D158", "#FFD60A", "#FF9F0A", "#FF375F", "#BF5AF2", "#5E5CE6", "#64D2FF"]

    QtDialogs.FileDialog {
        id: whisperFileDialog
        title: i18n("Seleccionar modelo Whisper GGML (.bin)")
        nameFilters: [i18n("Modelos Whisper GGML (*.bin)"), i18n("Todos los archivos (*)")]
        currentFolder: StandardPaths.writableLocation(StandardPaths.GenericDataLocation) + "/kity/models"
        onAccepted: {
            kcm.whisperModelPath = selectedFile.toString().replace(/^file:\/\//, "");
        }
    }

    QtDialogs.FileDialog {
        id: piperFileDialog
        title: i18n("Seleccionar voz neuronal Piper (.onnx)")
        nameFilters: [i18n("Modelos Piper ONNX (*.onnx)"), i18n("Todos los archivos (*)")]
        currentFolder: StandardPaths.writableLocation(StandardPaths.GenericDataLocation) + "/kity/voices"
        onAccepted: {
            kcm.piperVoicePath = selectedFile.toString().replace(/^file:\/\//, "");
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Activación y Escucha")
    }

    QQC2.CheckBox {
        Kirigami.FormData.label: i18n("Activación:")
        text: i18n("Escuchar «¡Hola Kity!» en segundo plano")
        checked: kcm.wakeWordEnabled
        onToggled: kcm.wakeWordEnabled = checked
    }

    QQC2.CheckBox {
        Kirigami.FormData.label: i18n("Al abrir ventana:")
        text: i18n("Empezar a escuchar por micrófono automáticamente")
        checked: kcm.autoListenOnActivate
        onToggled: kcm.autoListenOnActivate = checked
    }

    QQC2.CheckBox {
        id: vadCheck
        Kirigami.FormData.label: i18n("Detección de voz (VAD):")
        text: i18n("Detener grabación automáticamente al terminar de hablar")
        checked: kcm.vadEnabled
        onToggled: kcm.vadEnabled = checked
    }

    QQC2.SpinBox {
        Kirigami.FormData.label: i18n("Silencio para corte:")
        from: 400
        to: 4000
        stepSize: 100
        editable: true
        enabled: vadCheck.checked
        value: kcm.vadSilenceTimeoutMs
        textFromValue: (value, locale) => value + " ms"
        valueFromText: (text, locale) => parseInt(text) || 1300
        onValueModified: kcm.vadSilenceTimeoutMs = value
    }

    QQC2.CheckBox {
        Kirigami.FormData.label: i18n("Conversación continua:")
        text: i18n("Esperar una nueva pregunta tras responder por voz")
        checked: kcm.continuousConversation
        onToggled: kcm.continuousConversation = checked
    }

    QQC2.CheckBox {
        Kirigami.FormData.label: i18n("Avisos acústicos:")
        text: i18n("Reproducir tono armónico al iniciar/finalizar escucha")
        checked: kcm.earconsEnabled
        onToggled: kcm.earconsEnabled = checked
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: i18n("Respuestas habladas:")
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.maximumWidth: 320
        model: tabRoot.speechModes
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < tabRoot.speechModes.length; ++i) {
                if (tabRoot.speechModes[i].value === kcm.speechOutputMode) return i;
            }
            return 0;
        }
        onActivated: index => kcm.speechOutputMode = tabRoot.speechModes[index].value
    }

    QQC2.CheckBox {
        Kirigami.FormData.label: i18n("Voz centralizada:")
        text: i18n("Usar KDictation vía D-Bus (máximo rendimiento y estabilidad)")
        checked: kcm.useCentralizedVoice
        onToggled: kcm.useCentralizedVoice = checked
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Personalización de la Voz")
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: i18n("Acento (Variante):")
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.maximumWidth: 320
        model: ["Spanish (Spain)", "Spanish (Latin America)", "American", "British"]
        currentIndex: Math.max(0, model.indexOf(kcm.voiceAccent))
        onActivated: index => {
            kcm.voiceAccent = model[index];
            kcm.previewVoice();
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Voz (1–7):")
        spacing: 8

        Repeater {
            model: tabRoot.chromaticOrbColors

            Item {
                id: orbItem
                required property string modelData
                required property int index
                width: 28
                height: 28
                readonly property bool isSel: kcm.voiceIndex === index

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.isSel ? 32 : 26
                    height: parent.isSel ? 32 : 26
                    radius: width / 2
                    color: "transparent"
                    border.width: parent.isSel ? 2 : 0
                    border.color: parent.modelData
                    opacity: parent.isSel ? 1.0 : 0.0

                    Behavior on width { NumberAnimation { duration: 140 } }
                    Behavior on height { NumberAnimation { duration: 140 } }
                    Behavior on opacity { NumberAnimation { duration: 140 } }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.isSel ? 22 : 20
                    height: parent.isSel ? 22 : 20
                    radius: width / 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.lighter(orbItem.modelData, 1.4) }
                        GradientStop { position: 0.7; color: orbItem.modelData }
                        GradientStop { position: 1.0; color: Qt.darker(orbItem.modelData, 1.25) }
                    }
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.45)
                    scale: orbArea.pressed ? 0.90 : (orbArea.containsMouse ? 1.12 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    QQC2.Label {
                        anchors.centerIn: parent
                        text: (orbItem.index + 1).toString()
                        color: "#FFFFFF"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }

                MouseArea {
                    id: orbArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        kcm.voiceIndex = orbItem.index;
                        kcm.previewVoice();
                    }
                }
            }
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Muestra de voz:")
        spacing: 12

        QQC2.Button {
            icon.name: "media-playback-start"
            text: i18n("Escuchar voz %1", kcm.voiceIndex + 1)
            onClicked: kcm.previewVoice()
        }

        QQC2.Label {
            text: i18n("(%1, %2)", kcm.voiceAccent, (0.65 + kcm.voicePace * 0.75).toFixed(2) + "x")
            font.pixelSize: 11
            opacity: 0.75
        }
    }

    ColumnLayout {
        Kirigami.FormData.label: i18n("Ritmo (Pace):")
        Layout.fillWidth: true
        Layout.maximumWidth: 360
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            QQC2.Slider {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                from: 0.0
                to: 1.0
                value: kcm.voicePace
                onMoved: kcm.voicePace = value
                onPressedChanged: {
                    if (!pressed) kcm.previewVoice();
                }
            }
            QQC2.Label {
                text: (0.65 + kcm.voicePace * 0.75).toFixed(2) + "x"
                font.bold: true
                Layout.preferredWidth: 38
            }
        }
    }

    ColumnLayout {
        Kirigami.FormData.label: i18n("Expresividad:")
        Layout.fillWidth: true
        Layout.maximumWidth: 360
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            QQC2.Slider {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                from: 0.0
                to: 1.0
                value: kcm.voiceExpressivity
                onMoved: kcm.voiceExpressivity = value
                onPressedChanged: {
                    if (!pressed) kcm.previewVoice();
                }
            }
            QQC2.Label {
                text: Math.round(kcm.voiceExpressivity * 100) + "%"
                font.bold: true
                Layout.preferredWidth: 38
            }
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Motores de Reconocimiento y Síntesis")
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: i18n("Entrada de voz (STT):")
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.maximumWidth: 360
        model: [
            { text: i18n("Google Gemini 2.0 (Nube — Alta precisión)"), value: "gemini" },
            { text: i18n("Whisper.cpp (Local / Offline)"), value: "whisper" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < model.length; ++i) {
                if (model[i].value === kcm.sttEngine) return i;
            }
            return 0;
        }
        onActivated: kcm.sttEngine = model[currentIndex].value
    }

    ColumnLayout {
        visible: kcm.sttEngine === "whisper"
        Layout.fillWidth: true
        Layout.maximumWidth: 460
        spacing: 6

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Modelo Whisper:")
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            model: [
                { text: i18n("Whisper Small (466 MB — Recomendado)"), value: "/home/cesar/.local/share/kity/models/ggml-small.bin" },
                { text: i18n("Whisper Base (142 MB — Ligero)"), value: "/home/cesar/.local/share/kity/models/ggml-base.bin" },
                { text: i18n("Personalizado…"), value: "custom" }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                if (kcm.whisperModelPath.indexOf("small") !== -1 || kcm.whisperModelPath === "") return 0;
                if (kcm.whisperModelPath.indexOf("base") !== -1) return 1;
                return 2;
            }
            onActivated: {
                let val = model[currentIndex].value;
                if (val !== "custom") kcm.whisperModelPath = val;
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            QQC2.TextField {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                placeholderText: i18n("Ruta al archivo .bin")
                text: kcm.whisperModelPath
                onTextEdited: kcm.whisperModelPath = text.trim()
            }

            QQC2.Button {
                icon.name: "document-open"
                text: i18n("Examinar…")
                onClicked: whisperFileDialog.open()
            }

            Kirigami.Icon {
                source: kcm.whisperFound ? "emblem-checked" : "emblem-warning"
                implicitWidth: Kirigami.Units.iconSizes.small
                implicitHeight: Kirigami.Units.iconSizes.small
                QQC2.ToolTip.text: kcm.whisperFound ? i18n("Modelo listo") : i18n("Modelo no encontrado")
                QQC2.ToolTip.visible: whisperStatusHover.hovered
                HoverHandler { id: whisperStatusHover }
            }
        }
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: i18n("Salida de voz (TTS):")
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.maximumWidth: 360
        model: [
            { text: i18n("Google Cloud TTS (Nube)"), value: "google" },
            { text: i18n("Microsoft Edge Neural (Nube gratuita)"), value: "edge" },
            { text: i18n("Kokoro-82M (Local / Offline)"), value: "kokoro" },
            { text: i18n("Piper TTS (Local / Offline)"), value: "piper" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < model.length; ++i) {
                if (model[i].value === kcm.ttsEngine) return i;
            }
            return 0;
        }
        onActivated: kcm.ttsEngine = model[currentIndex].value
    }

    // --- Google Cloud TTS ---
    RowLayout {
        visible: kcm.ttsEngine === "google"
        Kirigami.FormData.label: i18n("Clave Google Cloud:")
        Layout.fillWidth: true
        Layout.maximumWidth: 420

        QQC2.TextField {
            id: googleKeyField
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            echoMode: showGoogleKeyBtn.checked ? TextInput.Normal : TextInput.Password
            placeholderText: i18n("Introduce tu API Key de Google Cloud TTS")
            text: kcm.googleApiKey
            onTextEdited: kcm.googleApiKey = text.trim()
        }

        QQC2.ToolButton {
            id: showGoogleKeyBtn
            checkable: true
            checked: false
            icon.name: checked ? "view-visible" : "view-hidden"
        }
    }

    QQC2.ComboBox {
        visible: kcm.ttsEngine === "google"
        Kirigami.FormData.label: i18n("Voz Google Cloud:")
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.maximumWidth: 360
        model: [
            { text: i18n("es-ES-Neural2-F (Femenina — Por defecto)"), value: "es-ES-Neural2-F" },
            { text: i18n("es-ES-Journey-F (Femenina — Conversacional)"), value: "es-ES-Journey-F" },
            { text: i18n("es-ES-Studio-C (Femenina — Calidad de estudio)"), value: "es-ES-Studio-C" },
            { text: i18n("es-ES-Neural2-A (Femenina — Variante clara)"), value: "es-ES-Neural2-A" },
            { text: i18n("es-ES-Neural2-B (Masculina)"), value: "es-ES-Neural2-B" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < model.length; ++i) {
                if (model[i].value === kcm.googleVoice) return i;
            }
            return 0;
        }
        onActivated: kcm.googleVoice = model[currentIndex].value
    }

    // --- Microsoft Edge Neural TTS ---
    QQC2.ComboBox {
        visible: kcm.ttsEngine === "edge"
        Kirigami.FormData.label: i18n("Voz Edge Neural:")
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.maximumWidth: 360
        model: [
            { text: i18n("es-ES-ElviraNeural (Femenina)"), value: "es-ES-ElviraNeural" },
            { text: i18n("es-ES-XimenaNeural (Femenina)"), value: "es-ES-XimenaNeural" },
            { text: i18n("es-ES-AlvaroNeural (Masculina)"), value: "es-ES-AlvaroNeural" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < model.length; ++i) {
                if (model[i].value === kcm.edgeVoice) return i;
            }
            return 0;
        }
        onActivated: kcm.edgeVoice = model[currentIndex].value
    }

    // --- Kokoro-82M ---
    QQC2.ComboBox {
        visible: kcm.ttsEngine === "kokoro"
        Kirigami.FormData.label: i18n("Voz Kokoro-82M:")
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.maximumWidth: 360
        model: [
            { text: i18n("ef_dora (Femenina)"), value: "ef_dora" },
            { text: i18n("em_alex (Masculina)"), value: "em_alex" },
            { text: i18n("em_santa (Masculina)"), value: "em_santa" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < model.length; ++i) {
                if (model[i].value === kcm.kokoroVoice) return i;
            }
            return 0;
        }
        onActivated: kcm.kokoroVoice = model[currentIndex].value
    }

    // --- Piper TTS ---
    RowLayout {
        visible: kcm.ttsEngine === "piper"
        Kirigami.FormData.label: i18n("Voz Piper (.onnx):")
        Layout.fillWidth: true
        Layout.maximumWidth: 460
        spacing: 6

        QQC2.TextField {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            placeholderText: i18n("Ruta al archivo .onnx")
            text: kcm.piperVoicePath
            onTextEdited: kcm.piperVoicePath = text.trim()
        }

        QQC2.Button {
            icon.name: "document-open"
            text: i18n("Examinar…")
            onClicked: piperFileDialog.open()
        }

        Kirigami.Icon {
            source: kcm.piperFound ? "emblem-checked" : "emblem-warning"
            implicitWidth: Kirigami.Units.iconSizes.small
            implicitHeight: Kirigami.Units.iconSizes.small
            QQC2.ToolTip.text: kcm.piperFound ? i18n("Voz lista") : i18n("Archivo no encontrado")
            QQC2.ToolTip.visible: piperStatusHover.hovered
            HoverHandler { id: piperStatusHover }
        }
    }
}
