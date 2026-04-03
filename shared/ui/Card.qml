import QtQuick
import "../designsystem"

Surface {
    variant: "surfaceContainer"
    backgroundColor: Tokens.color.surfaceContainer
    borderColor: Tokens.color.outlineVariant
    borderWidth: Tokens.border.width.thin
    radius: Tokens.component.card.radius
    padding: Tokens.component.card.padding
    shadowLevel: Tokens.shadow.sm
}
