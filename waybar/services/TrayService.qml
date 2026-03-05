pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Singleton {
    id: root

    // ── Configuration ─────────────────────────────────────────────────────
    /// Filter out passive (background) items from the tray
    property bool filterPassive: true
    /// Invert which list is treated as "pinned" vs "unpinned"
    /// When true: items are visible by default; adding to pinnedItemIds HIDES them
    property bool invertPins: true
    /// Append the item's raw id to tooltip text for debugging
    property bool showItemId: false

    // ── Mutable pinning state ──────────────────────────────────────────────
    property list<string> pinnedItemIds: []

    // ── Derived lists ──────────────────────────────────────────────────────
    readonly property list<var> _allFiltered: SystemTray.items.values.filter(
        item => !filterPassive || item.status !== SystemTrayItem.Passive
    )

    readonly property list<var> _pinnedFiltered: _allFiltered.filter(
        item => pinnedItemIds.includes(item.id)
    )

    readonly property list<var> _unpinnedFiltered: _allFiltered.filter(
        item => !pinnedItemIds.includes(item.id)
    )

    // Exposed: swapped when invertPins is true
    readonly property list<var> pinnedItems: invertPins ? _unpinnedFiltered : _pinnedFiltered
    readonly property list<var> unpinnedItems: invertPins ? _pinnedFiltered : _unpinnedFiltered

    /// All visible items — pinned first, then unpinned
    readonly property list<var> visibleItems: pinnedItems.concat(unpinnedItems)

    // ── Helpers ────────────────────────────────────────────────────────────
    function getTooltipForItem(item) {
        let result = item.tooltipTitle.length > 0 ? item.tooltipTitle
            : (item.title.length > 0 ? item.title : item.id);

        if (item.tooltipDescription.length > 0)
            result += " • " + item.tooltipDescription;

        if (showItemId)
            result += "\n[" + item.id + "]";

        return result;
    }

    // ── Pin management ─────────────────────────────────────────────────────
    function pin(itemId) {
        if (pinnedItemIds.includes(itemId)) return;
        pinnedItemIds.push(itemId);
    }

    function unpin(itemId) {
        pinnedItemIds = pinnedItemIds.filter(id => id !== itemId);
    }

    function togglePin(itemId) {
        if (pinnedItemIds.includes(itemId)) {
            unpin(itemId);
        } else {
            pin(itemId);
        }
    }
}
