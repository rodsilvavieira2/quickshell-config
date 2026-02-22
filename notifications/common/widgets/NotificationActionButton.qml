import QtQuick
import Quickshell.Services.Notifications
import ".."

RippleButton {
    id: button
    property string buttonText
    property string urgency

    implicitHeight: 32
    leftPadding: 14
    rightPadding: 14
    buttonRadius: Appearance.rounding.small
    colBackground: (urgency == NotificationUrgency.Critical) ? Appearance.colors.colCritical : Appearance.colors.colLayer3
    colBackgroundHover: (urgency == NotificationUrgency.Critical) ? Appearance.colors.colCritical : Appearance.colors.colLayer4
    colRipple: Appearance.colors.colLayer4

    contentItem: StyledText {
        horizontalAlignment: Text.AlignHCenter
        text: buttonText
        color: (urgency == NotificationUrgency.Critical) ? Appearance.colors.colOnCritical : Appearance.colors.colOnLayer0
    }
}
