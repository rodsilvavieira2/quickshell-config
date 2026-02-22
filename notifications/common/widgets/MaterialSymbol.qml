import QtQuick
import ".."

Text {
    id: root
    property int iconSize: Appearance ? (Appearance.font.pixelSize.larger !== undefined ? Appearance.font.pixelSize.larger : 18) : 18
    property bool filled: false
    font.family: "Material Symbols Rounded"
    font.styleName: filled ? "Filled" : "Regular"
    font.pixelSize: iconSize
    color: Appearance ? (Appearance.colors.colOnLayer0 !== undefined ? Appearance.colors.colOnLayer0 : "#cdd6f4") : "#cdd6f4"
    font.weight: filled ? Font.Black : Font.Normal
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}
