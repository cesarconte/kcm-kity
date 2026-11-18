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
        model: tabRoot.emailClients
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < tabRoot.emailClients.length; ++i) {
                if (tabRoot.emailClients[i].value === kcm.defaultEmailClient) return i;
            }
            return 0;
        }
        onActivated: index => kcm.defaultEmailClient = tabRoot.emailClients[index].value
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: i18n("Servicio de calendario:")
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.maximumWidth: 320
        model: tabRoot.calendarClients
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < tabRoot.calendarClients.length; ++i) {
                if (tabRoot.calendarClients[i].value === kcm.defaultCalendarClient) return i;
            }
            return 0;
        }
        onActivated: index => kcm.defaultCalendarClient = tabRoot.calendarClients[index].value
    }
}
