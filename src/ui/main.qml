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

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    readonly property var speechModes: [
        { "value": "always", "text": i18n("Hablar siempre en voz alta") },
        { "value": "voice_only", "text": i18n("Solo al preguntar por voz") },
        { "value": "manual", "text": i18n("Solo manual (pulsar altavoz)") }
    ]

    readonly property var iconStyles: [
        { "value": "symbolic", "text": i18n("Simbólico monocromo (Breeze)") },
        { "value": "color", "text": i18n("Color (Degradado Kity)") }
    ]

    readonly property var emailClients: [
        { "value": "proton", "text": i18n("Proton Mail") },
        { "value": "gmail", "text": i18n("Google Gmail") },
        { "value": "system", "text": i18n("Cliente predeterminado del sistema") }
    ]

    readonly property var calendarClients: [
        { "value": "korganizer", "text": i18n("KOrganizer (Google Calendar)") },
        { "value": "google", "text": i18n("Google Calendar (Web)") },
        { "value": "proton", "text": i18n("Proton Calendar") }
    ]

    property bool showAdvancedOllama: false
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

    ColumnLayout {
        width: root.width
        spacing: 0

        Kirigami.NavigationTabBar {
            id: navTabBar
            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            Layout.fillWidth: true

            actions: [
                Kirigami.Action {
                    icon.name: "preferences-other"
                    text: i18n("General")
                    checked: stackLayout.currentIndex === 0
                    onTriggered: stackLayout.currentIndex = 0
                },
                Kirigami.Action {
                    icon.name: "audio-input-microphone"
                    text: i18n("Voz y Sonido")
                    checked: stackLayout.currentIndex === 1
                    onTriggered: stackLayout.currentIndex = 1
                },
                Kirigami.Action {
                    icon.name: "system-run"
                    text: i18n("Inteligencia Artificial")
                    checked: stackLayout.currentIndex === 2
                    onTriggered: stackLayout.currentIndex = 2
                },
                Kirigami.Action {
                    icon.name: "document-edit"
                    text: i18n("Productividad")
                    checked: stackLayout.currentIndex === 3
                    onTriggered: stackLayout.currentIndex = 3
                }
            ]
        }

        StackLayout {
            id: stackLayout
            currentIndex: 0
            Layout.fillWidth: true
            Layout.preferredHeight: children[currentIndex].implicitHeight

            // =================================================================
            // TAB 0: GENERAL
            // =================================================================
            Kirigami.FormLayout {
                Layout.fillWidth: true

                // --- Hero Card: Estado de Kity ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.maximumWidth: 620
                    implicitHeight: heroContentCol.implicitHeight + 20
                    radius: 12
                    color: Qt.rgba(0.12, 0.13, 0.18, 0.88)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.14)

                    ColumnLayout {
                        id: heroContentCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: 20
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#FF375F" }
                                    GradientStop { position: 0.5; color: "#BF5AF2" }
                                    GradientStop { position: 1.0; color: "#5E5CE6" }
                                }

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    width: 20
                                    height: 20
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
                                    font.pixelSize: 13
                                    color: "#FFFFFF"
                                    text: kcm.siriMode === "ai"
                                        ? i18n("Kity AI (beta) activado")
                                        : (kcm.siriMode === "classic" ? i18n("Kity (clásico) activado") : i18n("Kity está desactivado"))
                                }

                                QQC2.Label {
                                    Layout.fillWidth: true
                                    wrapMode: Text.WordWrap
                                    font.pixelSize: 11
                                    color: Qt.rgba(1, 1, 1, 0.72)
                                    text: i18n("Asistente conversacional inteligente y control por voz estilo macOS Golden Gate.")
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            QQC2.Button {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                highlighted: kcm.siriMode === "ai"
                                text: i18n("Kity AI (beta)")
                                onClicked: kcm.siriMode = "ai"
                            }

                            QQC2.Button {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                highlighted: kcm.siriMode === "classic"
                                text: i18n("Kity clásico")
                                onClicked: kcm.siriMode = "classic"
                            }

                            QQC2.Button {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                highlighted: kcm.siriMode === "off"
                                text: i18n("Desactivar")
                                onClicked: kcm.siriMode = "off"
                            }
                        }
                    }
                }

                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Atajo y Comportamiento")
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Atajo de teclado:")
                    Layout.fillWidth: true
                    spacing: 8

                    QQC2.Label {
                        text: i18n("Meta + K")
                        font.bold: true
                    }

                    QQC2.Button {
                        text: i18n("Configurar en KDE…")
                        icon.name: "configure-shortcuts"
                        onClicked: kcm.openShortcutsKCM()
                    }
                }

                QQC2.CheckBox {
                    Kirigami.FormData.label: i18n("Ventana:")
                    text: i18n("Mantener abierta al cambiar a otra aplicación (Pin)")
                    checked: kcm.pin
                    onToggled: kcm.pin = checked
                }

                QQC2.ComboBox {
                    Kirigami.FormData.label: i18n("Icono de panel:")
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.maximumWidth: 320
                    model: root.iconStyles
                    textRole: "text"
                    valueRole: "value"
                    currentIndex: {
                        for (let i = 0; i < root.iconStyles.length; ++i) {
                            if (root.iconStyles[i].value === kcm.panelIconStyle) return i;
                        }
                        return 0;
                    }
                    onActivated: index => kcm.panelIconStyle = root.iconStyles[index].value
                }

                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Historial de Conversaciones")
                }

                QQC2.ComboBox {
                    Kirigami.FormData.label: i18n("Abrir en:")
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.maximumWidth: 320
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
                    Kirigami.FormData.label: i18n("Conservar historial:")
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.maximumWidth: 320
                    model: [
                        { value: "forever", text: i18n("Siempre") },
                        { value: "1year", text: i18n("1 año") },
                        { value: "30days", text: i18n("30 días") }
                    ]
                    textRole: "text"
                    valueRole: "value"
                    currentIndex: kcm.historyRetention === "1year" ? 1 : (kcm.historyRetention === "30days" ? 2 : 0)
                    onActivated: index => kcm.historyRetention = (index === 1 ? "1year" : (index === 2 ? "30days" : "forever"))
                }

                QQC2.ComboBox {
                    Kirigami.FormData.label: i18n("Vista previa lateral:")
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.maximumWidth: 320
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

                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Aplicaciones Excluidas")
                }

                ColumnLayout {
                    Kirigami.FormData.label: i18n("Apps excluidas:")
                    Layout.fillWidth: true
                    Layout.maximumWidth: 460
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        QQC2.TextField {
                            id: excludedAppInput
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            placeholderText: i18n("Nombre de aplicación…")
                            onAccepted: {
                                if (text.trim().length > 0) {
                                    kcm.addExcludedApp(text.trim());
                                    text = "";
                                }
                            }
                        }

                        QQC2.Button {
                            icon.name: "list-add"
                            text: i18n("Añadir")
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
                                height: 24
                                width: exclRow.implicitWidth + 12
                                radius: 12
                                color: Qt.rgba(1, 1, 1, 0.10)
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.18)

                                RowLayout {
                                    id: exclRow
                                    anchors.centerIn: parent
                                    spacing: 4

                                    QQC2.Label {
                                        text: modelData
                                        font.pixelSize: 11
                                    }

                                    QQC2.ToolButton {
                                        text: "✕"
                                        implicitWidth: 16
                                        implicitHeight: 16
                                        onClicked: kcm.removeExcludedApp(modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // =================================================================
            // TAB 1: VOZ Y SONIDO
            // =================================================================
            Kirigami.FormLayout {
                Layout.fillWidth: true

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
                    model: root.speechModes
                    textRole: "text"
                    valueRole: "value"
                    currentIndex: {
                        for (let i = 0; i < root.speechModes.length; ++i) {
                            if (root.speechModes[i].value === kcm.speechOutputMode) return i;
                        }
                        return 0;
                    }
                    onActivated: index => kcm.speechOutputMode = root.speechModes[index].value
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
                        model: root.chromaticOrbColors

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

            // =================================================================
            // TAB 2: INTELIGENCIA ARTIFICIAL
            // =================================================================
            Kirigami.FormLayout {
                Layout.fillWidth: true

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
                    checked: root.showAdvancedOllama
                    onToggled: root.showAdvancedOllama = checked
                }

                QQC2.SpinBox {
                    visible: root.showAdvancedOllama
                    Kirigami.FormData.label: i18n("Ventana contexto:")
                    from: 1024
                    to: 65536
                    stepSize: 1024
                    editable: true
                    value: kcm.ollamaNumCtx
                    onValueModified: kcm.ollamaNumCtx = value
                }

                QQC2.SpinBox {
                    visible: root.showAdvancedOllama
                    Kirigami.FormData.label: i18n("Hilos de CPU:")
                    from: 1
                    to: 20
                    stepSize: 1
                    editable: true
                    value: kcm.ollamaNumThread
                    onValueModified: kcm.ollamaNumThread = value
                }

                QQC2.SpinBox {
                    visible: root.showAdvancedOllama
                    Kirigami.FormData.label: i18n("Máx tokens respuesta:")
                    from: 64
                    to: 4096
                    stepSize: 64
                    editable: true
                    value: kcm.ollamaNumPredict
                    onValueModified: kcm.ollamaNumPredict = value
                }

                QQC2.TextField {
                    visible: root.showAdvancedOllama
                    Kirigami.FormData.label: i18n("Permanencia en RAM:")
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.maximumWidth: 140
                    placeholderText: "24h"
                    text: kcm.ollamaKeepAlive
                    onTextEdited: kcm.ollamaKeepAlive = text.trim()
                }

                RowLayout {
                    visible: root.showAdvancedOllama
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

            // =================================================================
            // TAB 3: PRODUCTIVIDAD
            // =================================================================
            Kirigami.FormLayout {
                Layout.fillWidth: true

                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Inteligencia en Pantalla y Privacidad")
                }

                QQC2.CheckBox {
                    Kirigami.FormData.label: i18n("Transcripción:")
                    text: i18n("Mostrar siempre la petición en pantalla")
                    checked: kcm.alwaysShowRequest
                    onToggled: kcm.alwaysShowRequest = checked
                }

                QQC2.CheckBox {
                    Kirigami.FormData.label: i18n("Búsqueda visual:")
                    text: i18n("Identificar objetos y texto (Live OCR) en capturas")
                    checked: kcm.autoVisualLookup
                    onToggled: kcm.autoVisualLookup = checked
                }

                QQC2.CheckBox {
                    Kirigami.FormData.label: i18n("Consultas en nube:")
                    text: i18n("Confirmar antes de enviar consultas complejas a Gemini")
                    checked: kcm.confirmCloudRequests
                    onToggled: kcm.confirmCloudRequests = checked
                }

                QQC2.CheckBox {
                    Kirigami.FormData.label: i18n("Sugerencias:")
                    text: i18n("Permitir sugerencias contextuales en aplicaciones")
                    checked: kcm.suggestionsEnabled
                    onToggled: kcm.suggestionsEnabled = checked
                }

                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Base Documental Local (RAG)")
                }

                QQC2.CheckBox {
                    id: kbCheck
                    Kirigami.FormData.label: i18n("Documentos locales:")
                    text: i18n("Consultar notas privadas (.txt, .md) para enriquecer respuestas")
                    checked: kcm.knowledgeBaseEnabled
                    onToggled: kcm.knowledgeBaseEnabled = checked
                }

                QQC2.SpinBox {
                    Kirigami.FormData.label: i18n("Máximo fragmentos:")
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
                    Layout.maximumWidth: 460
                    enabled: kbCheck.checked

                    QQC2.Label {
                        text: "~/.local/share/kity/knowledge/"
                        font.family: "monospace"
                        font.pixelSize: 11
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        elide: Text.ElideMiddle
                    }

                    QQC2.Button {
                        icon.name: "document-open-folder"
                        text: i18n("Abrir en Dolphin")
                        onClicked: kcm.openKnowledgeFolder()
                    }
                }

                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Servicios Integrados")
                }

                QQC2.ComboBox {
                    Kirigami.FormData.label: i18n("Cliente de correo:")
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.maximumWidth: 320
                    model: root.emailClients
                    textRole: "text"
                    valueRole: "value"
                    currentIndex: {
                        for (let i = 0; i < root.emailClients.length; ++i) {
                            if (root.emailClients[i].value === kcm.defaultEmailClient) return i;
                        }
                        return 0;
                    }
                    onActivated: index => kcm.defaultEmailClient = root.emailClients[index].value
                }

                QQC2.ComboBox {
                    Kirigami.FormData.label: i18n("Servicio de calendario:")
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.maximumWidth: 320
                    model: root.calendarClients
                    textRole: "text"
                    valueRole: "value"
                    currentIndex: {
                        for (let i = 0; i < root.calendarClients.length; ++i) {
                            if (root.calendarClients[i].value === kcm.defaultCalendarClient) return i;
                        }
                        return 0;
                    }
                    onActivated: index => kcm.defaultCalendarClient = root.calendarClients[index].value
                }
            }
        }
    }
}
