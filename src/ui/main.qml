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

import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

KCMUtils.SimpleKCM {
    id: root

    readonly property var speechModes: [
        { "value": "always", "text": i18n("Hablar siempre en voz alta (Recomendado)") },
        { "value": "voice_only", "text": i18n("Solo cuando preguntes por voz") },
        { "value": "manual", "text": i18n("Solo manual (al pulsar el altavoz del mensaje)") }
    ]

    readonly property var iconStyles: [
        { "value": "symbolic", "text": i18n("Simbólico monocromo (Breeze, recomendado)") },
        { "value": "color", "text": i18n("Color completo (Degradado Kity)") }
    ]

    readonly property var emailClients: [
        { "value": "proton", "text": i18n("Proton Mail (Aplicación de escritorio / Web)") },
        { "value": "gmail", "text": i18n("Google Gmail (Navegador web)") },
        { "value": "system", "text": i18n("Cliente de correo predeterminado del sistema") }
    ]

    readonly property var calendarClients: [
        { "value": "korganizer", "text": i18n("KOrganizer (Google Calendar)") },
        { "value": "google", "text": i18n("Google Calendar (Navegador web)") },
        { "value": "proton", "text": i18n("Proton Calendar (Aplicación / Web)") }
    ]

    property bool showAdvancedOllama: false
    property int selectedVoiceOrb: 3
    property real voicePaceVal: 0.68
    property real voiceExpressivityVal: 0.88
    property real kcmAnimTime: 0.0

    readonly property var chromaticOrbColors: ["#30D158", "#FFD60A", "#FF9F0A", "#FF375F", "#BF5AF2", "#5E5CE6", "#64D2FF"]
    readonly property color selectedOrbColor: chromaticOrbColors[Math.max(0, Math.min(6, kcm.voiceIndex))]

    NumberAnimation on kcmAnimTime {
        from: 0.0
        to: 1000.0
        duration: 1000000
        loops: Animation.Infinite
        running: true
    }

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

    Kirigami.FormLayout {
        // =====================================================================
        // 0A. macOS 27 Golden Gate: Activar Kity / Kity AI (beta)
        // Replicates media_1794404303929_e7675d47.png & Apple Guide mchl3fd7fc15
        // =====================================================================
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Kity y Kity AI — macOS Golden Gate")
        }

        Rectangle {
            Kirigami.FormData.label: i18n("Estado de Kity:")
            Layout.fillWidth: true
            implicitHeight: siriHeroCol.implicitHeight + 24
            radius: 12
            color: Qt.rgba(0.10, 0.11, 0.16, 0.85)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.16)

            ColumnLayout {
                id: siriHeroCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        radius: 21
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#FF375F" }
                            GradientStop { position: 0.5; color: "#BF5AF2" }
                            GradientStop { position: 1.0; color: "#5E5CE6" }
                        }

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: 22
                            height: 22
                            source: "audio-input-microphone-symbolic"
                            isMask: true
                            color: "#FFFFFF"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        QQC2.Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            font.bold: true
                            color: "#FFFFFF"
                            text: kcm.siriMode === "ai"
                                ? i18n("Kity AI (beta) activado")
                                : (kcm.siriMode === "classic" ? i18n("Kity (versión clásica) activado") : i18n("Kity está desactivado"))
                        }

                        QQC2.Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            font.pixelSize: 12
                            color: Qt.rgba(1, 1, 1, 0.72)
                            text: i18n("Kity te ayuda con tus tareas diarias y te responde al instante. En macOS Golden Gate puedes elegir entre la nueva experiencia conversacional Kity AI o Kity clásico.")
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    QQC2.Button {
                        Layout.fillWidth: true
                        highlighted: kcm.siriMode === "ai"
                        text: i18n("Probar Kity AI (beta)")
                        onClicked: kcm.siriMode = "ai"
                    }

                    QQC2.Button {
                        Layout.fillWidth: true
                        highlighted: kcm.siriMode === "classic"
                        text: i18n("Usar Kity (versión clásica)")
                        onClicked: kcm.siriMode = "classic"
                    }

                    QQC2.Button {
                        highlighted: kcm.siriMode === "off"
                        text: i18n("Desactivar")
                        onClicked: kcm.siriMode = "off"
                    }
                }
            }
        }

        QQC2.Label {
            Kirigami.FormData.label: i18n("Atajo de teclado:")
            text: i18n("Meta + K (Píldora Rápida «Search or Ask»)")
            font.bold: true
        }

        // =====================================================================
        // 0B. Personalizar la voz de Kity ("Guided by voices" - 10b_siri_voice_window.png)
        // =====================================================================
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Personalizar la voz de Kity (Voz, Variante, Ritmo y Expresividad)")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Vista previa acústica:")
            Layout.fillWidth: true
            spacing: 16

            Rectangle {
                id: previewBox
                Layout.preferredWidth: 220
                Layout.preferredHeight: 116
                radius: 14
                color: "#08080C"
                border.width: 1
                border.color: Qt.rgba(root.selectedOrbColor.r, root.selectedOrbColor.g, root.selectedOrbColor.b, previewArea.containsMouse ? 0.75 : 0.35)
                clip: true
                scale: previewArea.pressed ? 0.95 : (previewArea.containsMouse ? 1.02 : 1.0)

                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                // Ambient chromatic backdrop glow
                Rectangle {
                    anchors.centerIn: parent
                    width: 130
                    height: 80
                    radius: 40
                    color: root.selectedOrbColor
                    opacity: 0.14 + 0.08 * Math.sin(root.kcmAnimTime * 2.5)
                }

                Repeater {
                    model: 4
                    Rectangle {
                        required property int index
                        anchors.centerIn: parent
                        readonly property real waveScale: 1.0 + 0.14 * Math.sin(root.kcmAnimTime * 3.0 - index * 0.85)
                        width: (38 + index * 22) * waveScale
                        height: (38 + index * 22) * waveScale
                        radius: width * 0.42
                        rotation: index * 25.0 + root.kcmAnimTime * 14
                        color: "transparent"
                        border.width: 1.4
                        border.color: Qt.rgba(root.selectedOrbColor.r, root.selectedOrbColor.g, root.selectedOrbColor.b, (0.35 - index * 0.07) * (0.5 + kcm.voiceExpressivity * 0.5))
                    }
                }

                // Central Liquid Glass Siri Sphere
                Rectangle {
                    anchors.centerIn: parent
                    width: 42
                    height: 42
                    radius: 21
                    scale: previewArea.pressed ? 0.86 : (previewArea.containsMouse ? 1.10 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.lighter(root.selectedOrbColor, 1.45) }
                        GradientStop { position: 0.65; color: root.selectedOrbColor }
                        GradientStop { position: 1.0; color: Qt.darker(root.selectedOrbColor, 1.35) }
                    }
                    border.width: 1.5
                    border.color: Qt.rgba(1, 1, 1, 0.65)

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        source: "media-playback-start"
                        width: 16
                        height: 16
                        color: "#FFFFFF"
                    }
                }

                MouseArea {
                    id: previewArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: kcm.previewVoice()
                }

                QQC2.ToolTip.text: i18n("Haz clic para escuchar la voz seleccionada")
                QQC2.ToolTip.visible: previewArea.containsMouse
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                QQC2.Label {
                    text: i18n("Voz %1 (%2)", kcm.voiceIndex + 1, kcm.voiceAccent)
                    font.weight: Font.DemiBold
                    font.pixelSize: 13
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    opacity: 0.78
                    text: i18n("Pulsa sobre el orbe central o selecciona una de las 7 variantes cromáticas abajo para escuchar en directo la cadencia y expresividad ajustadas.")
                }

                QQC2.Button {
                    icon.name: "media-playback-start"
                    text: i18n("Escuchar muestra de voz")
                    onClicked: kcm.previewVoice()
                }
            }
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Variante (Acento):")
            Layout.fillWidth: true
            model: ["Spanish (Spain)", "Spanish (Latin America)", "American", "British"]
            currentIndex: Math.max(0, model.indexOf(kcm.voiceAccent))
            onActivated: index => {
                kcm.voiceAccent = model[index];
                kcm.previewVoice();
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Voz (1–7):")
            spacing: 12

            Repeater {
                model: root.chromaticOrbColors

                Item {
                    id: orbItem
                    required property string modelData
                    required property int index
                    width: 32
                    height: 32
                    readonly property bool isSel: kcm.voiceIndex === index

                    // Selection glowing aura
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.isSel ? 36 : 30
                        height: parent.isSel ? 36 : 30
                        radius: width / 2
                        color: "transparent"
                        border.width: parent.isSel ? 2.5 : 0
                        border.color: parent.modelData
                        opacity: parent.isSel ? 1.0 : 0.0

                        Behavior on width { NumberAnimation { duration: 160 } }
                        Behavior on height { NumberAnimation { duration: 160 } }
                        Behavior on opacity { NumberAnimation { duration: 160 } }
                    }

                    // Sphere Orb Body with 3D Radial Highlight
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.isSel ? 26 : 24
                        height: parent.isSel ? 26 : 24
                        radius: width / 2
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.lighter(orbItem.modelData, 1.4) }
                            GradientStop { position: 0.7; color: orbItem.modelData }
                            GradientStop { position: 1.0; color: Qt.darker(orbItem.modelData, 1.25) }
                        }
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.45)
                        scale: orbArea.pressed ? 0.90 : (orbArea.containsMouse ? 1.15 : 1.0)

                        Behavior on scale { NumberAnimation { duration: 120 } }

                        QQC2.Label {
                            anchors.centerIn: parent
                            text: (orbItem.index + 1).toString()
                            color: "#FFFFFF"
                            font.pixelSize: 11
                            font.bold: true
                            style: Text.Outline
                            styleColor: Qt.rgba(0, 0, 0, 0.45)
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

        ColumnLayout {
            Kirigami.FormData.label: i18n("Ritmo (Pace):")
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                QQC2.Slider {
                    Layout.fillWidth: true
                    from: 0.0
                    to: 1.0
                    value: kcm.voicePace
                    onMoved: kcm.voicePace = value
                }
                QQC2.Label {
                    text: (0.65 + kcm.voicePace * 0.75).toFixed(2) + "x"
                    font.bold: true
                    Layout.preferredWidth: 42
                }
            }
            RowLayout {
                Layout.fillWidth: true
                QQC2.Label { text: i18n("Lento"); font.pixelSize: 10; opacity: 0.6 }
                Item { Layout.fillWidth: true }
                QQC2.Label { text: i18n("Normal"); font.pixelSize: 10; opacity: 0.6 }
                Item { Layout.fillWidth: true }
                QQC2.Label { text: i18n("Rápido"); font.pixelSize: 10; opacity: 0.6 }
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Expresividad (Expressivity):")
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                QQC2.Slider {
                    Layout.fillWidth: true
                    from: 0.0
                    to: 1.0
                    value: kcm.voiceExpressivity
                    onMoved: kcm.voiceExpressivity = value
                }
                QQC2.Label {
                    text: Math.round(kcm.voiceExpressivity * 100) + "%"
                    font.bold: true
                    Layout.preferredWidth: 42
                }
            }
            RowLayout {
                Layout.fillWidth: true
                QQC2.Label { text: i18n("Sereno"); font.pixelSize: 10; opacity: 0.6 }
                Item { Layout.fillWidth: true }
                QQC2.Label { text: i18n("Equilibrado"); font.pixelSize: 10; opacity: 0.6 }
                Item { Layout.fillWidth: true }
                QQC2.Label { text: i18n("Muy dinámico"); font.pixelSize: 10; opacity: 0.6 }
            }
        }

        // =====================================================================
        // 0C. Ajustes de la app Kity (Apple Guide q7ny3g54v9lk & mchl3fd7fc15)
        // =====================================================================
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("App Kity (Conversaciones e Historial)")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Se abre en:")
            Layout.fillWidth: true
            model: [
                { value: "past", text: i18n("Conversaciones recientes") },
                { value: "new", text: i18n("Nueva conversación") }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: kcm.openToMode === "new" ? 1 : 0
            onActivated: index => kcm.openToMode = (index === 1 ? "new" : "past")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Conservar las conversaciones:")
            Layout.fillWidth: true
            model: [
                { value: "forever", text: i18n("Siempre") },
                { value: "1year", text: i18n("1 año") },
                { value: "30days", text: i18n("30 días") }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: kcm.historyRetention === "1year" ? 1 : (kcm.historyRetention === "30days" ? 2 : 0)
            onActivated: index => kcm.historyRetention = (index === 1 ? "1year" : (index === 2 ? "30days" : "forever"))
            QQC2.ToolTip.text: i18n("Si eliges «30 días» o «1 año», las conversaciones más antiguas se eliminarán definitivamente.")
            QQC2.ToolTip.visible: hovered
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Previsualizar (barra lateral):")
            Layout.fillWidth: true
            model: [
                { value: 2, text: i18n("2 líneas") },
                { value: 4, text: i18n("4 líneas (Recomendado)") },
                { value: 6, text: i18n("6 líneas") }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: kcm.previewLines <= 2 ? 0 : (kcm.previewLines >= 6 ? 2 : 1)
            onActivated: index => kcm.previewLines = (index === 0 ? 2 : (index === 2 ? 6 : 4))
        }

        // =====================================================================
        // 0D. Inteligencia Visual, Peticiones y Sugerencias (mchl3fd7fc15)
        // =====================================================================
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Respuestas, Buscador Visual y Sugerencias")
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Transcripción:")
            text: i18n("Mostrar siempre la petición (muestra el texto de lo que dices en pantalla)")
            checked: kcm.alwaysShowRequest
            onToggled: kcm.alwaysShowRequest = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Buscador visual automático:")
            text: i18n("Identificar automáticamente objetos, texto y lugares en capturas de pantalla")
            checked: kcm.autoVisualLookup
            onToggled: kcm.autoVisualLookup = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Extensión en la nube:")
            text: i18n("Confirmar peticiones antes de enviar consultas complejas a la nube (Gemini)")
            checked: kcm.confirmCloudRequests
            onToggled: kcm.confirmCloudRequests = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Sugerencias de Kity:")
            text: i18n("Permitir sugerencias contextuales de Kity en aplicaciones")
            checked: kcm.suggestionsEnabled
            onToggled: kcm.suggestionsEnabled = checked
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Apps excluidas:")
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                QQC2.TextField {
                    id: excludedAppInput
                    Layout.fillWidth: true
                    placeholderText: i18n("Nombre de aplicación a excluir de Kity…")
                    onAccepted: {
                        if (text.trim().length > 0) {
                            kcm.addExcludedApp(text.trim());
                            text = "";
                        }
                    }
                }

                QQC2.Button {
                    icon.name: "list-add"
                    text: i18n("Añadir app…")
                    onClicked: {
                        if (excludedAppInput.text.trim().length > 0) {
                            kcm.addExcludedApp(excludedAppInput.text.trim());
                            excludedAppInput.text = "";
                        }
                    }
                }
            }

            Flow {
                Layout.fillWidth: true
                spacing: 6
                visible: kcm.excludedApps.length > 0

                Repeater {
                    model: kcm.excludedApps

                    Rectangle {
                        required property string modelData
                        height: 26
                        width: exclRow.implicitWidth + 14
                        radius: 13
                        color: Qt.rgba(1, 1, 1, 0.10)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.20)

                        RowLayout {
                            id: exclRow
                            anchors.centerIn: parent
                            spacing: 6

                            QQC2.Label {
                                text: modelData
                                font.pixelSize: 12
                            }

                            QQC2.ToolButton {
                                text: "✕"
                                implicitWidth: 18
                                implicitHeight: 18
                                onClicked: kcm.removeExcludedApp(modelData)
                            }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // 1. Voz y Escucha Activa («¡Hola Kity!»)
        // =====================================================================
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Voz y Escucha Activa («¡Hola Kity!»)")
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Activación por voz:")
            text: i18n("Escuchar «¡Hola Kity!» u «Oye Kity» en segundo plano")
            checked: kcm.wakeWordEnabled
            onToggled: kcm.wakeWordEnabled = checked
            QQC2.ToolTip.text: i18n("Permite invocar a Kity con la voz en cualquier momento de manera manos libres")
            QQC2.ToolTip.visible: hovered
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Respuestas habladas:")
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            model: root.speechModes
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                for (let i = 0; i < root.speechModes.length; ++i) {
                    if (root.speechModes[i].value === kcm.speechOutputMode) return i;
                }
                return 0;
            }
            onActivated: index => {
                kcm.speechOutputMode = root.speechModes[index].value;
            }
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Avisos acústicos:")
            text: i18n("Reproducir tono armónico al activar o finalizar la escucha")
            checked: kcm.earconsEnabled
            onToggled: kcm.earconsEnabled = checked
            QQC2.ToolTip.text: i18n("Emite un sonido sutil estilo Siri al comenzar y terminar la captura del micrófono")
            QQC2.ToolTip.visible: hovered
        }

        QQC2.CheckBox {
            id: vadCheck
            Kirigami.FormData.label: i18n("Detección de voz (VAD):")
            text: i18n("Detener grabación automáticamente cuando termines de hablar")
            checked: kcm.vadEnabled
            onToggled: kcm.vadEnabled = checked
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Tiempo de silencio (ms):")
            from: 400
            to: 4000
            stepSize: 100
            editable: true
            enabled: vadCheck.checked
            value: kcm.vadSilenceTimeoutMs
            onValueModified: kcm.vadSilenceTimeoutMs = value
            QQC2.ToolTip.text: i18n("Milisegundos de pausa necesarios para procesar automáticamente la orden")
            QQC2.ToolTip.visible: hovered
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Conversación continua:")
            text: i18n("Esperar una nueva pregunta automáticamente tras responder por voz")
            checked: kcm.continuousConversation
            onToggled: kcm.continuousConversation = checked
            QQC2.ToolTip.text: i18n("Si está desactivado (Recomendado), Kity cerrará el micrófono inmediatamente al terminar de hablar para respetar el perfil de sonido de tus altavoces.")
            QQC2.ToolTip.visible: hovered
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Al abrir ventana:")
            text: i18n("Empezar a escuchar por micrófono inmediatamente al activar Kity")
            checked: kcm.autoListenOnActivate
            onToggled: kcm.autoListenOnActivate = checked
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Motor de Reconocimiento de Voz (STT):")
            Layout.fillWidth: true
            model: [
                { text: i18n("Google Gemini 2.0 Flash (Nube — Máxima precisión y comprensión de voz)"), value: "gemini" },
                { text: i18n("Whisper.cpp (Local / Offline — Privado e independiente de la red)"), value: "whisper" }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                for (var i = 0; i < model.length; ++i) {
                    if (model[i].value === kcm.sttEngine) return i;
                }
                return 0;
            }
            onActivated: {
                kcm.sttEngine = model[currentIndex].value;
            }
        }

        Kirigami.InlineMessage {
            visible: kcm.sttEngine === "gemini"
            Layout.fillWidth: true
            type: Kirigami.MessageType.Information
            text: i18n("Gemini 2.0 Flash procesa directamente el audio en la nube con la máxima fidelidad y sin coste. Utiliza la clave de API configurada abajo en «Cerebro IA / Proveedor de Inteligencia». Si no hay clave, cambiará automáticamente a Whisper local.")
        }

        ColumnLayout {
            visible: kcm.sttEngine === "whisper"
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            QQC2.ComboBox {
                Kirigami.FormData.label: i18n("Modelo Whisper local:")
                Layout.fillWidth: true
                model: [
                    { text: i18n("Whisper Small (466 MB — Recomendado: equilibrio óptimo precisión/velocidad)"), value: "/home/cesar/.local/share/kity/models/ggml-small.bin" },
                    { text: i18n("Whisper Base (142 MB — Ultraligero, menor uso de memoria)"), value: "/home/cesar/.local/share/kity/models/ggml-base.bin" },
                    { text: i18n("Personalizado / Otra ruta…"), value: "custom" }
                ]
                textRole: "text"
                valueRole: "value"
                currentIndex: {
                    if (kcm.whisperModelPath.indexOf("small") !== -1 || kcm.whisperModelPath === "") return 0;
                    if (kcm.whisperModelPath.indexOf("base") !== -1) return 1;
                    return 2;
                }
                onActivated: {
                    var val = model[currentIndex].value;
                    if (val !== "custom") {
                        kcm.whisperModelPath = val;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0

                QQC2.TextField {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    placeholderText: i18n("Ruta al archivo .bin del modelo Whisper")
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
                    QQC2.ToolTip.text: kcm.whisperFound ? i18n("Modelo Whisper detectado y listo") : i18n("Modelo no encontrado en la ruta indicada")
                    QQC2.ToolTip.visible: whisperStatusHover.hovered
                    HoverHandler { id: whisperStatusHover }
                }
            }
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Motor de Síntesis de Voz (TTS):")
            Layout.fillWidth: true
            model: [
                { text: i18n("Google Cloud TTS (Nube — Voces oficiales Neural2 / Journey en castellano)"), value: "google" },
                { text: i18n("Microsoft Edge Neural (Nube gratuita sin clave — Elvira / Ximena en castellano)"), value: "edge" },
                { text: i18n("Kokoro-82M (Local / Offline — Modelo abierto de 82M)"), value: "kokoro" },
                { text: i18n("Piper TTS (Local / Offline — Ligero en .onnx)"), value: "piper" }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                for (var i = 0; i < model.length; ++i) {
                    if (model[i].value === kcm.ttsEngine) return i;
                }
                return 0;
            }
            onActivated: {
                kcm.ttsEngine = model[currentIndex].value;
            }
        }

        // --- Configuración Google Cloud TTS ---
        RowLayout {
            visible: kcm.ttsEngine === "google"
            Kirigami.FormData.label: i18n("Clave de API de Google Cloud:")
            Layout.fillWidth: true

            QQC2.TextField {
                id: googleKeyField
                Layout.fillWidth: true
                echoMode: showGoogleKeyBtn.checked ? TextInput.Normal : TextInput.Password
                placeholderText: i18n("Introduce tu API Key de Google Cloud Text-to-Speech")
                text: kcm.googleApiKey
                onTextEdited: kcm.googleApiKey = text.trim()
            }

            QQC2.ToolButton {
                id: showGoogleKeyBtn
                checkable: true
                checked: false
                icon.name: checked ? "view-visible" : "view-hidden"
                QQC2.ToolTip.text: checked ? i18n("Ocultar clave") : i18n("Mostrar clave")
                QQC2.ToolTip.visible: hovered
            }
        }

        QQC2.ComboBox {
            visible: kcm.ttsEngine === "google"
            Kirigami.FormData.label: i18n("Voz de Google Cloud (España):")
            Layout.fillWidth: true
            model: [
                { text: i18n("es-ES-Neural2-F (Femenina — Calidad Neural2 por defecto)"), value: "es-ES-Neural2-F" },
                { text: i18n("es-ES-Journey-F (Femenina — Expresiva conversacional)"), value: "es-ES-Journey-F" },
                { text: i18n("es-ES-Studio-C (Femenina — Calidad de estudio máxima)"), value: "es-ES-Studio-C" },
                { text: i18n("es-ES-Neural2-A (Femenina — Variante clara)"), value: "es-ES-Neural2-A" },
                { text: i18n("es-ES-Neural2-B (Masculina — Neural2)"), value: "es-ES-Neural2-B" }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                for (var i = 0; i < model.length; ++i) {
                    if (model[i].value === kcm.googleVoice) return i;
                }
                return 0;
            }
            onActivated: kcm.googleVoice = model[currentIndex].value
        }

        // --- Configuración Microsoft Edge Neural TTS ---
        QQC2.ComboBox {
            visible: kcm.ttsEngine === "edge"
            Kirigami.FormData.label: i18n("Voz Edge Neural (Castellano de España):")
            Layout.fillWidth: true
            model: [
                { text: i18n("es-ES-ElviraNeural (Femenina — Natural y amigable)"), value: "es-ES-ElviraNeural" },
                { text: i18n("es-ES-XimenaNeural (Femenina — Entonación profesional)"), value: "es-ES-XimenaNeural" },
                { text: i18n("es-ES-AlvaroNeural (Masculina — Natural)"), value: "es-ES-AlvaroNeural" }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                for (var i = 0; i < model.length; ++i) {
                    if (model[i].value === kcm.edgeVoice) return i;
                }
                return 0;
            }
            onActivated: kcm.edgeVoice = model[currentIndex].value
        }

        // --- Configuración Kokoro-82M ---
        QQC2.ComboBox {
            visible: kcm.ttsEngine === "kokoro"
            Kirigami.FormData.label: i18n("Voz Kokoro-82M:")
            Layout.fillWidth: true
            model: [
                { text: i18n("ef_dora (Femenina — Modelo Kokoro)"), value: "ef_dora" },
                { text: i18n("em_alex (Masculina — Modelo Kokoro)"), value: "em_alex" },
                { text: i18n("em_santa (Masculina — Variante)"), value: "em_santa" }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                for (var i = 0; i < model.length; ++i) {
                    if (model[i].value === kcm.kokoroVoice) return i;
                }
                return 0;
            }
            onActivated: kcm.kokoroVoice = model[currentIndex].value
        }

        // --- Configuración Piper TTS ---
        RowLayout {
            visible: kcm.ttsEngine === "piper"
            Kirigami.FormData.label: i18n("Voz Piper TTS (.onnx):")
            Layout.fillWidth: true
            Layout.minimumWidth: 0

            QQC2.TextField {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                placeholderText: i18n("Detección automática en ~/.local/share/kity/voices/")
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
                QQC2.ToolTip.text: kcm.piperFound ? i18n("Voz Piper detectada y lista") : i18n("Archivo .onnx no encontrado en la ruta indicada")
                QQC2.ToolTip.visible: piperStatusHover.hovered
                HoverHandler { id: piperStatusHover }
            }
        }

        // =====================================================================
        // 2. Motor de Inteligencia Artificial (Dual-Brain: Ollama & Google Gemini)
        // =====================================================================
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Motor de Inteligencia Artificial (Dual-Brain: Local & Nube)")
        }

        QQC2.ComboBox {
            id: aiBackendCombo
            Kirigami.FormData.label: i18n("Arquitectura de IA:")
            Layout.fillWidth: true
            textRole: "text"
            valueRole: "value"
            model: [
                {
                    value: "hybrid",
                    text: i18n("Híbrido Inteligente (Recomendado: Ollama para control local + Google Gemini para web y conocimiento)")
                },
                {
                    value: "gemini",
                    text: i18n("Google Gemini Cloud (Ultra-rápido, multimodal y Google Search Grounding en tiempo real)")
                },
                {
                    value: "ollama",
                    text: i18n("100% Local y Privado con Ollama (Llama 3.2 / Mistral / Qwen — Sin conexión a la nube)")
                }
            ]
            currentIndex: {
                for (let i = 0; i < model.length; ++i) {
                    if (model[i].value === kcm.aiBackend) return i;
                }
                return 0;
            }
            onActivated: kcm.aiBackend = model[currentIndex].value
            QQC2.ToolTip.text: i18n("Permite alternar entre procesamiento 100% local en tu hardware, la nube de Google Gemini o un modo híbrido inteligente.")
            QQC2.ToolTip.visible: hovered
        }

        // Gemini Cloud Settings
        QQC2.ComboBox {
            visible: kcm.aiBackend === "gemini" || kcm.aiBackend === "hybrid"
            Kirigami.FormData.label: i18n("Modelo Google Gemini:")
            Layout.fillWidth: true
            editable: true
            textRole: "text"
            valueRole: "value"
            model: [
                { value: "gemini-4-argon", text: i18n("Gemini 4 (Argon) — Siguiente generación DeepMind / Antigravity") },
                { value: "gemini-2.0-flash", text: i18n("Gemini 2.0 Flash — Ultrarrápido, multimodal con Google Search Grounding") },
                { value: "gemini-2.0-pro-exp-02-05", text: i18n("Gemini 2.0 Pro — Máxima potencia de código y razonamiento") },
                { value: "gemini-1.5-pro", text: i18n("Gemini 1.5 Pro — Ventana de contexto masiva de 2M tokens") },
                { value: "gemini-1.5-flash", text: i18n("Gemini 1.5 Flash — Ligero y eficiente") }
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
            QQC2.ToolTip.text: i18n("Modelo de Gemini a utilizar. Puedes seleccionar uno de la lista o escribir libremente cualquier identificador de modelo al que tengas acceso con tu clave (ej. gemini-4-argon, gemini-2.0-flash, etc.).")
            QQC2.ToolTip.visible: hovered
        }

        RowLayout {
            visible: kcm.aiBackend === "gemini" || kcm.aiBackend === "hybrid"
            Kirigami.FormData.label: i18n("Clave API de Gemini:")
            Layout.fillWidth: true

            QQC2.TextField {
                id: geminiKeyField
                Layout.fillWidth: true
                echoMode: showGeminiKeyBtn.checked ? TextInput.Normal : TextInput.Password
                placeholderText: kcm.googleApiKey.length > 0 ? i18n("Reutilizando clave de Google Cloud configurada en TTS arriba") : i18n("Introduce tu clave API de Google AI Studio / Gemini")
                text: kcm.geminiApiKey
                onTextEdited: kcm.geminiApiKey = text.trim()
                QQC2.ToolTip.text: i18n("Si se deja en blanco, Kity reutilizará automáticamente la clave de Google Cloud API configurada para la síntesis de voz arriba.")
                QQC2.ToolTip.visible: hovered
            }

            QQC2.ToolButton {
                id: showGeminiKeyBtn
                checkable: true
                checked: false
                icon.name: checked ? "view-visible" : "view-hidden"
                QQC2.ToolTip.text: checked ? i18n("Ocultar clave") : i18n("Mostrar clave")
                QQC2.ToolTip.visible: hovered
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Servidor Ollama:")
            Layout.fillWidth: true
            Layout.minimumWidth: 0

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
                QQC2.ToolTip.text: i18n("Verificar conexión con el servidor Ollama local")
                QQC2.ToolTip.visible: checkBtnHover.hovered
                HoverHandler { id: checkBtnHover }
                onClicked: {
                    kcm.checkReadiness();
                    kcm.fetchModels();
                    checkIconAnim.restart();
                }

                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        id: checkIcon
                        source: "view-refresh-symbolic"
                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: Kirigami.Units.iconSizes.small
                        RotationAnimation on rotation {
                            id: checkIconAnim
                            from: 0
                            to: 360
                            duration: 650
                            running: kcm.ollamaChecking
                            loops: kcm.ollamaChecking ? Animation.Infinite : 1
                        }
                    }
                    QQC2.Label {
                        text: i18n("Comprobar")
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Kirigami.Icon {
                source: kcm.ollamaReachable ? "emblem-checked" : "emblem-error"
                implicitWidth: Kirigami.Units.iconSizes.small
                implicitHeight: Kirigami.Units.iconSizes.small
                QQC2.ToolTip.text: kcm.ollamaReachable ? i18n("Servidor Ollama activo y accesible") : i18n("No se puede conectar a Ollama en esta dirección")
                QQC2.ToolTip.visible: checkHover.hovered
                HoverHandler { id: checkHover }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Modelo principal:")
            Layout.fillWidth: true
            Layout.minimumWidth: 0

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
                onActivated: index => {
                    kcm.ollamaModel = model[index];
                }
                onAccepted: {
                    if (editText.trim().length > 0) {
                        kcm.ollamaModel = editText.trim();
                    }
                }
                QQC2.ToolTip.text: i18n("Modelo de lenguaje local utilizado para razonar y responder")
                QQC2.ToolTip.visible: hovered
            }

            QQC2.Button {
                id: refreshModelsButton
                QQC2.ToolTip.text: i18n("Consultar modelos instalados en Ollama y refrescar lista")
                QQC2.ToolTip.visible: refreshModelsBtnHover.hovered
                HoverHandler { id: refreshModelsBtnHover }
                onClicked: {
                    kcm.fetchModels();
                    refreshModelsAnim.restart();
                }

                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        id: refreshModelsIcon
                        source: "view-refresh-symbolic"
                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: Kirigami.Units.iconSizes.small
                        RotationAnimation on rotation {
                            id: refreshModelsAnim
                            from: 0
                            to: 360
                            duration: 650
                            running: false
                        }
                    }
                    QQC2.Label {
                        text: i18n("Actualizar lista")
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Temperatura (%1):", kcm.ollamaTemperature.toFixed(2))
            Layout.fillWidth: true
            Layout.minimumWidth: 0

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
                text: kcm.ollamaTemperature <= 0.35 ? i18n("Preciso") : i18n("Creativo")
                color: Kirigami.Theme.neutralTextColor
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Instrucción base (System Prompt):")
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: Kirigami.Units.smallSpacing

            QQC2.TextArea {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                implicitHeight: Kirigami.Units.gridUnit * 5
                wrapMode: TextEdit.Wrap
                text: kcm.systemPrompt
                onTextEdited: kcm.systemPrompt = text
                QQC2.ToolTip.text: i18n("Instrucciones principales de comportamiento, idioma y personalidad para Kity")
                QQC2.ToolTip.visible: hovered
            }

            QQC2.Button {
                id: restorePromptBtn
                QQC2.ToolTip.text: i18n("Restablecer la instrucción base en español de España")
                QQC2.ToolTip.visible: restorePromptHover.hovered
                HoverHandler { id: restorePromptHover }
                onClicked: {
                    kcm.restoreDefaultPrompt();
                    restoreAnim.restart();
                }

                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        id: restoreIcon
                        source: "edit-reset"
                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: Kirigami.Units.iconSizes.small
                        RotationAnimation on rotation {
                            id: restoreAnim
                            from: 0
                            to: -360
                            duration: 500
                            running: false
                        }
                    }
                    QQC2.Label {
                        text: i18n("Restaurar instrucción por defecto (Español de España)")
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Opciones técnicas:")
            text: i18n("Mostrar parámetros avanzados de rendimiento de Ollama")
            checked: root.showAdvancedOllama
            onToggled: root.showAdvancedOllama = checked
        }

        QQC2.SpinBox {
            visible: root.showAdvancedOllama
            Kirigami.FormData.label: i18n("Ventana de contexto (tokens):")
            from: 1024
            to: 65536
            stepSize: 1024
            editable: true
            value: kcm.ollamaNumCtx
            onValueModified: kcm.ollamaNumCtx = value
            QQC2.ToolTip.text: i18n("4096 tokens (por defecto) es el tamaño óptimo de memoria para respuestas de voz y contexto RAG sin sobrecargar la inferencia.")
            QQC2.ToolTip.visible: hovered
        }

        QQC2.SpinBox {
            visible: root.showAdvancedOllama
            Kirigami.FormData.label: i18n("Hilos de CPU para inferencia:")
            from: 1
            to: 20
            stepSize: 1
            editable: true
            value: kcm.ollamaNumThread
            onValueModified: kcm.ollamaNumThread = value
            QQC2.ToolTip.text: i18n("Óptimo para tu procesador Intel Core i5-13600K: 6 hilos (aprovecha al 100% los 6 núcleos P de alto rendimiento con máxima velocidad y cero competencia de hilos).")
            QQC2.ToolTip.visible: hovered
        }

        QQC2.SpinBox {
            visible: root.showAdvancedOllama
            Kirigami.FormData.label: i18n("Máximo tokens por respuesta:")
            from: 64
            to: 4096
            stepSize: 64
            editable: true
            value: kcm.ollamaNumPredict
            onValueModified: kcm.ollamaNumPredict = value
            QQC2.ToolTip.text: i18n("384 tokens garantiza respuestas concisas, dinámicas y naturales, optimizadas para síntesis de voz (TTS).")
            QQC2.ToolTip.visible: hovered
        }

        QQC2.TextField {
            visible: root.showAdvancedOllama
            Kirigami.FormData.label: i18n("Permanencia en RAM/VRAM:")
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            placeholderText: "24h"
            text: kcm.ollamaKeepAlive
            onTextEdited: kcm.ollamaKeepAlive = text.trim()
            QQC2.ToolTip.text: i18n("24h mantiene el modelo cargado en tus 32 GB de RAM, eliminando el retardo de 2 a 3 segundos de carga inicial en frío.")
            QQC2.ToolTip.visible: hovered
        }

        RowLayout {
            visible: root.showAdvancedOllama
            Kirigami.FormData.label: i18n("Modelo de visión (pantalla):")
            Layout.fillWidth: true
            Layout.minimumWidth: 0

            QQC2.ComboBox {
                id: visionModelCombo
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                editable: true
                model: kcm.detectedModels.length > 0 ? kcm.detectedModels : ["llama3.2:3b", "mistral:7b", "llama3.1:8b", "gemma2:9b"]
                editText: kcm.ollamaVisionModel
                currentIndex: {
                    const idx = model.indexOf(kcm.ollamaVisionModel);
                    return idx >= 0 ? idx : 0;
                }
                onActivated: index => {
                    kcm.ollamaVisionModel = model[index];
                }
                onAccepted: {
                    if (editText.trim().length > 0) {
                        kcm.ollamaVisionModel = editText.trim();
                    }
                }
                QQC2.ToolTip.text: i18n("Modelo utilizado para analizar capturas de pantalla. Por defecto se apoya en Live Text OCR (Tesseract) con tu modelo local (ej. %1). Si instalas un modelo multimodal (como llama3.2-vision:11b o llava:7b), puedes seleccionarlo aquí.", kcm.ollamaModel)
                QQC2.ToolTip.visible: hovered
            }

            QQC2.Label {
                text: i18n("Live Text OCR activo")
                color: Kirigami.Theme.positiveTextColor
                font: Kirigami.Theme.smallFont
                QQC2.ToolTip.text: i18n("El motor nativo de Live Text OCR (Tesseract) procesa el texto de pantalla y ventanas de forma instantánea.")
                QQC2.ToolTip.visible: ocrBadgeHover.hovered
                HoverHandler { id: ocrBadgeHover }
            }
        }

        // =====================================================================
        // 3. Base de Conocimiento Local y Privacidad (RAG)
        // =====================================================================
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Base Documental y Privacidad (RAG)")
        }

        QQC2.CheckBox {
            id: kbCheck
            Kirigami.FormData.label: i18n("Documentos locales:")
            text: i18n("Buscar en mis notas y documentos locales (.txt, .md) para enriquecer respuestas")
            checked: kcm.knowledgeBaseEnabled
            onToggled: kcm.knowledgeBaseEnabled = checked
            QQC2.ToolTip.text: i18n("Guarda apuntes privados en la carpeta para que Kity los consulte de forma 100% local")
            QQC2.ToolTip.visible: hovered
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Máximo de fragmentos a extraer:")
            from: 1
            to: 10
            stepSize: 1
            editable: true
            enabled: kbCheck.checked
            value: kcm.knowledgeBaseMaxSnippets
            onValueModified: kcm.knowledgeBaseMaxSnippets = value
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Carpeta de notas:")
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            enabled: kbCheck.checked

            QQC2.Label {
                text: "~/.local/share/kity/knowledge/"
                font.family: "monospace"
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                elide: Text.ElideMiddle
            }

            QQC2.Button {
                icon.name: "document-open-folder"
                text: i18n("Abrir en Dolphin")
                QQC2.ToolTip.text: i18n("Abrir la carpeta de conocimiento local en el gestor de archivos Dolphin")
                QQC2.ToolTip.visible: hovered
                onClicked: kcm.openKnowledgeFolder()
            }
        }

        // =====================================================================
        // 4. Servicios y Productividad
        // =====================================================================
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Servicios y Productividad")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Cliente de correo:")
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            model: root.emailClients
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                for (let i = 0; i < root.emailClients.length; ++i) {
                    if (root.emailClients[i].value === kcm.defaultEmailClient) return i;
                }
                return 0;
            }
            onActivated: index => {
                kcm.defaultEmailClient = root.emailClients[index].value;
            }
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Servicio de calendario:")
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            model: root.calendarClients
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                for (let i = 0; i < root.calendarClients.length; ++i) {
                    if (root.calendarClients[i].value === kcm.defaultCalendarClient) return i;
                }
                return 0;
            }
            onActivated: index => {
                kcm.defaultCalendarClient = root.calendarClients[index].value;
            }
        }

        // =====================================================================
        // 5. Ventana y Apariencia
        // =====================================================================
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Ventana y Apariencia")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Estilo de icono en el panel:")
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            model: root.iconStyles
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                for (let i = 0; i < root.iconStyles.length; ++i) {
                    if (root.iconStyles[i].value === kcm.panelIconStyle) return i;
                }
                return 0;
            }
            onActivated: index => {
                kcm.panelIconStyle = root.iconStyles[index].value;
            }
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Comportamiento:")
            text: i18n("Mantener ventana abierta al cambiar a otra aplicación (Pin)")
            checked: kcm.pin
            onToggled: kcm.pin = checked
        }
    }
}
