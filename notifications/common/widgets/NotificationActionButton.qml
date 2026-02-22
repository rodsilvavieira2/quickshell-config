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
    colBackgroundHover: (urgency == NotificationUrgency.Critical) ? Appearance.colors.colCritical : Appearance.colors.colFlamingo
    colRipple: Appearance.colors.colLayer4
    colText: (urgency == NotificationUrgency.Critical) ? Appearance.colors.colOnCritical : Appearance.colors.colOnLayer0
    colTextHover: (urgency == NotificationUrgency.Critical) ? Appearance.colors.colOnCritical : Appearance.colors.colOnFlamingo

    contentItem: StyledText {
        horizontalAlignment: Text.AlignHCenter
        text: buttonText
        color: button.highlighted ? button.colTextHover : button.colText
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
    }
}
