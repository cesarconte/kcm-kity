/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#include "assetdiagnostics.h"

#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QStringList>

bool AssetDiagnostics::isWhisperFound(const QString &whisperModelPath)
{
    if (!whisperModelPath.isEmpty() && QFile::exists(whisperModelPath)) {
        return true;
    }
    QStringList dataDirs = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
    if (!dataDirs.contains(QStringLiteral("/usr/share"))) {
        dataDirs.append(QStringLiteral("/usr/share"));
    }
    for (const QString &base : std::as_const(dataDirs)) {
        QDir dir(base + QStringLiteral("/kity/models"));
        if (!dir.entryList(QStringList() << QStringLiteral("*.bin"), QDir::Files).isEmpty()) {
            return true;
        }
    }
    return false;
}

bool AssetDiagnostics::isPiperFound(const QString &piperVoicePath)
{
    if (!piperVoicePath.isEmpty() && QFile::exists(piperVoicePath)) {
        return true;
    }
    QStringList dataDirs = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
    if (!dataDirs.contains(QStringLiteral("/usr/share"))) {
        dataDirs.append(QStringLiteral("/usr/share"));
    }
    for (const QString &base : std::as_const(dataDirs)) {
        QDir dir(base + QStringLiteral("/kity/voices"));
        if (!dir.entryList(QStringList() << QStringLiteral("*.onnx"), QDir::Files).isEmpty()) {
            return true;
        }
    }
    return false;
}
