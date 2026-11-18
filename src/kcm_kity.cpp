/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#include "kcm_kity.h"

#include <KConfigGroup>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDesktopServices>
#include <QDir>
#include <QProcess>
#include <QStandardPaths>
#include <QUrl>

#include "assetdiagnostics.h"
#include "ollamamodelscanner.h"
#include "voicepreviewengine.h"

K_PLUGIN_CLASS_WITH_JSON(KcmKity, "kcm_kity.json")

KcmKity::KcmKity(QObject *parent, const KPluginMetaData &data)
    : KQuickConfigModule(parent, data)
    , m_ollamaScanner(new OllamaModelScanner(this))
    , m_voicePreviewEngine(new VoicePreviewEngine(this))
{
    setButtons(KAbstractConfigModule::Apply | KAbstractConfigModule::Default);

    connect(m_ollamaScanner, &OllamaModelScanner::checkingChanged, this, &KcmKity::ollamaCheckingChanged);
    connect(m_ollamaScanner, &OllamaModelScanner::reachableChanged, this, [this]() {
        Q_EMIT ollamaReachableChanged();
        Q_EMIT diagnosticsChanged();
    });
    connect(m_ollamaScanner, &OllamaModelScanner::detectedModelsChanged, this, [this]() {
        Q_EMIT detectedModelsChanged();
        Q_EMIT diagnosticsChanged();
    });
}

KcmKity::~KcmKity() = default;

void KcmKity::load()
{
    KSharedConfig::Ptr config = KSharedConfig::openConfig(QStringLiteral("kityrc"));
    KConfigGroup cfg = config->group(QStringLiteral("General"));
    m_cfg.load(cfg);
    m_suggestionsEnabled = m_cfg.suggestionsEnabled;

    emitAllChanged();
    setNeedsSave(false);

    checkReadiness();
    fetchModels();
}

void KcmKity::save()
{
    KSharedConfig::Ptr config = KSharedConfig::openConfig(QStringLiteral("kityrc"));
    KConfigGroup cfg = config->group(QStringLiteral("General"));
    m_cfg.suggestionsEnabled = m_suggestionsEnabled;
    m_cfg.save(cfg);

    notifyDaemon();
    setNeedsSave(false);
}

void KcmKity::defaults()
{
    m_cfg.resetDefaults();
    m_suggestionsEnabled = m_cfg.suggestionsEnabled;

    emitAllChanged();
    setNeedsSave(true);
}

void KcmKity::emitAllChanged()
{
    Q_EMIT goldenGateChanged();
    Q_EMIT sttEngineChanged();
    Q_EMIT wakeWordEnabledChanged();
    Q_EMIT continuousConversationChanged();
    Q_EMIT speechOutputModeChanged();
    Q_EMIT earconsEnabledChanged();
    Q_EMIT vadEnabledChanged();
    Q_EMIT vadSilenceTimeoutMsChanged();
    Q_EMIT autoListenOnActivateChanged();
    Q_EMIT useCentralizedVoiceChanged();
    Q_EMIT whisperLanguageChanged();
    Q_EMIT whisperModelPathChanged();
    Q_EMIT piperVoicePathChanged();
    Q_EMIT ttsEngineChanged();
    Q_EMIT googleApiKeyChanged();
    Q_EMIT googleVoiceChanged();
    Q_EMIT edgeVoiceChanged();
    Q_EMIT kokoroVoiceChanged();

    Q_EMIT aiBackendChanged();
    Q_EMIT geminiModelChanged();
    Q_EMIT geminiApiKeyChanged();

    Q_EMIT ollamaUrlChanged();
    Q_EMIT ollamaModelChanged();
    Q_EMIT ollamaVisionModelChanged();
    Q_EMIT ollamaTemperatureChanged();
    Q_EMIT ollamaNumCtxChanged();
    Q_EMIT ollamaNumThreadChanged();
    Q_EMIT ollamaNumPredictChanged();
    Q_EMIT ollamaKeepAliveChanged();
    Q_EMIT systemPromptChanged();

    Q_EMIT knowledgeBaseEnabledChanged();
    Q_EMIT knowledgeBaseMaxSnippetsChanged();

    Q_EMIT panelIconStyleChanged();
    Q_EMIT pinChanged();
    Q_EMIT defaultEmailClientChanged();
    Q_EMIT defaultCalendarClientChanged();
    Q_EMIT diagnosticsChanged();
}

QStringList KcmKity::detectedModels() const
{
    return m_ollamaScanner->detectedModels();
}

bool KcmKity::ollamaChecking() const
{
    return m_ollamaScanner->isChecking();
}

bool KcmKity::ollamaReachable() const
{
    return m_ollamaScanner->isReachable();
}

bool KcmKity::whisperFound() const
{
    return AssetDiagnostics::isWhisperFound(m_cfg.whisperModelPath);
}

bool KcmKity::piperFound() const
{
    return AssetDiagnostics::isPiperFound(m_cfg.piperVoicePath);
}

// Setters
#define KCM_SETTER_IMPL(Type, Setter, Member, Signal) \
void KcmKity::Setter(Type v) { \
    if (m_cfg.Member != v) { \
        m_cfg.Member = v; \
        Q_EMIT Signal(); \
        setNeedsSave(true); \
    } \
}

KCM_SETTER_IMPL(const QString &, setSttEngine, sttEngine, sttEngineChanged)
KCM_SETTER_IMPL(bool, setWakeWordEnabled, wakeWordEnabled, wakeWordEnabledChanged)
KCM_SETTER_IMPL(bool, setContinuousConversation, continuousConversation, continuousConversationChanged)
KCM_SETTER_IMPL(const QString &, setSpeechOutputMode, speechOutputMode, speechOutputModeChanged)
KCM_SETTER_IMPL(bool, setEarconsEnabled, earconsEnabled, earconsEnabledChanged)
KCM_SETTER_IMPL(bool, setVadEnabled, vadEnabled, vadEnabledChanged)
KCM_SETTER_IMPL(int, setVadSilenceTimeoutMs, vadSilenceTimeoutMs, vadSilenceTimeoutMsChanged)
KCM_SETTER_IMPL(bool, setAutoListenOnActivate, autoListenOnActivate, autoListenOnActivateChanged)
KCM_SETTER_IMPL(bool, setUseCentralizedVoice, useCentralizedVoice, useCentralizedVoiceChanged)
KCM_SETTER_IMPL(const QString &, setWhisperLanguage, whisperLanguage, whisperLanguageChanged)

void KcmKity::setWhisperModelPath(const QString &v)
{
    if (m_cfg.whisperModelPath != v) {
        m_cfg.whisperModelPath = v;
        Q_EMIT whisperModelPathChanged();
        Q_EMIT diagnosticsChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setPiperVoicePath(const QString &v)
{
    if (m_cfg.piperVoicePath != v) {
        m_cfg.piperVoicePath = v;
        Q_EMIT piperVoicePathChanged();
        Q_EMIT diagnosticsChanged();
        setNeedsSave(true);
    }
}

KCM_SETTER_IMPL(const QString &, setTtsEngine, ttsEngine, ttsEngineChanged)
KCM_SETTER_IMPL(const QString &, setGoogleApiKey, googleApiKey, googleApiKeyChanged)
KCM_SETTER_IMPL(const QString &, setGoogleVoice, googleVoice, googleVoiceChanged)
KCM_SETTER_IMPL(const QString &, setEdgeVoice, edgeVoice, edgeVoiceChanged)
KCM_SETTER_IMPL(const QString &, setKokoroVoice, kokoroVoice, kokoroVoiceChanged)

KCM_SETTER_IMPL(const QString &, setAiBackend, aiBackend, aiBackendChanged)
KCM_SETTER_IMPL(const QString &, setGeminiModel, geminiModel, geminiModelChanged)
KCM_SETTER_IMPL(const QString &, setGeminiApiKey, geminiApiKey, geminiApiKeyChanged)

KCM_SETTER_IMPL(const QString &, setOllamaUrl, ollamaUrl, ollamaUrlChanged)
KCM_SETTER_IMPL(const QString &, setOllamaModel, ollamaModel, ollamaModelChanged)
KCM_SETTER_IMPL(const QString &, setOllamaVisionModel, ollamaVisionModel, ollamaVisionModelChanged)

void KcmKity::setOllamaTemperature(double v)
{
    if (!qFuzzyCompare(m_cfg.ollamaTemperature, v)) {
        m_cfg.ollamaTemperature = v;
        Q_EMIT ollamaTemperatureChanged();
        setNeedsSave(true);
    }
}

KCM_SETTER_IMPL(int, setOllamaNumCtx, ollamaNumCtx, ollamaNumCtxChanged)
KCM_SETTER_IMPL(int, setOllamaNumThread, ollamaNumThread, ollamaNumThreadChanged)
KCM_SETTER_IMPL(int, setOllamaNumPredict, ollamaNumPredict, ollamaNumPredictChanged)
KCM_SETTER_IMPL(const QString &, setOllamaKeepAlive, ollamaKeepAlive, ollamaKeepAliveChanged)
KCM_SETTER_IMPL(const QString &, setSystemPrompt, systemPrompt, systemPromptChanged)

KCM_SETTER_IMPL(bool, setKnowledgeBaseEnabled, knowledgeBaseEnabled, knowledgeBaseEnabledChanged)
KCM_SETTER_IMPL(int, setKnowledgeBaseMaxSnippets, knowledgeBaseMaxSnippets, knowledgeBaseMaxSnippetsChanged)

KCM_SETTER_IMPL(const QString &, setPanelIconStyle, panelIconStyle, panelIconStyleChanged)
KCM_SETTER_IMPL(bool, setPin, pin, pinChanged)
KCM_SETTER_IMPL(const QString &, setDefaultEmailClient, defaultEmailClient, defaultEmailClientChanged)
KCM_SETTER_IMPL(const QString &, setDefaultCalendarClient, defaultCalendarClient, defaultCalendarClientChanged)

KCM_SETTER_IMPL(const QString &, setVoiceAccent, voiceAccent, goldenGateChanged)

void KcmKity::setVoiceIndex(int v)
{
    const int clamped = qBound(0, v, 6);
    if (m_cfg.voiceIndex != clamped) {
        m_cfg.voiceIndex = clamped;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setVoicePace(double v)
{
    const double clamped = qBound(0.0, v, 1.0);
    if (!qFuzzyCompare(m_cfg.voicePace, clamped)) {
        m_cfg.voicePace = clamped;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setVoiceExpressivity(double v)
{
    const double clamped = qBound(0.0, v, 1.0);
    if (!qFuzzyCompare(m_cfg.voiceExpressivity, clamped)) {
        m_cfg.voiceExpressivity = clamped;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

KCM_SETTER_IMPL(const QString &, setSiriMode, siriMode, goldenGateChanged)
KCM_SETTER_IMPL(const QString &, setHistoryRetention, historyRetention, goldenGateChanged)
KCM_SETTER_IMPL(const QString &, setOpenToMode, openToMode, goldenGateChanged)

void KcmKity::setPreviewLines(int v)
{
    const int clamped = qBound(2, v, 6);
    if (m_cfg.previewLines != clamped) {
        m_cfg.previewLines = clamped;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

KCM_SETTER_IMPL(bool, setAlwaysShowRequest, alwaysShowRequest, goldenGateChanged)
KCM_SETTER_IMPL(bool, setAutoVisualLookup, autoVisualLookup, goldenGateChanged)
KCM_SETTER_IMPL(bool, setConfirmCloudRequests, confirmCloudRequests, goldenGateChanged)

void KcmKity::setSuggestionsEnabled(bool v)
{
    if (m_suggestionsEnabled != v) {
        m_suggestionsEnabled = v;
        m_cfg.suggestionsEnabled = v;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

KCM_SETTER_IMPL(const QStringList &, setExcludedApps, excludedApps, goldenGateChanged)

#undef KCM_SETTER_IMPL

void KcmKity::addExcludedApp(const QString &appName)
{
    const QString trimmed = appName.trimmed();
    if (!trimmed.isEmpty() && !m_cfg.excludedApps.contains(trimmed, Qt::CaseInsensitive)) {
        m_cfg.excludedApps.append(trimmed);
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::removeExcludedApp(const QString &appName)
{
    if (m_cfg.excludedApps.removeAll(appName) > 0) {
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::fetchModels()
{
    m_ollamaScanner->fetchModels(m_cfg.ollamaUrl, m_cfg.ollamaModel);
}

void KcmKity::checkReadiness()
{
    m_ollamaScanner->checkReadiness(m_cfg.ollamaUrl);
}

void KcmKity::previewVoice()
{
    save();
    notifyDaemon();
    m_voicePreviewEngine->previewVoice(m_cfg.voiceAccent, m_cfg.voiceIndex, m_cfg.voicePace, m_cfg.voiceExpressivity);
}

void KcmKity::openKnowledgeFolder() const
{
    const QString path = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + QStringLiteral("/kity/knowledge");
    QDir().mkpath(path);
    QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}

void KcmKity::restoreDefaultPrompt()
{
    setSystemPrompt(KityConfigData::defaultSystemPrompt());
}

void KcmKity::openShortcutsKCM() const
{
    QProcess::startDetached(QStringLiteral("kcmshell6"), {QStringLiteral("kcm_keys")});
}

void KcmKity::notifyDaemon()
{
    QDBusInterface iface(QStringLiteral("org.cesar.kity"),
                         QStringLiteral("/Kity"),
                         QStringLiteral("org.cesar.kity"),
                         QDBusConnection::sessionBus());
    if (iface.isValid()) {
        iface.call(QDBus::NoBlock, QStringLiteral("reloadConfig"));
    }
}

#include "kcm_kity.moc"
