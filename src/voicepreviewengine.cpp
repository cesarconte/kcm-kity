/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#include "voicepreviewengine.h"

#include <QStandardPaths>
#include <QStringList>

VoicePreviewEngine::VoicePreviewEngine(QObject *parent)
    : QObject(parent)
{
}

VoicePreviewEngine::~VoicePreviewEngine()
{
    cleanupProcesses();
}

void VoicePreviewEngine::stop()
{
    cleanupProcesses();
}

void VoicePreviewEngine::cleanupProcesses()
{
    if (m_previewPlayProc) {
        if (m_previewPlayProc->state() == QProcess::Running) {
            m_previewPlayProc->kill();
        }
        m_previewPlayProc->deleteLater();
        m_previewPlayProc = nullptr;
    }
    if (m_previewTtsProc) {
        if (m_previewTtsProc->state() == QProcess::Running) {
            m_previewTtsProc->kill();
        }
        m_previewTtsProc->deleteLater();
        m_previewTtsProc = nullptr;
    }
}

QString VoicePreviewEngine::resolveEdgeVoiceForOrb(const QString &accent, int idx, int &orbPitchShift)
{
    orbPitchShift = 0;
    if (accent.contains(QLatin1String("Latin"), Qt::CaseInsensitive)) {
        static const QStringList voices = {
            QStringLiteral("es-MX-DaliaNeural"), QStringLiteral("es-MX-JorgeNeural"),
            QStringLiteral("es-CO-SalomeNeural"), QStringLiteral("es-AR-ElenaNeural"),
            QStringLiteral("es-CL-CatalinaNeural"), QStringLiteral("es-US-PalomaNeural"),
            QStringLiteral("es-PE-CamilaNeural")
        };
        return voices.value(idx, voices.at(0));
    }
    if (accent.contains(QLatin1String("American"), Qt::CaseInsensitive)) {
        static const QStringList voices = {
            QStringLiteral("en-US-AndrewNeural"), QStringLiteral("en-US-BrianNeural"),
            QStringLiteral("en-US-GuyNeural"), QStringLiteral("en-US-AvaNeural"),
            QStringLiteral("en-US-EmmaNeural"), QStringLiteral("en-US-JennyNeural"),
            QStringLiteral("en-US-AriaNeural")
        };
        return voices.value(idx, voices.at(3));
    }
    if (accent.contains(QLatin1String("British"), Qt::CaseInsensitive)) {
        static const QStringList voices = {
            QStringLiteral("en-GB-RyanNeural"), QStringLiteral("en-GB-ThomasNeural"),
            QStringLiteral("en-GB-RyanNeural"), QStringLiteral("en-GB-SoniaNeural"),
            QStringLiteral("en-GB-MaisieNeural"), QStringLiteral("en-GB-LibbyNeural"),
            QStringLiteral("en-GB-LibbyNeural")
        };
        static const int shifts[] = { -3, 0, +4, 0, 0, 0, +4 };
        orbPitchShift = shifts[qBound(0, idx, 6)];
        return voices.value(idx, voices.at(3));
    }
    // Spanish (Spain): Edge has 3 native actors (Alvaro, Elvira, Ximena).
    // Modulated into 7 distinct acoustic personas via harmonic pitch offsets.
    static const QStringList esVoices = {
        QStringLiteral("es-ES-AlvaroNeural"), QStringLiteral("es-ES-AlvaroNeural"),
        QStringLiteral("es-ES-AlvaroNeural"), QStringLiteral("es-ES-ElviraNeural"),
        QStringLiteral("es-ES-ElviraNeural"), QStringLiteral("es-ES-XimenaNeural"),
        QStringLiteral("es-ES-XimenaNeural")
    };
    static const int esShifts[] = { -6, 0, +5, 0, +4, -2, +4 };
    orbPitchShift = esShifts[qBound(0, idx, 6)];
    return esVoices.value(idx, esVoices.at(3));
}

void VoicePreviewEngine::previewVoice(const QString &voiceAccent, int voiceIndex, double voicePace, double voiceExpressivity)
{
    cleanupProcesses();

    const QString edgeCli = QStandardPaths::findExecutable(QStringLiteral("kity-edge-tts"));
    const QString pwPlay = QStandardPaths::findExecutable(QStringLiteral("pw-play"));
    if (edgeCli.isEmpty() || pwPlay.isEmpty()) {
        return;
    }

    int orbPitchShift = 0;
    const QString voice = resolveEdgeVoiceForOrb(voiceAccent, qBound(0, voiceIndex, 6), orbPitchShift);
    const int ratePct = qRound((voicePace - 0.5) * 80.0);
    const int userPitchHz = qRound((voiceExpressivity - 0.5) * 28.0);
    const int totalPitchHz = userPitchHz + orbPitchShift;
    const QString rateArg = QStringLiteral("--rate=%1%2%").arg(ratePct >= 0 ? QStringLiteral("+") : QString()).arg(ratePct);
    const QString pitchArg = QStringLiteral("--pitch=%1%2Hz").arg(totalPitchHz >= 0 ? QStringLiteral("+") : QString()).arg(totalPitchHz);
    const QString sampleText = (voiceAccent.contains(QLatin1String("American"), Qt::CaseInsensitive)
                                || voiceAccent.contains(QLatin1String("British"), Qt::CaseInsensitive))
        ? QStringLiteral("Hello, I'm Kity in macOS Golden Gate. You can customize my voice, pace, and expressivity.")
        : QStringLiteral("Hola, soy Kity. Puedes personalizar mi voz, ritmo y expresividad como en macOS.");

    m_previewTtsProc = new QProcess(this);
    m_previewPlayProc = new QProcess(this);
    m_previewTtsProc->setStandardOutputProcess(m_previewPlayProc.data());

    connect(m_previewPlayProc.data(), &QProcess::finished, this, [this](int, QProcess::ExitStatus) {
        cleanupProcesses();
    });

    m_previewTtsProc->start(edgeCli, {QStringLiteral("--voice"), voice, rateArg, pitchArg, QStringLiteral("--text"), sampleText, QStringLiteral("--write-media"), QStringLiteral("-")});
    m_previewPlayProc->start(pwPlay, {QStringLiteral("-")});
}
