import QtQuick
import "../designsystem"

Chip {
    id: root

    property bool occupied: false

    containerColor: occupied ? Tokens.color.surfaceContainerHigh : "transparent"
    hoverContainerColor: occupied ? Tokens.color.surfaceContainerHighest : Tokens.color.surfaceContainerLow
    pressedContainerColor: Tokens.color.surfaceContainerHighest
    selectedContainerColor: Tokens.color.secondaryContainer
    contentColor: occupied ? Tokens.color.text.primary : Tokens.color.text.secondary
    selectedContentColor: Tokens.color.secondaryContainerForeground
    borderColor: occupied ? ThemePalette.withAlpha(Tokens.color.outlineVariant, 0.7) : "transparent"
    selectedBorderColor: ThemePalette.withAlpha(Tokens.color.primary, 0.28)
    horizontalPadding: Tokens.space.s8
    verticalPadding: Tokens.space.s4
    spacing: Tokens.space.s4
    contentFontSize: Tokens.font.size.caption
    chipRadius: Tokens.shape.medium
}
