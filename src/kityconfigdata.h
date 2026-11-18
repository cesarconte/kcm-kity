/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#pragma once

#include <KConfigGroup>
#include <QString>
#include <QStringList>

struct KityConfigData
{
    // Voice & Audio
    QString sttEngine = QStringLiteral("gemini");
    bool wakeWordEnabled = true;
    bool continuousConversation = false;
    QString speechOutputMode = QStringLiteral("always");
    bool earconsEnabled = true;
    bool vadEnabled = true;
    int vadSilenceTimeoutMs = 1300;
    bool autoListenOnActivate = false;
    bool useCentralizedVoice = true;
    QString whisperLanguage = QStringLiteral("es");
    QString whisperModelPath;
    QString piperVoicePath;

    // TTS Engines
    QString ttsEngine = QStringLiteral("google");
    QString googleApiKey;
    QString googleVoice = QStringLiteral("es-ES-Neural2-F");
    QString edgeVoice = QStringLiteral("es-ES-ElviraNeural");
    QString kokoroVoice = QStringLiteral("ef_dora");

    // AI Engine / Dual-Brain Architecture
    QString aiBackend = QStringLiteral("hybrid");
    QString geminiModel = QStringLiteral("gemini-2.0-flash");
    QString geminiApiKey;

    // Ollama AI Engine
    QString ollamaUrl = QStringLiteral("http://127.0.0.1:11434");
    QString ollamaModel = QStringLiteral("llama3.2:3b");
    QString ollamaVisionModel = QStringLiteral("llama3.2:3b");
    double ollamaTemperature = 0.2;
    int ollamaNumCtx = 4096;
    int ollamaNumThread = 6;
    int ollamaNumPredict = 384;
    QString ollamaKeepAlive = QStringLiteral("24h");
    QString systemPrompt;

    // Local RAG Knowledge Base
    bool knowledgeBaseEnabled = true;
    int knowledgeBaseMaxSnippets = 3;

    // Appearance & Services
    QString panelIconStyle = QStringLiteral("symbolic");
    bool pin = false;
    QString defaultEmailClient = QStringLiteral("proton");
    QString defaultCalendarClient = QStringLiteral("proton");

    // macOS Golden Gate Voice & Assistant Experience
    QString voiceAccent = QStringLiteral("Spanish (Spain)");
    int voiceIndex = 3;
    double voicePace = 0.55;
    double voiceExpressivity = 0.65;
    QString siriMode = QStringLiteral("ai");
    QString historyRetention = QStringLiteral("forever");
    QString openToMode = QStringLiteral("past");
    int previewLines = 4;
    bool alwaysShowRequest = true;
    bool autoVisualLookup = true;
    bool confirmCloudRequests = false;
    bool suggestionsEnabled = true;
    QStringList excludedApps;

    static QString defaultSystemPrompt();
    void load(const KConfigGroup &cfg);
    void save(KConfigGroup &cfg) const;
    void resetDefaults();
};
