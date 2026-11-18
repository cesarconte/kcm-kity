/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#include "kityconfigdata.h"

QString KityConfigData::defaultSystemPrompt()
{
    return QStringLiteral(
        "Eres Kity, un asistente de voz e inteligencia artificial nativo para KDE Plasma en CachyOS Linux. "
        "Responde SIEMPRE en español de España (castellano), de forma concisa, clara, directa y natural, "
        "optimizada para síntesis de voz (TTS).");
}

void KityConfigData::load(const KConfigGroup &cfg)
{
    sttEngine = cfg.readEntry(QStringLiteral("sttEngine"), QStringLiteral("gemini"));
    wakeWordEnabled = cfg.readEntry(QStringLiteral("wakeWordEnabled"), true);
    continuousConversation = cfg.readEntry(QStringLiteral("continuousConversation"), false);
    speechOutputMode = cfg.readEntry(QStringLiteral("speechOutputMode"), QStringLiteral("always"));
    earconsEnabled = cfg.readEntry(QStringLiteral("earconsEnabled"), true);
    vadEnabled = cfg.readEntry(QStringLiteral("vadEnabled"), true);
    vadSilenceTimeoutMs = cfg.readEntry(QStringLiteral("vadSilenceTimeoutMs"), 1300);
    autoListenOnActivate = cfg.readEntry(QStringLiteral("autoListenOnActivate"), false);
    useCentralizedVoice = cfg.readEntry(QStringLiteral("useCentralizedVoice"), true);
    whisperLanguage = cfg.readEntry(QStringLiteral("whisperLanguage"), QStringLiteral("es"));
    whisperModelPath = cfg.readEntry(QStringLiteral("whisperModelPath"), QString());
    piperVoicePath = cfg.readEntry(QStringLiteral("piperVoicePath"), QString());
    ttsEngine = cfg.readEntry(QStringLiteral("ttsEngine"), QStringLiteral("google"));
    googleApiKey = cfg.readEntry(QStringLiteral("googleApiKey"), QString());
    googleVoice = cfg.readEntry(QStringLiteral("googleVoice"), QStringLiteral("es-ES-Neural2-F"));
    edgeVoice = cfg.readEntry(QStringLiteral("edgeVoice"), QStringLiteral("es-ES-ElviraNeural"));
    kokoroVoice = cfg.readEntry(QStringLiteral("kokoroVoice"), QStringLiteral("ef_dora"));

    aiBackend = cfg.readEntry(QStringLiteral("aiBackend"), QStringLiteral("hybrid"));
    geminiModel = cfg.readEntry(QStringLiteral("geminiModel"), QStringLiteral("gemini-2.0-flash"));
    geminiApiKey = cfg.readEntry(QStringLiteral("geminiApiKey"), QString());

    ollamaUrl = cfg.readEntry(QStringLiteral("ollamaUrl"), QStringLiteral("http://127.0.0.1:11434"));
    ollamaModel = cfg.readEntry(QStringLiteral("ollamaModel"), QStringLiteral("llama3.2:3b"));
    ollamaVisionModel = cfg.readEntry(QStringLiteral("ollamaVisionModel"), QStringLiteral("llama3.2:3b"));
    if (ollamaVisionModel == QLatin1String("moondream")) {
        ollamaVisionModel = QStringLiteral("llama3.2:3b");
    }
    ollamaTemperature = cfg.readEntry(QStringLiteral("ollamaTemperature"), 0.2);
    ollamaNumCtx = cfg.readEntry(QStringLiteral("ollamaNumCtx"), 4096);
    ollamaNumThread = cfg.readEntry(QStringLiteral("ollamaNumThread"), 6);
    ollamaNumPredict = cfg.readEntry(QStringLiteral("ollamaNumPredict"), 384);
    ollamaKeepAlive = cfg.readEntry(QStringLiteral("ollamaKeepAlive"), QStringLiteral("24h"));
    systemPrompt = cfg.readEntry(QStringLiteral("systemPrompt"), defaultSystemPrompt());

    knowledgeBaseEnabled = cfg.readEntry(QStringLiteral("knowledgeBaseEnabled"), true);
    knowledgeBaseMaxSnippets = cfg.readEntry(QStringLiteral("knowledgeBaseMaxSnippets"), 3);

    panelIconStyle = cfg.readEntry(QStringLiteral("panelIconStyle"), QStringLiteral("symbolic"));
    pin = cfg.readEntry(QStringLiteral("pin"), false);
    defaultEmailClient = cfg.readEntry(QStringLiteral("defaultEmailClient"), QStringLiteral("proton"));
    defaultCalendarClient = cfg.readEntry(QStringLiteral("defaultCalendarClient"), QStringLiteral("proton"));

    voiceAccent = cfg.readEntry(QStringLiteral("voiceAccent"), QStringLiteral("Spanish (Spain)"));
    voiceIndex = cfg.readEntry(QStringLiteral("voiceIndex"), 3);
    voicePace = cfg.readEntry(QStringLiteral("voicePace"), 0.55);
    voiceExpressivity = cfg.readEntry(QStringLiteral("voiceExpressivity"), 0.65);
    siriMode = cfg.readEntry(QStringLiteral("siriMode"), QStringLiteral("ai"));
    historyRetention = cfg.readEntry(QStringLiteral("historyRetention"), QStringLiteral("forever"));
    openToMode = cfg.readEntry(QStringLiteral("openToMode"), QStringLiteral("past"));
    previewLines = cfg.readEntry(QStringLiteral("previewLines"), 4);
    alwaysShowRequest = cfg.readEntry(QStringLiteral("alwaysShowRequest"), true);
    autoVisualLookup = cfg.readEntry(QStringLiteral("autoVisualLookup"), true);
    confirmCloudRequests = cfg.readEntry(QStringLiteral("confirmCloudRequests"), false);
    suggestionsEnabled = cfg.readEntry(QStringLiteral("suggestionsEnabled"), true);
    excludedApps = cfg.readEntry(QStringLiteral("excludedApps"), QStringList());
}

void KityConfigData::save(KConfigGroup &cfg) const
{
    cfg.writeEntry(QStringLiteral("sttEngine"), sttEngine);
    cfg.writeEntry(QStringLiteral("wakeWordEnabled"), wakeWordEnabled);
    cfg.writeEntry(QStringLiteral("continuousConversation"), continuousConversation);
    cfg.writeEntry(QStringLiteral("speechOutputMode"), speechOutputMode);
    cfg.writeEntry(QStringLiteral("earconsEnabled"), earconsEnabled);
    cfg.writeEntry(QStringLiteral("vadEnabled"), vadEnabled);
    cfg.writeEntry(QStringLiteral("vadSilenceTimeoutMs"), vadSilenceTimeoutMs);
    cfg.writeEntry(QStringLiteral("autoListenOnActivate"), autoListenOnActivate);
    cfg.writeEntry(QStringLiteral("useCentralizedVoice"), useCentralizedVoice);
    cfg.writeEntry(QStringLiteral("whisperLanguage"), whisperLanguage);
    cfg.writeEntry(QStringLiteral("whisperModelPath"), whisperModelPath);
    cfg.writeEntry(QStringLiteral("piperVoicePath"), piperVoicePath);
    cfg.writeEntry(QStringLiteral("ttsEngine"), ttsEngine);
    cfg.writeEntry(QStringLiteral("googleApiKey"), googleApiKey);
    cfg.writeEntry(QStringLiteral("googleVoice"), googleVoice);
    cfg.writeEntry(QStringLiteral("edgeVoice"), edgeVoice);
    cfg.writeEntry(QStringLiteral("kokoroVoice"), kokoroVoice);

    cfg.writeEntry(QStringLiteral("aiBackend"), aiBackend);
    cfg.writeEntry(QStringLiteral("geminiModel"), geminiModel);
    cfg.writeEntry(QStringLiteral("geminiApiKey"), geminiApiKey);

    cfg.writeEntry(QStringLiteral("ollamaUrl"), ollamaUrl);
    cfg.writeEntry(QStringLiteral("ollamaModel"), ollamaModel);
    cfg.writeEntry(QStringLiteral("ollamaVisionModel"), ollamaVisionModel);
    cfg.writeEntry(QStringLiteral("ollamaTemperature"), ollamaTemperature);
    cfg.writeEntry(QStringLiteral("ollamaNumCtx"), ollamaNumCtx);
    cfg.writeEntry(QStringLiteral("ollamaNumThread"), ollamaNumThread);
    cfg.writeEntry(QStringLiteral("ollamaNumPredict"), ollamaNumPredict);
    cfg.writeEntry(QStringLiteral("ollamaKeepAlive"), ollamaKeepAlive);
    cfg.writeEntry(QStringLiteral("systemPrompt"), systemPrompt);

    cfg.writeEntry(QStringLiteral("knowledgeBaseEnabled"), knowledgeBaseEnabled);
    cfg.writeEntry(QStringLiteral("knowledgeBaseMaxSnippets"), knowledgeBaseMaxSnippets);

    cfg.writeEntry(QStringLiteral("panelIconStyle"), panelIconStyle);
    cfg.writeEntry(QStringLiteral("pin"), pin);
    cfg.writeEntry(QStringLiteral("defaultEmailClient"), defaultEmailClient);
    cfg.writeEntry(QStringLiteral("defaultCalendarClient"), defaultCalendarClient);

    cfg.writeEntry(QStringLiteral("voiceAccent"), voiceAccent);
    cfg.writeEntry(QStringLiteral("voiceIndex"), voiceIndex);
    cfg.writeEntry(QStringLiteral("voicePace"), voicePace);
    cfg.writeEntry(QStringLiteral("voiceExpressivity"), voiceExpressivity);
    cfg.writeEntry(QStringLiteral("siriMode"), siriMode);
    cfg.writeEntry(QStringLiteral("historyRetention"), historyRetention);
    cfg.writeEntry(QStringLiteral("openToMode"), openToMode);
    cfg.writeEntry(QStringLiteral("previewLines"), previewLines);
    cfg.writeEntry(QStringLiteral("alwaysShowRequest"), alwaysShowRequest);
    cfg.writeEntry(QStringLiteral("autoVisualLookup"), autoVisualLookup);
    cfg.writeEntry(QStringLiteral("confirmCloudRequests"), confirmCloudRequests);
    cfg.writeEntry(QStringLiteral("suggestionsEnabled"), suggestionsEnabled);
    cfg.writeEntry(QStringLiteral("excludedApps"), excludedApps);

    cfg.sync();
}

void KityConfigData::resetDefaults()
{
    sttEngine = QStringLiteral("gemini");
    wakeWordEnabled = true;
    continuousConversation = false;
    speechOutputMode = QStringLiteral("always");
    earconsEnabled = true;
    vadEnabled = true;
    vadSilenceTimeoutMs = 1300;
    autoListenOnActivate = false;
    useCentralizedVoice = true;
    whisperLanguage = QStringLiteral("es");
    whisperModelPath.clear();
    piperVoicePath.clear();
    ttsEngine = QStringLiteral("google");
    googleApiKey.clear();
    googleVoice = QStringLiteral("es-ES-Neural2-F");
    edgeVoice = QStringLiteral("es-ES-ElviraNeural");
    kokoroVoice = QStringLiteral("ef_dora");

    aiBackend = QStringLiteral("hybrid");
    geminiModel = QStringLiteral("gemini-2.0-flash");
    geminiApiKey.clear();

    ollamaUrl = QStringLiteral("http://127.0.0.1:11434");
    ollamaModel = QStringLiteral("llama3.2:3b");
    ollamaVisionModel = QStringLiteral("llama3.2:3b");
    ollamaTemperature = 0.2;
    ollamaNumCtx = 4096;
    ollamaNumThread = 6;
    ollamaNumPredict = 384;
    ollamaKeepAlive = QStringLiteral("24h");
    systemPrompt = defaultSystemPrompt();

    knowledgeBaseEnabled = true;
    knowledgeBaseMaxSnippets = 3;

    panelIconStyle = QStringLiteral("symbolic");
    pin = false;
    defaultEmailClient = QStringLiteral("proton");
    defaultCalendarClient = QStringLiteral("proton");

    voiceAccent = QStringLiteral("Spanish (Spain)");
    voiceIndex = 3;
    voicePace = 0.55;
    voiceExpressivity = 0.65;
    siriMode = QStringLiteral("ai");
    historyRetention = QStringLiteral("forever");
    openToMode = QStringLiteral("past");
    previewLines = 4;
    alwaysShowRequest = true;
    autoVisualLookup = true;
    confirmCloudRequests = false;
    suggestionsEnabled = true;
    excludedApps.clear();
}
