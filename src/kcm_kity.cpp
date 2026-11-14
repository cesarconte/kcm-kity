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
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QProcess>
#include <QStandardPaths>
#include <QUrl>

K_PLUGIN_CLASS_WITH_JSON(KcmKity, "kcm_kity.json")

static const QString defaultSystemPrompt()
{
    return QStringLiteral(
        "Eres Kity, un asistente de voz e inteligencia artificial nativo para KDE Plasma en CachyOS Linux. "
        "Responde SIEMPRE en español de España (castellano), de forma concisa, clara, directa y natural, "
        "optimizada para síntesis de voz (TTS).");
}

KcmKity::KcmKity(QObject *parent, const KPluginMetaData &data)
    : KQuickConfigModule(parent, data)
    , m_nam(new QNetworkAccessManager(this))
    , m_systemPrompt(defaultSystemPrompt())
{
    setButtons(KAbstractConfigModule::Apply | KAbstractConfigModule::Default);
}

KcmKity::~KcmKity() = default;

void KcmKity::load()
{
    KSharedConfig::Ptr config = KSharedConfig::openConfig(QStringLiteral("kityrc"));
    KConfigGroup cfg = config->group(QStringLiteral("General"));

    m_wakeWordEnabled = cfg.readEntry(QStringLiteral("wakeWordEnabled"), true);
    m_speechOutputMode = cfg.readEntry(QStringLiteral("speechOutputMode"), QStringLiteral("always"));
    m_earconsEnabled = cfg.readEntry(QStringLiteral("earconsEnabled"), true);
    m_vadEnabled = cfg.readEntry(QStringLiteral("vadEnabled"), true);
    m_vadSilenceTimeoutMs = cfg.readEntry(QStringLiteral("vadSilenceTimeoutMs"), 1300);
    m_autoListenOnActivate = cfg.readEntry(QStringLiteral("autoListenOnActivate"), false);
    m_whisperLanguage = cfg.readEntry(QStringLiteral("whisperLanguage"), QStringLiteral("es"));
    m_whisperModelPath = cfg.readEntry(QStringLiteral("whisperModelPath"), QString());
    m_piperVoicePath = cfg.readEntry(QStringLiteral("piperVoicePath"), QString());
    m_ttsEngine = cfg.readEntry(QStringLiteral("ttsEngine"), QStringLiteral("google"));
    m_googleApiKey = cfg.readEntry(QStringLiteral("googleApiKey"), QString());
    m_googleVoice = cfg.readEntry(QStringLiteral("googleVoice"), QStringLiteral("es-ES-Neural2-F"));
    m_edgeVoice = cfg.readEntry(QStringLiteral("edgeVoice"), QStringLiteral("es-ES-ElviraNeural"));
    m_kokoroVoice = cfg.readEntry(QStringLiteral("kokoroVoice"), QStringLiteral("ef_dora"));

    m_aiBackend = cfg.readEntry(QStringLiteral("aiBackend"), QStringLiteral("hybrid"));
    m_geminiModel = cfg.readEntry(QStringLiteral("geminiModel"), QStringLiteral("gemini-2.0-flash"));
    m_geminiApiKey = cfg.readEntry(QStringLiteral("geminiApiKey"), QString());

    m_ollamaUrl = cfg.readEntry(QStringLiteral("ollamaUrl"), QStringLiteral("http://127.0.0.1:11434"));
    m_ollamaModel = cfg.readEntry(QStringLiteral("ollamaModel"), QStringLiteral("llama3.2:3b"));
    m_ollamaVisionModel = cfg.readEntry(QStringLiteral("ollamaVisionModel"), QStringLiteral("llama3.2:3b"));
    if (m_ollamaVisionModel == QLatin1String("moondream")) {
        m_ollamaVisionModel = QStringLiteral("llama3.2:3b");
    }
    m_ollamaTemperature = cfg.readEntry(QStringLiteral("ollamaTemperature"), 0.2);
    m_ollamaNumCtx = cfg.readEntry(QStringLiteral("ollamaNumCtx"), 4096);
    m_ollamaNumThread = cfg.readEntry(QStringLiteral("ollamaNumThread"), 6);
    m_ollamaNumPredict = cfg.readEntry(QStringLiteral("ollamaNumPredict"), 384);
    m_ollamaKeepAlive = cfg.readEntry(QStringLiteral("ollamaKeepAlive"), QStringLiteral("24h"));
    m_systemPrompt = cfg.readEntry(QStringLiteral("systemPrompt"), defaultSystemPrompt());

    m_knowledgeBaseEnabled = cfg.readEntry(QStringLiteral("knowledgeBaseEnabled"), true);
    m_knowledgeBaseMaxSnippets = cfg.readEntry(QStringLiteral("knowledgeBaseMaxSnippets"), 3);

    m_panelIconStyle = cfg.readEntry(QStringLiteral("panelIconStyle"), QStringLiteral("symbolic"));
    m_pin = cfg.readEntry(QStringLiteral("pin"), false);
    m_defaultEmailClient = cfg.readEntry(QStringLiteral("defaultEmailClient"), QStringLiteral("proton"));
    m_defaultCalendarClient = cfg.readEntry(QStringLiteral("defaultCalendarClient"), QStringLiteral("proton"));

    m_voiceAccent = cfg.readEntry(QStringLiteral("voiceAccent"), QStringLiteral("Spanish (Spain)"));
    m_voiceIndex = cfg.readEntry(QStringLiteral("voiceIndex"), 3);
    m_voicePace = cfg.readEntry(QStringLiteral("voicePace"), 0.55);
    m_voiceExpressivity = cfg.readEntry(QStringLiteral("voiceExpressivity"), 0.65);
    m_siriMode = cfg.readEntry(QStringLiteral("siriMode"), QStringLiteral("ai"));
    m_historyRetention = cfg.readEntry(QStringLiteral("historyRetention"), QStringLiteral("forever"));
    m_openToMode = cfg.readEntry(QStringLiteral("openToMode"), QStringLiteral("past"));
    m_previewLines = cfg.readEntry(QStringLiteral("previewLines"), 4);
    m_alwaysShowRequest = cfg.readEntry(QStringLiteral("alwaysShowRequest"), true);
    m_autoVisualLookup = cfg.readEntry(QStringLiteral("autoVisualLookup"), true);
    m_confirmCloudRequests = cfg.readEntry(QStringLiteral("confirmCloudRequests"), false);
    m_suggestionsEnabled = cfg.readEntry(QStringLiteral("suggestionsEnabled"), true);
    m_excludedApps = cfg.readEntry(QStringLiteral("excludedApps"), QStringList());

    Q_EMIT goldenGateChanged();
    Q_EMIT wakeWordEnabledChanged();
    Q_EMIT speechOutputModeChanged();
    Q_EMIT earconsEnabledChanged();
    Q_EMIT vadEnabledChanged();
    Q_EMIT vadSilenceTimeoutMsChanged();
    Q_EMIT autoListenOnActivateChanged();
    Q_EMIT whisperLanguageChanged();
    Q_EMIT whisperModelPathChanged();
    Q_EMIT piperVoicePathChanged();
    Q_EMIT ttsEngineChanged();
    Q_EMIT googleApiKeyChanged();
    Q_EMIT googleVoiceChanged();
    Q_EMIT edgeVoiceChanged();
    Q_EMIT kokoroVoiceChanged();

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

    setNeedsSave(false);

    checkReadiness();
    fetchModels();
}

void KcmKity::save()
{
    KSharedConfig::Ptr config = KSharedConfig::openConfig(QStringLiteral("kityrc"));
    KConfigGroup cfg = config->group(QStringLiteral("General"));

    cfg.writeEntry(QStringLiteral("wakeWordEnabled"), m_wakeWordEnabled);
    cfg.writeEntry(QStringLiteral("speechOutputMode"), m_speechOutputMode);
    cfg.writeEntry(QStringLiteral("earconsEnabled"), m_earconsEnabled);
    cfg.writeEntry(QStringLiteral("vadEnabled"), m_vadEnabled);
    cfg.writeEntry(QStringLiteral("vadSilenceTimeoutMs"), m_vadSilenceTimeoutMs);
    cfg.writeEntry(QStringLiteral("autoListenOnActivate"), m_autoListenOnActivate);
    cfg.writeEntry(QStringLiteral("whisperLanguage"), m_whisperLanguage);
    cfg.writeEntry(QStringLiteral("whisperModelPath"), m_whisperModelPath);
    cfg.writeEntry(QStringLiteral("piperVoicePath"), m_piperVoicePath);
    cfg.writeEntry(QStringLiteral("ttsEngine"), m_ttsEngine);
    cfg.writeEntry(QStringLiteral("googleApiKey"), m_googleApiKey);
    cfg.writeEntry(QStringLiteral("googleVoice"), m_googleVoice);
    cfg.writeEntry(QStringLiteral("edgeVoice"), m_edgeVoice);
    cfg.writeEntry(QStringLiteral("kokoroVoice"), m_kokoroVoice);

    cfg.writeEntry(QStringLiteral("aiBackend"), m_aiBackend);
    cfg.writeEntry(QStringLiteral("geminiModel"), m_geminiModel);
    cfg.writeEntry(QStringLiteral("geminiApiKey"), m_geminiApiKey);

    cfg.writeEntry(QStringLiteral("ollamaUrl"), m_ollamaUrl);
    cfg.writeEntry(QStringLiteral("ollamaModel"), m_ollamaModel);
    cfg.writeEntry(QStringLiteral("ollamaVisionModel"), m_ollamaVisionModel);
    cfg.writeEntry(QStringLiteral("ollamaTemperature"), m_ollamaTemperature);
    cfg.writeEntry(QStringLiteral("ollamaNumCtx"), m_ollamaNumCtx);
    cfg.writeEntry(QStringLiteral("ollamaNumThread"), m_ollamaNumThread);
    cfg.writeEntry(QStringLiteral("ollamaNumPredict"), m_ollamaNumPredict);
    cfg.writeEntry(QStringLiteral("ollamaKeepAlive"), m_ollamaKeepAlive);
    cfg.writeEntry(QStringLiteral("systemPrompt"), m_systemPrompt);

    cfg.writeEntry(QStringLiteral("knowledgeBaseEnabled"), m_knowledgeBaseEnabled);
    cfg.writeEntry(QStringLiteral("knowledgeBaseMaxSnippets"), m_knowledgeBaseMaxSnippets);

    cfg.writeEntry(QStringLiteral("panelIconStyle"), m_panelIconStyle);
    cfg.writeEntry(QStringLiteral("pin"), m_pin);
    cfg.writeEntry(QStringLiteral("defaultEmailClient"), m_defaultEmailClient);
    cfg.writeEntry(QStringLiteral("defaultCalendarClient"), m_defaultCalendarClient);

    cfg.writeEntry(QStringLiteral("voiceAccent"), m_voiceAccent);
    cfg.writeEntry(QStringLiteral("voiceIndex"), m_voiceIndex);
    cfg.writeEntry(QStringLiteral("voicePace"), m_voicePace);
    cfg.writeEntry(QStringLiteral("voiceExpressivity"), m_voiceExpressivity);
    cfg.writeEntry(QStringLiteral("siriMode"), m_siriMode);
    cfg.writeEntry(QStringLiteral("historyRetention"), m_historyRetention);
    cfg.writeEntry(QStringLiteral("openToMode"), m_openToMode);
    cfg.writeEntry(QStringLiteral("previewLines"), m_previewLines);
    cfg.writeEntry(QStringLiteral("alwaysShowRequest"), m_alwaysShowRequest);
    cfg.writeEntry(QStringLiteral("autoVisualLookup"), m_autoVisualLookup);
    cfg.writeEntry(QStringLiteral("confirmCloudRequests"), m_confirmCloudRequests);
    cfg.writeEntry(QStringLiteral("suggestionsEnabled"), m_suggestionsEnabled);
    cfg.writeEntry(QStringLiteral("excludedApps"), m_excludedApps);

    cfg.sync();

    notifyDaemon();
    setNeedsSave(false);
}

void KcmKity::defaults()
{
    setWakeWordEnabled(true);
    setSpeechOutputMode(QStringLiteral("always"));
    setEarconsEnabled(true);
    setVadEnabled(true);
    setVadSilenceTimeoutMs(1300);
    setAutoListenOnActivate(false);
    setWhisperLanguage(QStringLiteral("es"));
    setWhisperModelPath(QString());
    setPiperVoicePath(QString());
    setTtsEngine(QStringLiteral("google"));
    setGoogleApiKey(QString());
    setGoogleVoice(QStringLiteral("es-ES-Neural2-F"));
    setEdgeVoice(QStringLiteral("es-ES-ElviraNeural"));
    setKokoroVoice(QStringLiteral("ef_dora"));

    setAiBackend(QStringLiteral("hybrid"));
    setGeminiModel(QStringLiteral("gemini-2.0-flash"));
    setGeminiApiKey(QString());

    setOllamaUrl(QStringLiteral("http://127.0.0.1:11434"));
    setOllamaModel(QStringLiteral("llama3.2:3b"));
    setOllamaVisionModel(QStringLiteral("llama3.2:3b"));
    setOllamaTemperature(0.2);
    setOllamaNumCtx(4096);
    setOllamaNumThread(6);
    setOllamaNumPredict(384);
    setOllamaKeepAlive(QStringLiteral("24h"));
    setSystemPrompt(defaultSystemPrompt());

    setKnowledgeBaseEnabled(true);
    setKnowledgeBaseMaxSnippets(3);

    setPanelIconStyle(QStringLiteral("symbolic"));
    setPin(false);
    setDefaultEmailClient(QStringLiteral("proton"));
    setDefaultCalendarClient(QStringLiteral("proton"));

    setNeedsSave(true);
}

void KcmKity::setWakeWordEnabled(bool v)
{
    if (m_wakeWordEnabled != v) {
        m_wakeWordEnabled = v;
        Q_EMIT wakeWordEnabledChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setSpeechOutputMode(const QString &v)
{
    if (m_speechOutputMode != v) {
        m_speechOutputMode = v;
        Q_EMIT speechOutputModeChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setEarconsEnabled(bool v)
{
    if (m_earconsEnabled != v) {
        m_earconsEnabled = v;
        Q_EMIT earconsEnabledChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setVadEnabled(bool v)
{
    if (m_vadEnabled != v) {
        m_vadEnabled = v;
        Q_EMIT vadEnabledChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setVadSilenceTimeoutMs(int v)
{
    if (m_vadSilenceTimeoutMs != v) {
        m_vadSilenceTimeoutMs = v;
        Q_EMIT vadSilenceTimeoutMsChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setAutoListenOnActivate(bool v)
{
    if (m_autoListenOnActivate != v) {
        m_autoListenOnActivate = v;
        Q_EMIT autoListenOnActivateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setWhisperLanguage(const QString &v)
{
    if (m_whisperLanguage != v) {
        m_whisperLanguage = v;
        Q_EMIT whisperLanguageChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setWhisperModelPath(const QString &v)
{
    if (m_whisperModelPath != v) {
        m_whisperModelPath = v;
        Q_EMIT whisperModelPathChanged();
        Q_EMIT diagnosticsChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setPiperVoicePath(const QString &v)
{
    if (m_piperVoicePath != v) {
        m_piperVoicePath = v;
        Q_EMIT piperVoicePathChanged();
        Q_EMIT diagnosticsChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setOllamaUrl(const QString &v)
{
    if (m_ollamaUrl != v) {
        m_ollamaUrl = v;
        Q_EMIT ollamaUrlChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setOllamaModel(const QString &v)
{
    if (m_ollamaModel != v) {
        m_ollamaModel = v;
        Q_EMIT ollamaModelChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setOllamaVisionModel(const QString &v)
{
    if (m_ollamaVisionModel != v) {
        m_ollamaVisionModel = v;
        Q_EMIT ollamaVisionModelChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setOllamaTemperature(double v)
{
    if (!qFuzzyCompare(m_ollamaTemperature, v)) {
        m_ollamaTemperature = v;
        Q_EMIT ollamaTemperatureChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setOllamaNumCtx(int v)
{
    if (m_ollamaNumCtx != v) {
        m_ollamaNumCtx = v;
        Q_EMIT ollamaNumCtxChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setOllamaNumThread(int v)
{
    if (m_ollamaNumThread != v) {
        m_ollamaNumThread = v;
        Q_EMIT ollamaNumThreadChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setOllamaNumPredict(int v)
{
    if (m_ollamaNumPredict != v) {
        m_ollamaNumPredict = v;
        Q_EMIT ollamaNumPredictChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setOllamaKeepAlive(const QString &v)
{
    if (m_ollamaKeepAlive != v) {
        m_ollamaKeepAlive = v;
        Q_EMIT ollamaKeepAliveChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setSystemPrompt(const QString &v)
{
    if (m_systemPrompt != v) {
        m_systemPrompt = v;
        Q_EMIT systemPromptChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setKnowledgeBaseEnabled(bool v)
{
    if (m_knowledgeBaseEnabled != v) {
        m_knowledgeBaseEnabled = v;
        Q_EMIT knowledgeBaseEnabledChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setKnowledgeBaseMaxSnippets(int v)
{
    if (m_knowledgeBaseMaxSnippets != v) {
        m_knowledgeBaseMaxSnippets = v;
        Q_EMIT knowledgeBaseMaxSnippetsChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setPanelIconStyle(const QString &v)
{
    if (m_panelIconStyle != v) {
        m_panelIconStyle = v;
        Q_EMIT panelIconStyleChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setPin(bool v)
{
    if (m_pin != v) {
        m_pin = v;
        Q_EMIT pinChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setDefaultEmailClient(const QString &v)
{
    if (m_defaultEmailClient != v) {
        m_defaultEmailClient = v;
        Q_EMIT defaultEmailClientChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setDefaultCalendarClient(const QString &v)
{
    if (m_defaultCalendarClient != v) {
        m_defaultCalendarClient = v;
        Q_EMIT defaultCalendarClientChanged();
        setNeedsSave(true);
    }
}

bool KcmKity::whisperFound() const
{
    if (!m_whisperModelPath.isEmpty() && QFile::exists(m_whisperModelPath)) {
        return true;
    }
    QStringList dataDirs = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
    if (!dataDirs.contains(QStringLiteral("/usr/share"))) {
        dataDirs.append(QStringLiteral("/usr/share"));
    }
    for (const QString &base : dataDirs) {
        QDir dir(base + QStringLiteral("/kity/models"));
        if (!dir.entryList(QStringList() << QStringLiteral("*.bin"), QDir::Files).isEmpty()) {
            return true;
        }
    }
    return false;
}

bool KcmKity::piperFound() const
{
    if (!m_piperVoicePath.isEmpty() && QFile::exists(m_piperVoicePath)) {
        return true;
    }
    QStringList dataDirs = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
    if (!dataDirs.contains(QStringLiteral("/usr/share"))) {
        dataDirs.append(QStringLiteral("/usr/share"));
    }
    for (const QString &base : dataDirs) {
        QDir dir(base + QStringLiteral("/kity/voices"));
        if (!dir.entryList(QStringList() << QStringLiteral("*.onnx"), QDir::Files).isEmpty()) {
            return true;
        }
    }
    return false;
}

void KcmKity::fetchModels()
{
    const QString baseUrl = m_ollamaUrl.trimmed().isEmpty() ? QStringLiteral("http://127.0.0.1:11434") : m_ollamaUrl.trimmed();
    QUrl url(baseUrl + QStringLiteral("/api/tags"));
    QNetworkRequest request(url);
    request.setTransferTimeout(4000);

    QNetworkReply *reply = m_nam->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() == QNetworkReply::NoError) {
            const QByteArray data = reply->readAll();
            const QJsonDocument doc = QJsonDocument::fromJson(data);
            if (doc.isObject()) {
                const QJsonArray arr = doc.object().value(QStringLiteral("models")).toArray();
                QStringList list;
                for (const QJsonValue &v : arr) {
                    const QString name = v.toObject().value(QStringLiteral("name")).toString();
                    if (!name.isEmpty()) {
                        list.append(name);
                    }
                }
                if (!list.isEmpty()) {
                    if (!m_ollamaModel.isEmpty() && !list.contains(m_ollamaModel)) {
                        list.prepend(m_ollamaModel);
                    }
                    m_detectedModels = list;
                    Q_EMIT detectedModelsChanged();
                    Q_EMIT diagnosticsChanged();
                }
            }
        }
    });
}

void KcmKity::checkReadiness()
{
    m_ollamaChecking = true;
    Q_EMIT ollamaCheckingChanged();

    const QString baseUrl = m_ollamaUrl.trimmed().isEmpty() ? QStringLiteral("http://127.0.0.1:11434") : m_ollamaUrl.trimmed();
    QUrl url(baseUrl + QStringLiteral("/api/version"));
    QNetworkRequest request(url);
    request.setTransferTimeout(3000);

    QNetworkReply *reply = m_nam->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        m_ollamaChecking = false;
        m_ollamaReachable = (reply->error() == QNetworkReply::NoError);
        Q_EMIT ollamaCheckingChanged();
        Q_EMIT ollamaReachableChanged();
        Q_EMIT diagnosticsChanged();
    });
}

void KcmKity::openKnowledgeFolder() const
{
    const QString path = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + QStringLiteral("/kity/knowledge");
    QDir().mkpath(path);
    QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}

void KcmKity::restoreDefaultPrompt()
{
    setSystemPrompt(defaultSystemPrompt());
}

void KcmKity::setTtsEngine(const QString &v)
{
    if (m_ttsEngine != v) {
        m_ttsEngine = v;
        Q_EMIT ttsEngineChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setGoogleApiKey(const QString &v)
{
    if (m_googleApiKey != v) {
        m_googleApiKey = v;
        Q_EMIT googleApiKeyChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setGoogleVoice(const QString &v)
{
    if (m_googleVoice != v) {
        m_googleVoice = v;
        Q_EMIT googleVoiceChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setEdgeVoice(const QString &v)
{
    if (m_edgeVoice != v) {
        m_edgeVoice = v;
        Q_EMIT edgeVoiceChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setKokoroVoice(const QString &v)
{
    if (m_kokoroVoice != v) {
        m_kokoroVoice = v;
        Q_EMIT kokoroVoiceChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setAiBackend(const QString &v)
{
    if (m_aiBackend != v) {
        m_aiBackend = v;
        Q_EMIT aiBackendChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setGeminiModel(const QString &v)
{
    if (m_geminiModel != v) {
        m_geminiModel = v;
        Q_EMIT geminiModelChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setGeminiApiKey(const QString &v)
{
    if (m_geminiApiKey != v) {
        m_geminiApiKey = v;
        Q_EMIT geminiApiKeyChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setVoiceAccent(const QString &v)
{
    if (m_voiceAccent != v) {
        m_voiceAccent = v;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setVoiceIndex(int v)
{
    const int clamped = qBound(0, v, 6);
    if (m_voiceIndex != clamped) {
        m_voiceIndex = clamped;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setVoicePace(double v)
{
    const double clamped = qBound(0.0, v, 1.0);
    if (!qFuzzyCompare(m_voicePace, clamped)) {
        m_voicePace = clamped;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setVoiceExpressivity(double v)
{
    const double clamped = qBound(0.0, v, 1.0);
    if (!qFuzzyCompare(m_voiceExpressivity, clamped)) {
        m_voiceExpressivity = clamped;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setSiriMode(const QString &v)
{
    if (m_siriMode != v) {
        m_siriMode = v;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setHistoryRetention(const QString &v)
{
    if (m_historyRetention != v) {
        m_historyRetention = v;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setOpenToMode(const QString &v)
{
    if (m_openToMode != v) {
        m_openToMode = v;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setPreviewLines(int v)
{
    const int clamped = qBound(2, v, 6);
    if (m_previewLines != clamped) {
        m_previewLines = clamped;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setAlwaysShowRequest(bool v)
{
    if (m_alwaysShowRequest != v) {
        m_alwaysShowRequest = v;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setAutoVisualLookup(bool v)
{
    if (m_autoVisualLookup != v) {
        m_autoVisualLookup = v;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setConfirmCloudRequests(bool v)
{
    if (m_confirmCloudRequests != v) {
        m_confirmCloudRequests = v;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setSuggestionsEnabled(bool v)
{
    if (m_suggestionsEnabled != v) {
        m_suggestionsEnabled = v;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::setExcludedApps(const QStringList &v)
{
    if (m_excludedApps != v) {
        m_excludedApps = v;
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::addExcludedApp(const QString &appName)
{
    const QString trimmed = appName.trimmed();
    if (!trimmed.isEmpty() && !m_excludedApps.contains(trimmed, Qt::CaseInsensitive)) {
        m_excludedApps.append(trimmed);
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::removeExcludedApp(const QString &appName)
{
    if (m_excludedApps.removeAll(appName) > 0) {
        Q_EMIT goldenGateChanged();
        setNeedsSave(true);
    }
}

void KcmKity::previewVoice()
{
    save();
    const QString edgeCli = QStandardPaths::findExecutable(QStringLiteral("kity-edge-tts"));
    const QString pwPlay = QStandardPaths::findExecutable(QStringLiteral("pw-play"));
    if (edgeCli.isEmpty() || pwPlay.isEmpty()) {
        return;
    }

    auto resolveEdgeVoiceForOrb = [](const QString &accent, int idx) -> QString {
        if (accent.contains(QLatin1String("Latin"), Qt::CaseInsensitive)) {
            static const QStringList voices = {
                QStringLiteral("es-MX-DaliaNeural"), QStringLiteral("es-MX-JorgeNeural"),
                QStringLiteral("es-CO-SalomeNeural"), QStringLiteral("es-MX-BeatrizNeural"),
                QStringLiteral("es-AR-ElenaNeural"), QStringLiteral("es-CL-CatalinaNeural"),
                QStringLiteral("es-US-PalomaNeural")
            };
            return voices.value(idx, voices.at(3));
        }
        if (accent.contains(QLatin1String("American"), Qt::CaseInsensitive)) {
            static const QStringList voices = {
                QStringLiteral("en-US-AvaNeural"), QStringLiteral("en-US-AndrewNeural"),
                QStringLiteral("en-US-EmmaNeural"), QStringLiteral("en-US-AriaNeural"),
                QStringLiteral("en-US-BrianNeural"), QStringLiteral("en-US-JennyNeural"),
                QStringLiteral("en-US-GuyNeural")
            };
            return voices.value(idx, voices.at(3));
        }
        if (accent.contains(QLatin1String("British"), Qt::CaseInsensitive)) {
            static const QStringList voices = {
                QStringLiteral("en-GB-SoniaNeural"), QStringLiteral("en-GB-RyanNeural"),
                QStringLiteral("en-GB-LibbyNeural"), QStringLiteral("en-GB-MaisieNeural"),
                QStringLiteral("en-GB-ThomasNeural"), QStringLiteral("en-GB-AbbiNeural"),
                QStringLiteral("en-GB-OllieNeural")
            };
            return voices.value(idx, voices.at(3));
        }
        static const QStringList esVoices = {
            QStringLiteral("es-ES-AlvaroNeural"), QStringLiteral("es-ES-AbrilNeural"),
            QStringLiteral("es-ES-ArnauNeural"), QStringLiteral("es-ES-ElviraNeural"),
            QStringLiteral("es-ES-EstrellaNeural"), QStringLiteral("es-ES-DarioNeural"),
            QStringLiteral("es-ES-XimenaNeural")
        };
        return esVoices.value(idx, esVoices.at(3));
    };

    const QString voice = resolveEdgeVoiceForOrb(m_voiceAccent, qBound(0, m_voiceIndex, 6));
    const int ratePct = qRound((m_voicePace - 0.5) * 80.0);
    const int pitchHz = qRound((m_voiceExpressivity - 0.5) * 28.0);
    const QString rateArg = QStringLiteral("--rate=%1%2%").arg(ratePct >= 0 ? QStringLiteral("+") : QString()).arg(ratePct);
    const QString pitchArg = QStringLiteral("--pitch=%1%2Hz").arg(pitchHz >= 0 ? QStringLiteral("+") : QString()).arg(pitchHz);
    const QString sampleText = (m_voiceAccent.contains(QLatin1String("American"), Qt::CaseInsensitive)
                                || m_voiceAccent.contains(QLatin1String("British"), Qt::CaseInsensitive))
        ? QStringLiteral("Hello, I'm Kity in macOS Golden Gate. You can customize my voice, pace, and expressivity.")
        : QStringLiteral("Hola, soy Kity en macOS Golden Gate. Puedes ajustar mi voz, ritmo y expresividad a tu gusto.");

    auto *ttsProc = new QProcess(this);
    auto *playProc = new QProcess(this);
    ttsProc->setStandardOutputProcess(playProc);
    connect(playProc, &QProcess::finished, this, [ttsProc, playProc](int, QProcess::ExitStatus) {
        playProc->deleteLater();
        ttsProc->deleteLater();
    });
    ttsProc->start(edgeCli, {QStringLiteral("--voice"), voice, rateArg, pitchArg, QStringLiteral("--text"), sampleText, QStringLiteral("--write-media"), QStringLiteral("-")});
    playProc->start(pwPlay, {QStringLiteral("-")});
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
