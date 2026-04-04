import ".." as Root
import "../components"
import "../services" as Services
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property real memUsage: Services.SystemStatsService.memTotal > 0 ? Services.SystemStatsService.memUsed / Services.SystemStatsService.memTotal : 0
    readonly property string cpuValue: Math.round(Services.SystemStatsService.cpuUsage * 100) + "%"
    readonly property string memValue: Services.SystemStatsService.memTotal > 0 ? Math.round(root.memUsage * 100) + "%" : "--%"
    readonly property string gpuValue: Math.round(Services.SystemStatsService.gpuUsage * 100) + "%"

    implicitWidth: metricsRow.implicitWidth
    implicitHeight: metricsRow.implicitHeight

    RowLayout {
        id: metricsRow

        anchors.centerIn: parent
        spacing: Root.Config.pillSpacing

        CircularMetricChip {
            metricLabel: "CPU"
            value: Services.SystemStatsService.cpuUsage
            valueText: root.cpuValue
            accentColor: Root.Config.blue
        }

        CircularMetricChip {
            metricLabel: "RAM"
            value: root.memUsage
            valueText: root.memValue
            accentColor: Root.Config.green
        }

        CircularMetricChip {
            visible: Services.SystemStatsService.hasGpu
            metricLabel: "GPU"
            value: Services.SystemStatsService.gpuUsage
            valueText: root.gpuValue
            accentColor: Root.Config.mauve
        }

    }

}
