/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#pragma once

#include <KQuickConfigModule>
#include <QStringList>

#include "kityconfigdata.h"

class OllamaModelScanner;
class VoicePreviewEngine;

class KcmKity : public KQuickConfigModule
{
    Q_OBJECT

    // Voice & Audio
    Q_PROPERTY(QString sttEngine READ sttEngine WRITE setSttEngine NOTIFY sttEngineChanged)
    Q_PROPERTY(bool wakeWordEnabled READ wakeWordEnabled WRITE setWakeWordEnabled NOTIFY wakeWordEnabledChanged)
    Q_PROPERTY(bool continuousConversation READ continuousConversation WRITE setContinuousConversation NOTIFY continuousConversationChanged)
    Q_PROPERTY(QString speechOutputMode READ speechOutputMode WRITE setSpeechOutputMode NOTIFY speechOutputModeChanged)
    Q_PROPERTY(bool earconsEnabled READ earconsEnabled WRITE setEarconsEnabled NOTIFY earconsEnabledChanged)
    Q_PROPERTY(bool vadEnabled READ vadEnabled WRITE setVadEnabled NOTIFY vadEnabledChanged)
    Q_PROPERTY(int vadSilenceTimeoutMs READ vadSilenceTimeoutMs WRITE setVadSilenceTimeoutMs NOTIFY vadSilenceTimeoutMsChanged)
    Q_PROPERTY(bool autoListenOnActivate READ autoListenOnActivate WRITE setAutoListenOnActivate NOTIFY autoListenOnActivateChanged)
    Q_PROPERTY(bool useCentralizedVoice READ useCentralizedVoice WRITE setUseCentralizedVoice NOTIFY useCentralizedVoiceChanged)
    Q_PROPERTY(QString whisperLanguage READ whisperLanguage WRITE setWhisperLanguage NOTIFY whisperLanguageChanged)
    Q_PROPERTY(QString whisperModelPath READ whisperModelPath WRITE setWhisperModelPath NOTIFY whisperModelPathChanged)
    Q_PROPERTY(QString piperVoicePath READ piperVoicePath WRITE setPiperVoicePath NOTIFY piperVoicePathChanged)

    // TTS Engines (Google Cloud, Edge Neural, Kokoro-82M, Piper)
    Q_PROPERTY(QString ttsEngine READ ttsEngine WRITE setTtsEngine NOTIFY ttsEngineChanged)
    Q_PROPERTY(QString googleApiKey READ googleApiKey WRITE setGoogleApiKey NOTIFY googleApiKeyChanged)
    Q_PROPERTY(QString googleVoice READ googleVoice WRITE setGoogleVoice NOTIFY googleVoiceChanged)
    Q_PROPERTY(QString edgeVoice READ edgeVoice WRITE setEdgeVoice NOTIFY edgeVoiceChanged)
    Q_PROPERTY(QString kokoroVoice READ kokoroVoice WRITE setKokoroVoice NOTIFY kokoroVoiceChanged)

    // AI Engine / Dual-Brain Architecture (Ollama & Google Gemini)
    Q_PROPERTY(QString aiBackend READ aiBackend WRITE setAiBackend NOTIFY aiBackendChanged)
    Q_PROPERTY(QString geminiModel READ geminiModel WRITE setGeminiModel NOTIFY geminiModelChanged)
    Q_PROPERTY(QString geminiApiKey READ geminiApiKey WRITE setGeminiApiKey NOTIFY geminiApiKeyChanged)

    // Ollama AI Engine
    Q_PROPERTY(QString ollamaUrl READ ollamaUrl WRITE setOllamaUrl NOTIFY ollamaUrlChanged)
    Q_PROPERTY(QString ollamaModel READ ollamaModel WRITE setOllamaModel NOTIFY ollamaModelChanged)
    Q_PROPERTY(QString ollamaVisionModel READ ollamaVisionModel WRITE setOllamaVisionModel NOTIFY ollamaVisionModelChanged)
    Q_PROPERTY(double ollamaTemperature READ ollamaTemperature WRITE setOllamaTemperature NOTIFY ollamaTemperatureChanged)
    Q_PROPERTY(int ollamaNumCtx READ ollamaNumCtx WRITE setOllamaNumCtx NOTIFY ollamaNumCtxChanged)
    Q_PROPERTY(int ollamaNumThread READ ollamaNumThread WRITE setOllamaNumThread NOTIFY ollamaNumThreadChanged)
    Q_PROPERTY(int ollamaNumPredict READ ollamaNumPredict WRITE setOllamaNumPredict NOTIFY ollamaNumPredictChanged)
    Q_PROPERTY(QString ollamaKeepAlive READ ollamaKeepAlive WRITE setOllamaKeepAlive NOTIFY ollamaKeepAliveChanged)
    Q_PROPERTY(QString systemPrompt READ systemPrompt WRITE setSystemPrompt NOTIFY systemPromptChanged)

    // Local RAG Knowledge Base
    Q_PROPERTY(bool knowledgeBaseEnabled READ knowledgeBaseEnabled WRITE setKnowledgeBaseEnabled NOTIFY knowledgeBaseEnabledChanged)
    Q_PROPERTY(int knowledgeBaseMaxSnippets READ knowledgeBaseMaxSnippets WRITE setKnowledgeBaseMaxSnippets NOTIFY knowledgeBaseMaxSnippetsChanged)

    // Appearance & Services
    Q_PROPERTY(QString panelIconStyle READ panelIconStyle WRITE setPanelIconStyle NOTIFY panelIconStyleChanged)
    Q_PROPERTY(bool pin READ pin WRITE setPin NOTIFY pinChanged)
    Q_PROPERTY(QString defaultEmailClient READ defaultEmailClient WRITE setDefaultEmailClient NOTIFY defaultEmailClientChanged)
    Q_PROPERTY(QString defaultCalendarClient READ defaultCalendarClient WRITE setDefaultCalendarClient NOTIFY defaultCalendarClientChanged)

    // macOS Golden Gate Voice & Assistant Experience
    Q_PROPERTY(QString voiceAccent READ voiceAccent WRITE setVoiceAccent NOTIFY goldenGateChanged)
    Q_PROPERTY(int voiceIndex READ voiceIndex WRITE setVoiceIndex NOTIFY goldenGateChanged)
    Q_PROPERTY(double voicePace READ voicePace WRITE setVoicePace NOTIFY goldenGateChanged)
    Q_PROPERTY(double voiceExpressivity READ voiceExpressivity WRITE setVoiceExpressivity NOTIFY goldenGateChanged)
    Q_PROPERTY(QString siriMode READ siriMode WRITE setSiriMode NOTIFY goldenGateChanged)
    Q_PROPERTY(QString historyRetention READ historyRetention WRITE setHistoryRetention NOTIFY goldenGateChanged)
    Q_PROPERTY(QString openToMode READ openToMode WRITE setOpenToMode NOTIFY goldenGateChanged)
    Q_PROPERTY(int previewLines READ previewLines WRITE setPreviewLines NOTIFY goldenGateChanged)
    Q_PROPERTY(bool alwaysShowRequest READ alwaysShowRequest WRITE setAlwaysShowRequest NOTIFY goldenGateChanged)
    Q_PROPERTY(bool autoVisualLookup READ autoVisualLookup WRITE setAutoVisualLookup NOTIFY goldenGateChanged)
    Q_PROPERTY(bool confirmCloudRequests READ confirmCloudRequests WRITE setConfirmCloudRequests NOTIFY goldenGateChanged)
    Q_PROPERTY(bool suggestionsEnabled READ suggestionsEnabled WRITE setSuggestionsEnabled NOTIFY goldenGateChanged)
    Q_PROPERTY(QStringList excludedApps READ excludedApps WRITE setExcludedApps NOTIFY goldenGateChanged)

    // Live diagnostics & model discovery
    Q_PROPERTY(QStringList detectedModels READ detectedModels NOTIFY detectedModelsChanged)
    Q_PROPERTY(bool ollamaChecking READ ollamaChecking NOTIFY ollamaCheckingChanged)
    Q_PROPERTY(bool ollamaReachable READ ollamaReachable NOTIFY ollamaReachableChanged)
    Q_PROPERTY(bool whisperFound READ whisperFound NOTIFY diagnosticsChanged)
    Q_PROPERTY(bool piperFound READ piperFound NOTIFY diagnosticsChanged)

public:
    explicit KcmKity(QObject *parent, const KPluginMetaData &data);
    ~KcmKity() override;

    void load() override;
    void save() override;
    void defaults() override;

    // Getters
    QString sttEngine() const { return m_cfg.sttEngine; }
    bool wakeWordEnabled() const { return m_cfg.wakeWordEnabled; }
    bool continuousConversation() const { return m_cfg.continuousConversation; }
    QString speechOutputMode() const { return m_cfg.speechOutputMode; }
    bool earconsEnabled() const { return m_cfg.earconsEnabled; }
    bool vadEnabled() const { return m_cfg.vadEnabled; }
    int vadSilenceTimeoutMs() const { return m_cfg.vadSilenceTimeoutMs; }
    bool autoListenOnActivate() const { return m_cfg.autoListenOnActivate; }
    bool useCentralizedVoice() const { return m_cfg.useCentralizedVoice; }
    QString whisperLanguage() const { return m_cfg.whisperLanguage; }
    QString whisperModelPath() const { return m_cfg.whisperModelPath; }
    QString piperVoicePath() const { return m_cfg.piperVoicePath; }

    QString ttsEngine() const { return m_cfg.ttsEngine; }
    QString googleApiKey() const { return m_cfg.googleApiKey; }
    QString googleVoice() const { return m_cfg.googleVoice; }
    QString edgeVoice() const { return m_cfg.edgeVoice; }
    QString kokoroVoice() const { return m_cfg.kokoroVoice; }

    QString aiBackend() const { return m_cfg.aiBackend; }
    QString geminiModel() const { return m_cfg.geminiModel; }
    QString geminiApiKey() const { return m_cfg.geminiApiKey; }

    QString ollamaUrl() const { return m_cfg.ollamaUrl; }
    QString ollamaModel() const { return m_cfg.ollamaModel; }
    QString ollamaVisionModel() const { return m_cfg.ollamaVisionModel; }
    double ollamaTemperature() const { return m_cfg.ollamaTemperature; }
    int ollamaNumCtx() const { return m_cfg.ollamaNumCtx; }
    int ollamaNumThread() const { return m_cfg.ollamaNumThread; }
    int ollamaNumPredict() const { return m_cfg.ollamaNumPredict; }
    QString ollamaKeepAlive() const { return m_cfg.ollamaKeepAlive; }
    QString systemPrompt() const { return m_cfg.systemPrompt; }

    bool knowledgeBaseEnabled() const { return m_cfg.knowledgeBaseEnabled; }
    int knowledgeBaseMaxSnippets() const { return m_cfg.knowledgeBaseMaxSnippets; }

    QString panelIconStyle() const { return m_cfg.panelIconStyle; }
    bool pin() const { return m_cfg.pin; }
    QString defaultEmailClient() const { return m_cfg.defaultEmailClient; }
    QString defaultCalendarClient() const { return m_cfg.defaultCalendarClient; }

    QString voiceAccent() const { return m_cfg.voiceAccent; }
    int voiceIndex() const { return m_cfg.voiceIndex; }
    double voicePace() const { return m_cfg.voicePace; }
    double voiceExpressivity() const { return m_cfg.voiceExpressivity; }
    QString siriMode() const { return m_cfg.siriMode; }
    QString historyRetention() const { return m_cfg.historyRetention; }
    QString openToMode() const { return m_cfg.openToMode; }
    int previewLines() const { return m_cfg.previewLines; }
    bool alwaysShowRequest() const { return m_cfg.alwaysShowRequest; }
    bool autoVisualLookup() const { return m_cfg.autoVisualLookup; }
    bool confirmCloudRequests() const { return m_cfg.confirmCloudRequests; }
    bool suggestionsEnabled() const { return m_suggestionsEnabled; }
    QStringList excludedApps() const { return m_cfg.excludedApps; }

    QStringList detectedModels() const;
    bool ollamaChecking() const;
    bool ollamaReachable() const;
    bool whisperFound() const;
    bool piperFound() const;

    // Setters
    void setSttEngine(const QString &v);
    void setWakeWordEnabled(bool v);
    void setContinuousConversation(bool v);
    void setSpeechOutputMode(const QString &v);
    void setEarconsEnabled(bool v);
    void setVadEnabled(bool v);
    void setVadSilenceTimeoutMs(int v);
    void setAutoListenOnActivate(bool v);
    void setUseCentralizedVoice(bool v);
    void setWhisperLanguage(const QString &v);
    void setWhisperModelPath(const QString &v);
    void setPiperVoicePath(const QString &v);

    void setTtsEngine(const QString &v);
    void setGoogleApiKey(const QString &v);
    void setGoogleVoice(const QString &v);
    void setEdgeVoice(const QString &v);
    void setKokoroVoice(const QString &v);

    void setAiBackend(const QString &v);
    void setGeminiModel(const QString &v);
    void setGeminiApiKey(const QString &v);

    void setOllamaUrl(const QString &v);
    void setOllamaModel(const QString &v);
    void setOllamaVisionModel(const QString &v);
    void setOllamaTemperature(double v);
    void setOllamaNumCtx(int v);
    void setOllamaNumThread(int v);
    void setOllamaNumPredict(int v);
    void setOllamaKeepAlive(const QString &v);
    void setSystemPrompt(const QString &v);

    void setKnowledgeBaseEnabled(bool v);
    void setKnowledgeBaseMaxSnippets(int v);

    void setPanelIconStyle(const QString &v);
    void setPin(bool v);
    void setDefaultEmailClient(const QString &v);
    void setDefaultCalendarClient(const QString &v);

    void setVoiceAccent(const QString &v);
    void setVoiceIndex(int v);
    void setVoicePace(double v);
    void setVoiceExpressivity(double v);
    void setSiriMode(const QString &v);
    void setHistoryRetention(const QString &v);
    void setOpenToMode(const QString &v);
    void setPreviewLines(int v);
    void setAlwaysShowRequest(bool v);
    void setAutoVisualLookup(bool v);
    void setConfirmCloudRequests(bool v);
    void setSuggestionsEnabled(bool v);
    void setExcludedApps(const QStringList &v);

    // Q_INVOKABLE Actions
    Q_INVOKABLE void fetchModels();
    Q_INVOKABLE void checkReadiness();
    Q_INVOKABLE void openKnowledgeFolder() const;
    Q_INVOKABLE void restoreDefaultPrompt();
    Q_INVOKABLE void previewVoice();
    Q_INVOKABLE void openShortcutsKCM() const;
    Q_INVOKABLE void addExcludedApp(const QString &appName);
    Q_INVOKABLE void removeExcludedApp(const QString &appName);

Q_SIGNALS:
    void goldenGateChanged();
    void sttEngineChanged();
    void wakeWordEnabledChanged();
    void continuousConversationChanged();
    void speechOutputModeChanged();
    void earconsEnabledChanged();
    void vadEnabledChanged();
    void vadSilenceTimeoutMsChanged();
    void autoListenOnActivateChanged();
    void useCentralizedVoiceChanged();
    void whisperLanguageChanged();
    void whisperModelPathChanged();
    void piperVoicePathChanged();
    void ttsEngineChanged();
    void googleApiKeyChanged();
    void googleVoiceChanged();
    void edgeVoiceChanged();
    void kokoroVoiceChanged();

    void aiBackendChanged();
    void geminiModelChanged();
    void geminiApiKeyChanged();

    void ollamaUrlChanged();
    void ollamaModelChanged();
    void ollamaVisionModelChanged();
    void ollamaTemperatureChanged();
    void ollamaNumCtxChanged();
    void ollamaNumThreadChanged();
    void ollamaNumPredictChanged();
    void ollamaKeepAliveChanged();
    void systemPromptChanged();

    void knowledgeBaseEnabledChanged();
    void knowledgeBaseMaxSnippetsChanged();

    void panelIconStyleChanged();
    void pinChanged();
    void defaultEmailClientChanged();
    void defaultCalendarClientChanged();

    void detectedModelsChanged();
    void ollamaCheckingChanged();
    void ollamaReachableChanged();
    void diagnosticsChanged();

private:
    void notifyDaemon();
    void emitAllChanged();

    KityConfigData m_cfg;
    OllamaModelScanner *m_ollamaScanner = nullptr;
    VoicePreviewEngine *m_voicePreviewEngine = nullptr;
    bool m_suggestionsEnabled = true;
};
