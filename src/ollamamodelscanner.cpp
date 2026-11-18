/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#include "ollamamodelscanner.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>

OllamaModelScanner::OllamaModelScanner(QObject *parent)
    : QObject(parent)
    , m_nam(new QNetworkAccessManager(this))
{
}

OllamaModelScanner::~OllamaModelScanner() = default;

void OllamaModelScanner::checkReadiness(const QString &rawUrl)
{
    m_checking = true;
    Q_EMIT checkingChanged(m_checking);

    const QString baseUrl = rawUrl.trimmed().isEmpty() ? QStringLiteral("http://127.0.0.1:11434") : rawUrl.trimmed();
    QUrl url(baseUrl + QStringLiteral("/api/version"));
    QNetworkRequest request(url);
    request.setTransferTimeout(3000);

    QNetworkReply *reply = m_nam->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        m_checking = false;
        m_reachable = (reply->error() == QNetworkReply::NoError);
        Q_EMIT checkingChanged(m_checking);
        Q_EMIT reachableChanged(m_reachable);
    });
}

void OllamaModelScanner::fetchModels(const QString &rawUrl, const QString &currentModel)
{
    const QString baseUrl = rawUrl.trimmed().isEmpty() ? QStringLiteral("http://127.0.0.1:11434") : rawUrl.trimmed();
    QUrl url(baseUrl + QStringLiteral("/api/tags"));
    QNetworkRequest request(url);
    request.setTransferTimeout(4000);

    QNetworkReply *reply = m_nam->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, currentModel]() {
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
                    if (!currentModel.isEmpty() && !list.contains(currentModel)) {
                        list.prepend(currentModel);
                    }
                    m_detectedModels = list;
                    Q_EMIT detectedModelsChanged(m_detectedModels);
                }
            }
        }
    });
}
