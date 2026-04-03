import QtQuick
import "../designsystem"

Surface {
    variant: "surface"
    backgroundColor: Tokens.color.surface
    borderColor: Tokens.color.outlineVariant
    borderWidth: Tokens.border.width.thin
    radius: Tokens.component.panel.radius
    padding: Tokens.component.panel.padding
    shadowLevel: Tokens.shadow.md
}
