/*
    SPDX-FileCopyrightText: 2026 Kity contributors
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#pragma once

#include <QString>

class AssetDiagnostics
{
public:
    static bool isWhisperFound(const QString &whisperModelPath);
    static bool isPiperFound(const QString &piperVoicePath);
};
