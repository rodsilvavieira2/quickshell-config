import QtQuick

QtObject {
    id: root

    readonly property var categories: [
        {
            id: "appearance",
            label: "Appearance",
            iconName: "palette",
            keywords: ["theme", "accent", "font", "scale", "dark", "light", "gtk"],
            pageSource: Qt.resolvedUrl("../pages/AppearancePage.qml"),
            entries: [
                { id: "mode", label: "Light and dark mode", description: "Switch shell appearance mode", keywords: ["dark", "light", "mode"] },
                { id: "accent", label: "Accent color", description: "Set the desktop accent seed", keywords: ["accent", "color", "seed"] },
                { id: "font", label: "Fonts", description: "Choose shell and GTK typography", keywords: ["font", "typography", "gtk"] }
            ]
        },
        {
            id: "wallpaper",
            label: "Wallpaper",
            iconName: "image",
            keywords: ["wallpaper", "background", "image"],
            pageSource: Qt.resolvedUrl("../pages/WallpaperPage.qml"),
            entries: [
                { id: "current", label: "Current wallpaper", description: "Review the active wallpaper", keywords: ["current", "wallpaper"] },
                { id: "picker", label: "Wallpaper picker", description: "Choose or search new wallpapers", keywords: ["picker", "search", "background"] }
            ]
        },
        {
            id: "displays",
            label: "Displays",
            iconName: "monitor",
            keywords: ["monitor", "display", "resolution", "scale", "refresh"],
            pageSource: Qt.resolvedUrl("../pages/DisplaysPage.qml"),
            entries: [
                { id: "monitor", label: "Monitor mode", description: "Change resolution and refresh rate", keywords: ["resolution", "refresh"] },
                { id: "scale", label: "Display scale", description: "Change monitor scale", keywords: ["scale"] }
            ]
        },
        {
            id: "audio",
            label: "Audio",
            iconName: "volume-2",
            keywords: ["audio", "volume", "microphone", "speaker", "output", "input"],
            pageSource: Qt.resolvedUrl("../pages/AudioPage.qml"),
            entries: [
                { id: "output", label: "Audio output", description: "Default speakers and output volume", keywords: ["output", "speaker", "volume"] },
                { id: "input", label: "Microphone", description: "Default input and gain", keywords: ["microphone", "input", "mic"] }
            ]
        },
        {
            id: "network",
            label: "Network",
            iconName: "wifi",
            keywords: ["network", "wifi", "ethernet", "internet", "connection"],
            pageSource: Qt.resolvedUrl("../pages/NetworkPage.qml"),
            entries: [
                { id: "wifi", label: "Wi-Fi", description: "Control Wi-Fi radio and networks", keywords: ["wifi", "wireless"] },
                { id: "ethernet", label: "Ethernet", description: "Inspect wired connection state", keywords: ["ethernet", "wired"] }
            ]
        },
        {
            id: "bluetooth",
            label: "Bluetooth",
            iconName: "bluetooth",
            keywords: ["bluetooth", "devices", "pair", "headphones"],
            pageSource: Qt.resolvedUrl("../pages/BluetoothPage.qml"),
            entries: [
                { id: "adapter", label: "Bluetooth adapter", description: "Enable or disable the adapter", keywords: ["adapter", "power"] },
                { id: "devices", label: "Bluetooth devices", description: "Pair or connect devices", keywords: ["pair", "connect", "devices"] }
            ]
        },
        {
            id: "input-about",
            label: "Input & About",
            iconName: "keyboard",
            keywords: ["keyboard", "mouse", "touchpad", "layout", "about", "system"],
            pageSource: Qt.resolvedUrl("../pages/InputAboutPage.qml"),
            entries: [
                { id: "input", label: "Input behavior", description: "Follow mouse and touchpad options", keywords: ["follow mouse", "touchpad", "natural scroll"] },
                { id: "about", label: "About this desktop", description: "Paths and runtime summaries", keywords: ["about", "system", "desktop"] }
            ]
        }
    ]

    function categoryById(categoryId) {
        return categories.find(category => category.id === categoryId) ?? categories[0];
    }

    function search(query) {
        const normalized = (query ?? "").trim().toLowerCase();
        if (normalized.length === 0)
            return [];

        const results = [];

        for (const category of categories) {
            const haystacks = [
                category.label,
                ...(category.keywords ?? [])
            ].map(value => String(value).toLowerCase());

            let categoryScore = haystacks.some(value => value.includes(normalized)) ? 10 : 0;

            for (const entry of category.entries ?? []) {
                const entryHaystacks = [
                    entry.label,
                    entry.description,
                    ...(entry.keywords ?? [])
                ].map(value => String(value).toLowerCase());

                const exactMatch = entryHaystacks.some(value => value === normalized);
                const includesMatch = entryHaystacks.some(value => value.includes(normalized));

                if (exactMatch || includesMatch) {
                    results.push({
                        categoryId: category.id,
                        categoryLabel: category.label,
                        categoryIconName: category.iconName,
                        entryId: entry.id,
                        title: entry.label,
                        description: entry.description,
                        score: exactMatch ? 100 : 50 + categoryScore
                    });
                }
            }

            if (categoryScore > 0) {
                results.push({
                    categoryId: category.id,
                    categoryLabel: category.label,
                    categoryIconName: category.iconName,
                    entryId: "",
                    title: category.label,
                    description: "Open category",
                    score: categoryScore
                });
            }
        }

        return results.sort((first, second) => second.score - first.score);
    }
}
