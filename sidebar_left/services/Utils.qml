pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    function trim(text) {
        return text ? String(text).trim() : "";
    }

    function shellSingleQuoteEscape(text) {
        return trim(String(text ?? "")).replace(/'/g, "'\\''");
    }

    function normalizeBaseUrl(url) {
        const cleaned = trim(url);
        if (!cleaned) return "";
        return cleaned.endsWith("/") ? cleaned.slice(0, -1) : cleaned;
    }

    function openAiChatEndpoint(baseUrl) {
        const normalized = normalizeBaseUrl(baseUrl);
        if (!normalized) return "";
        return normalized.endsWith("/chat/completions")
            ? normalized
            : `${normalized}/chat/completions`;
    }

    function cloneMessages(messages) {
        return (messages ?? []).map(message => ({
            role: message.role,
            content: message.content
        }));
    }

    function requestJson(url, method, headers, payload, onSuccess, onError) {
        const xhr = new XMLHttpRequest();
        xhr.open(method, url);

        const headerMap = headers ?? {};
        for (const key in headerMap) {
            xhr.setRequestHeader(key, headerMap[key]);
        }

        xhr.onreadystatechange = () => {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;

            const responseText = xhr.responseText ?? "";
            const ok = xhr.status >= 200 && xhr.status < 300;

            if (!ok) {
                let detail = trim(responseText);
                if (!detail.length) {
                    detail = xhr.status > 0
                        ? `HTTP ${xhr.status}`
                        : "Network request failed";
                }
                if (onError) onError(detail);
                return;
            }

            if (!responseText.length) {
                if (onSuccess) onSuccess({});
                return;
            }

            try {
                if (onSuccess) onSuccess(JSON.parse(responseText));
            } catch (error) {
                if (onError) onError(`Invalid JSON response: ${error}`);
            }
        };

        xhr.onerror = () => {
            if (onError) onError("Network request failed");
        };

        xhr.send(payload !== undefined ? JSON.stringify(payload) : undefined);
    }

    function openAiContentToText(content) {
        if (typeof content === "string") return trim(content);
        if (Array.isArray(content)) {
            return trim(content
                .map(part => typeof part === "string" ? part : (part?.text ?? ""))
                .join("\n"));
        }
        return trim(content?.text ?? "");
    }
}
