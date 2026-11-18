/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#pragma once

#include <QNetworkAccessManager>
#include <QObject>
#include <QStringList>

class OllamaModelScanner : public QObject
{
    Q_OBJECT

public:
    explicit OllamaModelScanner(QObject *parent = nullptr);
    ~OllamaModelScanner() override;

    bool isChecking() const { return m_checking; }
    bool isReachable() const { return m_reachable; }
    QStringList detectedModels() const { return m_detectedModels; }

    void checkReadiness(const QString &rawUrl);
    void fetchModels(const QString &rawUrl, const QString &currentModel = {});

Q_SIGNALS:
    void checkingChanged(bool checking);
    void reachableChanged(bool reachable);
    void detectedModelsChanged(const QStringList &models);

private:
    QNetworkAccessManager *m_nam = nullptr;
    bool m_checking = false;
    bool m_reachable = false;
    QStringList m_detectedModels;
};
