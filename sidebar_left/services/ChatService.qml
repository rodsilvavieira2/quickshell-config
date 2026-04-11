pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var messages: []
    property bool busy: false
    property string error: ""
    property string systemPrompt: "You are a concise desktop sidebar assistant. Use Markdown when it helps, but keep answers readable in a narrow panel."

    function clearMessages() {
        root.messages = [];
        root.error = "";
    }

    function sendUserMessage(text) {
        const cleaned = Utils.trim(text);
        if (!cleaned.length || busy) return;

        root.error = "";
        root.messages = [...root.messages, buildMessage("user", cleaned)];
        const requestMessages = Utils.cloneMessages(root.messages);
        root.busy = true;

        if (SidebarState.provider === "gemini_cli") {
            requestGeminiCli(requestMessages);
        } else if (SidebarState.provider === "openai_compatible") {
            requestOpenAi(requestMessages);
        } else {
            requestOllama(requestMessages);
        }
    }

    function buildMessage(role, content) {
        return {
            id: Date.now() + Math.random(),
            role: role,
            content: content
        };
    }

    function fail(message) {
        root.busy = false;
        root.error = message;
    }

    function succeed(content) {
        const cleaned = Utils.trim(content);
        root.busy = false;
        root.error = "";
        root.messages = [...root.messages, buildMessage("assistant", cleaned.length ? cleaned : "No response returned.")];
    }

    function messagePayload(includeSystem) {
        const payload = Utils.cloneMessages(root.messages);
        if (includeSystem && Utils.trim(root.systemPrompt).length > 0) {
            payload.unshift({
                role: "system",
                content: root.systemPrompt
            });
        }
        return payload;
    }

    function requestOllama() {
        Utils.requestJson(
            "http://127.0.0.1:11434/api/chat",
            "POST",
            { "Content-Type": "application/json" },
            {
                model: SidebarState.activeModel(),
                messages: messagePayload(true),
                stream: false
            },
            response => {
                succeed(response?.message?.content ?? response?.response ?? "");
            },
            detail => {
                fail(`Ollama request failed: ${detail}`);
            }
        );
    }

    function requestOpenAi() {
        const endpoint = Utils.openAiChatEndpoint(SidebarState.openAiBaseUrl);
        const apiKey = Utils.trim(SidebarState.openAiApiKey);

        if (!endpoint.length || !apiKey.length) {
            fail("OpenAI-compatible requests need a base URL and API key.");
            return;
        }

        Utils.requestJson(
            endpoint,
            "POST",
            {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${apiKey}`
            },
            {
                model: SidebarState.activeModel(),
                messages: messagePayload(true),
                temperature: 0.5
            },
            response => {
                const choice = response?.choices?.[0]?.message?.content;
                succeed(Utils.openAiContentToText(choice));
            },
            detail => {
                fail(`OpenAI-compatible request failed: ${detail}`);
            }
        );
    }

    function requestGeminiCli() {
        geminiChatProc.stdoutBuffer = "";
        geminiChatProc.stderrBuffer = "";
        geminiChatProc.command = [
            "gemini",
            "--model", SidebarState.activeModel(),
            "--prompt", geminiPrompt(),
            "--output-format", "text"
        ];
        geminiChatProc.running = true;
    }

    function geminiPrompt() {
        const lines = [];
        lines.push(root.systemPrompt);
        lines.push("");
        lines.push("Continue this conversation. Respond only as the assistant.");
        lines.push("");

        for (const message of root.messages) {
            lines.push(`${message.role === "assistant" ? "Assistant" : "User"}: ${message.content}`);
        }

        lines.push("Assistant:");
        return lines.join("\n");
    }

    Process {
        id: geminiChatProc

        property string stdoutBuffer: ""
        property string stderrBuffer: ""

        stdout: SplitParser {
            onRead: data => {
                geminiChatProc.stdoutBuffer += data + "\n";
            }
        }

        stderr: SplitParser {
            onRead: data => {
                geminiChatProc.stderrBuffer += data + "\n";
            }
        }

        onExited: exitCode => {
            if (exitCode === 0) {
                succeed(geminiChatProc.stdoutBuffer);
            } else {
                const detail = Utils.trim(geminiChatProc.stderrBuffer) || "Gemini CLI exited with a non-zero status.";
                fail(`Gemini CLI request failed: ${detail}`);
            }
        }
    }
}
