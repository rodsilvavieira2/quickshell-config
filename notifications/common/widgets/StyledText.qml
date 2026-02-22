import QtQuick
import ".."

Text {
    id: root
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    font {
        hintingPreference: Font.PreferFullHinting
        family: Appearance ? (Appearance.font.family.main !== undefined ? Appearance.font.family.main : "JetBrains Mono") : "JetBrains Mono"
        pixelSize: Appearance ? (Appearance.font.pixelSize.small !== undefined ? Appearance.font.pixelSize.small : 13) : 13
    }
    color: Appearance ? (Appearance.colors.colOnLayer0 !== undefined ? Appearance.colors.colOnLayer0 : "#cdd6f4") : "#cdd6f4"
}
