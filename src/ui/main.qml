/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

KCMUtils.SimpleKCM {
    id: root

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

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

            GeneralTab {
                id: generalTab
            }

            VoiceTab {
                id: voiceTab
            }

            AITab {
                id: aiTab
            }

            ProductivityTab {
                id: productivityTab
            }
        }
    }
}
