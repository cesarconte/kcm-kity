/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#pragma once

#include <QObject>
#include <QPointer>
#include <QProcess>

class VoicePreviewEngine : public QObject
{
    Q_OBJECT

public:
    explicit VoicePreviewEngine(QObject *parent = nullptr);
    ~VoicePreviewEngine() override;

    void previewVoice(const QString &voiceAccent, int voiceIndex, double voicePace, double voiceExpressivity);
    void stop();

private:
    void cleanupProcesses();
    static QString resolveEdgeVoiceForOrb(const QString &accent, int idx, int &orbPitchShift);

    QPointer<QProcess> m_previewTtsProc;
    QPointer<QProcess> m_previewPlayProc;
};
