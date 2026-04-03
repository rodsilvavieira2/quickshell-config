import QtQuick
import QtQuick.Layouts

import ".." as Root
import "../components"
import "../services"

Item {
    id: root

    implicitWidth: metricsRow.implicitWidth
    implicitHeight: metricsRow.implicitHeight

    readonly property string cpuValue: Math.round(SystemStatsService.cpuUsage * 100) + "%"
    readonly property string memValue: SystemStatsService.memTotal > 0
        ? Math.round((SystemStatsService.memUsed / SystemStatsService.memTotal) * 100) + "%"
        : "--%"
    readonly property string gpuValue: Math.round(SystemStatsService.gpuUsage * 100) + "%"

    RowLayout {
        id: metricsRow
        anchors.centerIn: parent
        spacing: Root.Config.pillSpacing

        InfoChip {
            iconText: "󰍛"
            valueText: root.cpuValue
            iconColor: Root.Config.blue
            labelColor: Root.Config.text
        }

        InfoChip {
            iconText: "󰘚"
            valueText: root.memValue
            iconColor: Root.Config.green
            labelColor: Root.Config.text
        }

        InfoChip {
            visible: SystemStatsService.hasGpu
            iconText: "󰢮"
            valueText: root.gpuValue
            iconColor: Root.Config.mauve
            labelColor: Root.Config.text
        }
    }
}
