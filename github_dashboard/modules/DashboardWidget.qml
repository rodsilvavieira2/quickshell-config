import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../common"
import "../common/widgets"
import "../services"

Item {
    id: root
    width: 640
    // Give some padding around the actual panel so the shadow isn't clipped
    // or we just define the height based on the panel content plus shadows.
    height: panel.height + Appearance.sizes.elevationMargin * 2

    function fetchData() {
        api.fetchQuota();
    }

    GitHubApi {
        id: api
    }
    
    StyledRectangularShadow { target: panel }

    Rectangle {
        id: panel
        width: 600
        height: mainLayout.implicitHeight + 40
        anchors.centerIn: parent
        
        color: Appearance.colors.colLayer0
        radius: 14
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        clip: true

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // Header Section
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "GitHub Copilot Premium"
                    color: Appearance.colors.colOnLayer0
                    font.family: Appearance.font.family.title
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.bold: true
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: api.state === "data" ? api.usagePercentage.toFixed(1) + "%" : (api.state === "loading" ? "Fetching..." : "Error")
                    color: Appearance.colors.colOnLayer0
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
            }

            // Progress Bar Background
            Rectangle {
                id: progressBarBg
                Layout.fillWidth: true
                height: 10
                color: Appearance.colors.colLayer1
                border.color: Appearance.colors.colSeparator
                border.width: 1
                radius: height / 2
                clip: true
                
                // Progress Bar Fill (Data state)
                Rectangle {
                    visible: api.state === "data"
                    width: Math.min(Math.max(api.usagePercentage / 100.0, 0), 1) * parent.width
                    height: parent.height
                    color: Appearance.colors.colSuccess
                    radius: parent.radius
                }

                // Loading State (Indeterminate Animation)
                Rectangle {
                    id: loadingBar
                    visible: api.state === "loading"
                    width: parent.width * 0.3
                    height: parent.height
                    color: Appearance.colors.colAccent
                    radius: parent.radius
                    opacity: 0.8

                    SequentialAnimation {
                        running: api.state === "loading"
                        loops: Animation.Infinite
                        
                        NumberAnimation {
                            target: loadingBar
                            property: "x"
                            from: -loadingBar.width
                            to: progressBarBg.width
                            duration: 1200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            // Descriptive Text
            Text {
                Layout.fillWidth: true
                Layout.topMargin: 4
                text: "Please note that there may be a delay in the displayed usage percentage. The premium request entitlement for your plan will reset at the start of next month. To enable additional premium requests, <a href='https://github.com/settings/billing/summary' style='color: " + Appearance.colors.colAccent + "; text-decoration: none;'>update your Copilot premium request budget</a>."
                color: Appearance.colors.colSubtext
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.small
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                
                onLinkActivated: function(link) {
                    Qt.openUrlExternally(link)
                }
                
                HoverHandler {
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
            
            // Error state below the text if there's an error
            Text {
                visible: api.state === "error" || api.state === "rate_limited"
                text: api.errorMessage
                color: Appearance.colors.colError
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.small
                Layout.topMargin: 4
            }
        }
    }
}