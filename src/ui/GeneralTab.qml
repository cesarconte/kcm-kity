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

    readonly property var iconStyles: [
        { "value": "symbolic", "text": i18n("Simbólico monocromo (Breeze)") },
        { "value": "color", "text": i18n("Color (Degradado Kity)") }
    ]

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
        model: tabRoot.iconStyles
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < tabRoot.iconStyles.length; ++i) {
                if (tabRoot.iconStyles[i].value === kcm.panelIconStyle) return i;
            }
            return 0;
        }
        onActivated: index => kcm.panelIconStyle = tabRoot.iconStyles[index].value
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
