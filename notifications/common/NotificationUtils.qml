pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    function processNotificationBody(bodyText, fallbackTitle) {
        const text = bodyText && bodyText.length > 0 ? bodyText : (fallbackTitle ? fallbackTitle : "")
        return text
    }

    function getFriendlyNotifTimeString(timeMs) {
        if (!timeMs || timeMs <= 0) return ""
        const now = Date.now()
        const diff = Math.max(0, now - timeMs)
        const seconds = Math.floor(diff / 1000)
        const minutes = Math.floor(seconds / 60)
        const hours = Math.floor(minutes / 60)
        const days = Math.floor(hours / 24)

        if (seconds < 60) return `${seconds}s`
        if (minutes < 60) return `${minutes}m`
        if (hours < 24) return `${hours}h`
        return `${days}d`
    }
}
