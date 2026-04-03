//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtCore
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "./shared/designsystem" as Design

ShellRoot {
    id: shellRoot

    property bool panelOpen: false

    IpcHandler {
        target: "calendar"
        function toggle() { shellRoot.panelOpen = !shellRoot.panelOpen; }
        function open() { shellRoot.panelOpen = true; }
        function close() { shellRoot.panelOpen = false; }
    }

    PanelWindow {
        id: window
        visible: shellRoot.panelOpen
        color: "transparent"

        WlrLayershell.namespace: "quickshell:calendar"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true; bottom: true; left: true; right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.panelOpen = false
        }

        // Close on escape if not handled by inner shortcuts
        Shortcut {
            sequence: "Escape"
            onActivated: shellRoot.panelOpen = false
        }

        // -------------------------------------------------------------------------
        // KEYBOARD SHORTCUTS
        // -------------------------------------------------------------------------
        Shortcut { 
            sequence: "Left"
            onActivated: {
                if (calHover.hovered) {
                    window.setMonthOffset(window.targetMonthOffset - 1);
                } else {
                    window.setWeatherView(window.targetWeatherView - 1);
                }
            }
        }

        Shortcut { 
            sequence: "Right"
            onActivated: {
                if (calHover.hovered) {
                    window.setMonthOffset(window.targetMonthOffset + 1);
                } else {
                    window.setWeatherView(window.targetWeatherView + 1);
                }
            }
        }

        // -------------------------------------------------------------------------
        // COLORS
        // -------------------------------------------------------------------------
        readonly property color base: Design.Tokens.color.bg.surface
        readonly property color mantle: Design.Tokens.color.bg.elevated
        readonly property color crust: Design.Tokens.color.bg.canvas
        readonly property color text: Design.Tokens.color.text.primary
        readonly property color subtext1: Design.Tokens.color.text.secondary
        readonly property color subtext0: Design.Tokens.color.text.secondary
        readonly property color overlay2: Design.ThemePalette.mix(Design.Tokens.color.text.secondary, Design.Tokens.color.text.muted, 0.25)
        readonly property color overlay1: Design.Tokens.color.text.muted
        readonly property color overlay0: Design.Tokens.color.text.muted
        readonly property color surface2: Design.Tokens.color.bg.active
        readonly property color surface1: Design.Tokens.color.bg.hover
        readonly property color surface0: Design.Tokens.color.bg.interactive

        readonly property color mauve: Design.Tokens.color.accent.hover
        readonly property color pink: Design.ThemePalette.mix(Design.Tokens.color.error, Design.Tokens.color.accent.primary, 0.35)
        readonly property color blue: Design.Tokens.color.accent.primary
        readonly property color sapphire: Design.Tokens.color.info
        readonly property color peach: Design.Tokens.color.warning
        readonly property color yellow: Design.ThemePalette.mix(Design.Tokens.color.warning, Design.Tokens.color.text.primary, Design.ThemeSettings.isDark ? 0.18 : 0.08)
        readonly property color teal: Design.ThemePalette.mix(Design.Tokens.color.info, Design.Tokens.color.success, 0.45)
        readonly property color green: Design.Tokens.color.success
        readonly property color red: Design.Tokens.color.error
        readonly property string textFontFamily: Design.Tokens.font.family.body
        readonly property string iconFontFamily: Design.Tokens.font.family.icon

        readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/calendar"

        // -------------------------------------------------------------------------
        // TIME OF DAY DYNAMIC COLORS
        // -------------------------------------------------------------------------
        readonly property color timeColor: {
            let h = window.currentTime.getHours();
            if (h >= 5 && h < 12) return window.peach;      // Morning
            if (h >= 12 && h < 17) return window.sapphire;  // Afternoon
            if (h >= 17 && h < 21) return window.mauve;     // Evening
            return window.blue;                             // Night
        }

        readonly property color timeAccent: {
            let h = window.currentTime.getHours();
            if (h >= 5 && h < 12) return window.yellow;     // Morning Accent
            if (h >= 12 && h < 17) return window.teal;      // Afternoon Accent
            if (h >= 17 && h < 21) return window.pink;      // Evening Accent
            return window.mauve;                            // Night Accent
        }

        readonly property color textAccent: Qt.tint(window.timeAccent, Qt.alpha(window.text, 0.35))

        // -------------------------------------------------------------------------
        // STARTUP ANIMATION STATES
        // -------------------------------------------------------------------------
        property bool startupComplete: false
        property real introMain: 0
        property real introAmbient: 0
        property real introClock: 0
        property real introCalendar: 0
        property real introWeather: 0
        property real introSchedule: 0

        SequentialAnimation {
            running: shellRoot.panelOpen
            
            // 50ms buffer to allow the window manager to map the surface before animating
            PauseAnimation { duration: 20 }

            ParallelAnimation {
                // Base window fades and scales slightly
                NumberAnimation { target: window; property: "introMain"; from: 0; to: 1.0; duration: 800; easing.type: Easing.OutQuart }

                // Ambient background glows and big parallax icon fade in
                SequentialAnimation {
                    PauseAnimation { duration: 150 }
                    NumberAnimation { target: window; property: "introAmbient"; from: 0; to: 1.0; duration: 1000; easing.type: Easing.OutSine }
                }

                // Central clock and 3D orbital pop from the center
                SequentialAnimation {
                    PauseAnimation { duration: 250 }
                    NumberAnimation { target: window; property: "introClock"; from: 0; to: 1.0; duration: 900; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
                }

                // Left wing (Calendar) slides in from the left
                SequentialAnimation {
                    PauseAnimation { duration: 350 }
                    NumberAnimation { target: window; property: "introCalendar"; from: 0; to: 1.0; duration: 850; easing.type: Easing.OutQuint }
                }

                // Right wing (Weather) slides in from the right
                SequentialAnimation {
                    PauseAnimation { duration: 400 }
                    NumberAnimation { target: window; property: "introWeather"; from: 0; to: 1.0; duration: 850; easing.type: Easing.OutQuint }
                }

                // Bottom section (Schedule) flows up smoothly
                SequentialAnimation {
                    PauseAnimation { duration: 500 }
                    NumberAnimation { target: window; property: "introSchedule"; from: 0; to: 1.0; duration: 900; easing.type: Easing.OutExpo }
                }
            }
            ScriptAction { script: window.startupComplete = true }
        }

        Connections {
            target: shellRoot
            function onPanelOpenChanged() {
                if (!shellRoot.panelOpen) {
                    window.introMain = 0;
                    window.introAmbient = 0;
                    window.introClock = 0;
                    window.introCalendar = 0;
                    window.introWeather = 0;
                    window.introSchedule = 0;
                    window.startupComplete = false;
                }
            }
        }

        property real globalOrbitAngle: 0
        NumberAnimation on globalOrbitAngle {
            from: 0; to: Math.PI * 2; duration: 90000; loops: Animation.Infinite; running: shellRoot.panelOpen
        }

        // -------------------------------------------------------------------------
        // STATE & TIME (WITH SECOND PULSE)
        // -------------------------------------------------------------------------
        property var currentTime: new Date()
        property real currentEpoch: currentTime.getTime() / 1000
        
        property real secondPulse: 1.0
        NumberAnimation on secondPulse { 
            id: pulseReset 
            to: 1.0; duration: 600; easing.type: Easing.OutQuint; running: false 
        }

        Timer {
            interval: 1000; running: shellRoot.panelOpen; repeat: true
            onTriggered: {
                window.currentTime = new Date();
                window.currentEpoch = window.currentTime.getTime() / 1000;
                window.secondPulse = 1.06; // Gentle pulse
                pulseReset.start();        
                
                if (window.currentTime.getHours() === 0 && window.currentTime.getMinutes() === 0 && window.currentTime.getSeconds() === 0) {
                    updateCalendarGrid();
                }
            }
        }

        // -------------------------------------------------------------------------
        // WEATHER DATA & ELEGANT TRANSITIONS (3D ORBIT SPIN)
        // -------------------------------------------------------------------------
        property var weatherData: null
        property int weatherView: 0
        property color activeWeatherHex: weatherData && weatherData.forecast && weatherData.forecast[weatherView] ? weatherData.forecast[weatherView].hex : window.mauve

        function normalizeWeatherIcon(icon) {
            if (icon === "") return "";
            if (icon === "") return "";
            if (!icon || icon === "") return "";
            return icon;
        }

        function normalizeWeatherPayload(payload) {
            if (!payload || !payload.forecast || !payload.forecast.length) return payload;
            for (let i = 0; i < payload.forecast.length; i++) {
                let day = payload.forecast[i];
                day.icon = window.normalizeWeatherIcon(day.icon);
                if (day.hourly && day.hourly.length) {
                    for (let j = 0; j < day.hourly.length; j++) {
                        day.hourly[j].icon = window.normalizeWeatherIcon(day.hourly[j].icon);
                    }
                }
            }
            return payload;
        }

        // Transition Properties
        property int targetWeatherView: 0
        property real weatherContentOpacity: 1.0
        property real weatherContentOffset: 0.0
        property int weatherAnimDirection: 1
        
        // New 3D Spin Properties
        property real transitionSpin: 0.0
        property real transitionScale: 1.0

        // -------------------------------------------------------------------------
        // TEMPERATURE LOGIC 
        // -------------------------------------------------------------------------
        property real targetTemp: window.weatherData && window.weatherData.forecast[window.targetWeatherView] ? Number(window.weatherData.forecast[window.targetWeatherView].max) : 0
        property real displayedTemp: targetTemp

        Behavior on displayedTemp {
            NumberAnimation {
                id: tempAnim
                duration: 800
                easing.type: Easing.OutQuart
            }
        }

        property bool isTempAnimating: tempAnim.running
        property color tempGlowColor: {
            if (!isTempAnimating || !window.startupComplete) return window.text;
            
            // If the target is higher than the currently ticking number, we are counting up
            if (window.targetTemp > window.displayedTemp) return window.red;
            
            // If the target is lower than the currently ticking number, we are counting down
            if (window.targetTemp < window.displayedTemp) return window.blue;
            
            return window.text; 
        }
        SequentialAnimation {
            id: weatherTransitionAnim
            ParallelAnimation {
                NumberAnimation { target: window; property: "weatherContentOpacity"; to: 0.0; duration: 250; easing.type: Easing.InSine }
                NumberAnimation { target: window; property: "weatherContentOffset"; to: -40 * window.weatherAnimDirection; duration: 250; easing.type: Easing.InSine }
                
                // Spin the 3D orbit out and scale it down for depth
                NumberAnimation { target: window; property: "transitionSpin"; to: 180 * window.weatherAnimDirection; duration: 300; easing.type: Easing.InBack }
                NumberAnimation { target: window; property: "transitionScale"; to: 0.8; duration: 300; easing.type: Easing.InCubic }
            }
            ScriptAction { 
                script: { 
                    window.weatherView = window.targetWeatherView; 
                    window.weatherContentOffset = 40 * window.weatherAnimDirection; // Move to opposite side while hidden
                    
                    // Reset the spin to the opposite side so it continues spinning into place seamlessly
                    window.transitionSpin = -180 * window.weatherAnimDirection;
                } 
            }
            ParallelAnimation {
                NumberAnimation { target: window; property: "weatherContentOpacity"; to: 1.0; duration: 450; easing.type: Easing.OutQuart }
                NumberAnimation { target: window; property: "weatherContentOffset"; to: 0.0; duration: 450; easing.type: Easing.OutQuart }
                
                // Snap the 3D orbit back to 0 degrees and restore full scale
                NumberAnimation { target: window; property: "transitionSpin"; to: 0.0; duration: 600; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                NumberAnimation { target: window; property: "transitionScale"; to: 1.0; duration: 500; easing.type: Easing.OutBack }
            }
        }

        function setWeatherView(idx) {
            if (idx < 0 || idx > 4 || !window.weatherData) return;
            if (idx === window.targetWeatherView) return; // Ignore if we are already heading there

            // If an animation is already running, gracefully interrupt it and apply the logical switch
            // before starting the new animation so the data doesn't get desynced.
            if (weatherTransitionAnim.running) {
                weatherTransitionAnim.stop();
                window.weatherView = window.targetWeatherView;
            }

            window.weatherAnimDirection = idx > window.weatherView ? 1 : -1;
            window.targetWeatherView = idx;
            weatherTransitionAnim.start();
        }

        property int activeHourIndex: {
            if (window.weatherView !== 0 || !window.weatherData || !window.weatherData.forecast || !window.weatherData.forecast[0] || !window.weatherData.forecast[0].hourly) return -1;
            
            let ch = window.currentTime.getHours();
            let hrArr = window.weatherData.forecast[0].hourly.slice(0, 8);
            let bestIdx = -1;
            let minDiff = 999;
            
            for (let i = 0; i < hrArr.length; i++) {
                let timeStr = hrArr[i].time || "00:00";
                let h = parseInt(timeStr.split(":")[0]);
                let diff = Math.abs(h - ch);
                if (diff < minDiff) {
                    minDiff = diff;
                    bestIdx = i;
                }
            }
            return bestIdx !== -1 ? bestIdx : 0;
        }

        Process {
            id: weatherPoller
            command: ["bash", window.scriptsDir + "/weather.sh", "--json"]
            running: shellRoot.panelOpen
            stdout: StdioCollector {
                onStreamFinished: {
                    let txt = this.text.trim();
                    if (txt !== "") {
                        try {
                            const parsed = JSON.parse(txt);
                            window.weatherData = window.normalizeWeatherPayload(parsed);
                        } catch(e) {}
                    }
                }
            }
        }

        Timer {
            interval: 150000 
            running: shellRoot.panelOpen; repeat: true
            onTriggered: weatherPoller.running = true
        }

        // -------------------------------------------------------------------------
        // NEWS DATA (Hacker News)
        // -------------------------------------------------------------------------
        property var newsData: ({ "articles": [], "fetched_at": 0 })

        Process {
            id: newsPoller
            command: ["bash", window.scriptsDir + "/news_manager.sh"]
            running: shellRoot.panelOpen
            stdout: StdioCollector {
                onStreamFinished: {
                    let txt = this.text.trim();
                    if (txt !== "") {
                        try { window.newsData = JSON.parse(txt); } catch(e) { console.log("News Parse Error:", e); }
                    }
                }
            }
        }

        Timer {
            interval: 1800000 // 30 minutes
            running: shellRoot.panelOpen; repeat: true
            onTriggered: newsPoller.running = true
        }

        // -------------------------------------------------------------------------
        // CALENDAR GRID LOGIC & TRANSITIONS
        // -------------------------------------------------------------------------
        property int monthOffset: 0
        property int targetMonthOffset: 0
        property string targetMonthName: ""
        ListModel { id: calendarModel }

        property real calendarContentOpacity: 1.0
        property real calendarContentOffset: 0.0
        property int calendarAnimDirection: 1

        SequentialAnimation {
            id: calendarTransitionAnim
            ParallelAnimation {
                NumberAnimation { target: window; property: "calendarContentOpacity"; to: 0.0; duration: 200; easing.type: Easing.InSine }
                NumberAnimation { target: window; property: "calendarContentOffset"; to: -20 * window.calendarAnimDirection; duration: 200; easing.type: Easing.InSine }
            }
            ScriptAction {
                script: {
                    window.monthOffset = window.targetMonthOffset;
                    window.calendarContentOffset = 20 * window.calendarAnimDirection;
                }
            }
            ParallelAnimation {
                NumberAnimation { target: window; property: "calendarContentOpacity"; to: 1.0; duration: 350; easing.type: Easing.OutQuart }
                NumberAnimation { target: window; property: "calendarContentOffset"; to: 0.0; duration: 350; easing.type: Easing.OutQuart }
            }
        }

        function setMonthOffset(newOffset) {
            if (newOffset === window.targetMonthOffset) return;

            if (calendarTransitionAnim.running) {
                calendarTransitionAnim.stop();
                window.monthOffset = window.targetMonthOffset;
            }

            window.calendarAnimDirection = newOffset > window.targetMonthOffset ? 1 : -1;
            window.targetMonthOffset = newOffset;
            calendarTransitionAnim.start();
        }

        function updateCalendarGrid() {
            let d = new Date(window.currentTime.getTime());
            d.setDate(1); 
            d.setMonth(d.getMonth() + window.monthOffset);

            let targetMonth = d.getMonth();
            let targetYear = d.getFullYear();

            let actualToday = new Date();
            let isRealCurrentMonth = (actualToday.getMonth() === targetMonth && actualToday.getFullYear() === targetYear);
            let todayDate = actualToday.getDate();

            window.targetMonthName = Qt.formatDateTime(d, "MMMM yyyy");

            let firstDay = new Date(targetYear, targetMonth, 1).getDay();
            firstDay = (firstDay === 0) ? 6 : firstDay - 1; 

            let daysInMonth = new Date(targetYear, targetMonth + 1, 0).getDate();
            let daysInPrevMonth = new Date(targetYear, targetMonth, 0).getDate();

            calendarModel.clear();

            // Previous Month Days
            for (let i = firstDay - 1; i >= 0; i--) {
                let dNum = daysInPrevMonth - i;
                calendarModel.append({ 
                    dayNum: dNum.toString(), 
                    isCurrentMonth: false, 
                    isToday: false
                });
            }

            // Current Month Days
            for (let i = 1; i <= daysInMonth; i++) {
                calendarModel.append({ 
                    dayNum: i.toString(), 
                    isCurrentMonth: true, 
                    isToday: (isRealCurrentMonth && i === todayDate)
                });
            }

            // Next Month Days
            let remaining = 42 - calendarModel.count;
            for (let i = 1; i <= remaining; i++) {
                calendarModel.append({ 
                    dayNum: i.toString(), 
                    isCurrentMonth: false, 
                    isToday: false
                });
            }
        }

        onMonthOffsetChanged: updateCalendarGrid()

        Component.onCompleted: {
            updateCalendarGrid();
        }

        // -------------------------------------------------------------------------
        // UI LAYOUT
        // -------------------------------------------------------------------------
        Item {
            anchors.centerIn: parent
            width: 1450
            height: 750

            MouseArea { anchors.fill: parent; preventStealing: true }

            scale: 0.95 + (0.05 * window.introMain)
            opacity: window.introMain

            Rectangle {
                anchors.fill: parent
                radius: 20
                color: window.base
                border.color: window.surface0
                border.width: 1
                clip: true

                // =======================================================
                // AMBIENT WIDGET COLOR BLOBS (Spread Out)
                // =======================================================
                Rectangle {
                    width: parent.width * 0.5; height: width; radius: width / 2
                    x: (parent.width * 0.75 - width / 2) + Math.cos(window.globalOrbitAngle * 1.5) * 350
                    y: (parent.height * 0.3 - height / 2) + Math.sin(window.globalOrbitAngle * 1.5) * 200
                    opacity: 0.025 * window.introAmbient
                    color: window.activeWeatherHex
                    Behavior on color { ColorAnimation { duration: 1000 } }
                }

                Rectangle {
                    width: parent.width * 0.6; height: width; radius: width / 2
                    x: (parent.width * 0.25 - width / 2) + Math.sin(window.globalOrbitAngle * 1.2) * -300
                    y: (parent.height * 0.7 - height / 2) + Math.cos(window.globalOrbitAngle * 1.2) * -250
                    opacity: 0.02 * window.introAmbient
                    color: window.timeColor
                    Behavior on color { ColorAnimation { duration: 1000 } }
                }

                Rectangle {
                    width: parent.width * 0.45; height: width; radius: width / 2
                    x: (parent.width * 0.5 - width / 2) + Math.cos(window.globalOrbitAngle * -1.8) * 400
                    y: (parent.height * 0.5 - height / 2) + Math.sin(window.globalOrbitAngle * -1.8) * -350
                    opacity: 0.015 * window.introAmbient
                    color: window.timeAccent
                    Behavior on color { ColorAnimation { duration: 1000 } }
                }

                // Big Parallax Weather Icon (Tied to Weather Transition)
                Text {
                    id: weatherIconText
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -100
                    text: window.weatherData && window.weatherData.forecast[window.weatherView] ? window.weatherData.forecast[window.weatherView].icon : ""
                    font.family: window.iconFontFamily
                    font.pixelSize: 800
                    color: window.activeWeatherHex
                    opacity: (0.03 + (0.01 * Math.sin(window.globalOrbitAngle * 4))) * window.introAmbient * window.weatherContentOpacity
                    z: 0
                    Behavior on color { ColorAnimation { duration: 1500 } }
                    
                    property real drift: 0
                    SequentialAnimation on drift {
                        loops: Animation.Infinite
                        NumberAnimation { to: -20; duration: 6000; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0; duration: 6000; easing.type: Easing.InOutSine }
                    }
                    
                    transform: [
                        Translate { y: weatherIconText.drift },
                        Translate { x: window.weatherContentOffset * 2 } // Exaggerated shift for background depth
                    ]
                }

                // =======================================================
                // CENTRAL HERO: THE BREATHING TIME HUB & 3D HOURLY ORBIT
                // =======================================================
                Item {
                    id: centralHub
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -100
                    width: 1; height: 1 
                    z: 5

                    opacity: window.introClock
                    scale: 0.85 + (0.15 * window.introClock)

                    property real levitation: 0
                    SequentialAnimation on levitation {
                        loops: Animation.Infinite
                        NumberAnimation { to: -15; duration: 4000; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0; duration: 4000; easing.type: Easing.InOutSine }
                    }

                    property real orbitBreath: 1.0
                    SequentialAnimation on orbitBreath {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { to: 1.035; duration: 3500; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 3500; easing.type: Easing.InOutSine }
                    }

                    // 3D Perspective Wobble (Pitch, Yaw, Roll)
                    property real pitchBreath: 0
                    SequentialAnimation on pitchBreath {
                        loops: Animation.Infinite; running: true
                        NumberAnimation { to: 3.5; duration: 4200; easing.type: Easing.InOutSine }
                        NumberAnimation { to: -3.5; duration: 4200; easing.type: Easing.InOutSine }
                    }

                    property real yawBreath: 0
                    SequentialAnimation on yawBreath {
                        loops: Animation.Infinite; running: true
                        NumberAnimation { to: 2.5; duration: 5100; easing.type: Easing.InOutSine }
                        NumberAnimation { to: -2.5; duration: 5100; easing.type: Easing.InOutSine }
                    }

                    property real rollBreath: 0
                    SequentialAnimation on rollBreath {
                        loops: Animation.Infinite; running: true
                        NumberAnimation { to: 1.5; duration: 5800; easing.type: Easing.InOutSine }
                        NumberAnimation { to: -1.5; duration: 5800; easing.type: Easing.InOutSine }
                    }
                    
                    transform: [
                        Translate { y: 25 * (1.0 - window.introClock) },
                        Translate { y: centralHub.levitation },
                        Rotation { axis { x: 1; y: 0; z: 0 } angle: centralHub.pitchBreath },
                        Rotation { axis { x: 0; y: 1; z: 0 } angle: centralHub.yawBreath },
                        Rotation { axis { x: 0; y: 0; z: 1 } angle: centralHub.rollBreath }
                    ]

                    Canvas {
                        z: -10
                        x: -400   // Widened to prevent clipping when scaled
                        y: -200   // Heightened to prevent clipping when scaled
                        width: 800
                        height: 400
                        opacity: 0.25

                        property real currentScale: centralHub.orbitBreath
                        onCurrentScaleChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            ctx.beginPath();
                            var currentRx = 320 * currentScale;
                            var currentRy = 140 * currentScale;
                            for (var i = 0; i <= Math.PI * 2; i += 0.05) {
                                var xx = width/2 + Math.cos(i) * currentRx;
                                var yy = height/2 + Math.sin(i) * currentRy;
                                if (i === 0) ctx.moveTo(xx, yy); else ctx.lineTo(xx, yy);
                            }
                            ctx.strokeStyle = window.textAccent;
                            ctx.lineWidth = 1.5;
                            ctx.setLineDash([4, 10]);
                            ctx.stroke();
                        }
                        Behavior on opacity { NumberAnimation { duration: 1500 } }
                    }

                    // Core Clock
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0
                        z: 0 
                        scale: 0.95 + (0.05 * window.secondPulse) 
                        
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2
                            Text {
                                text: Qt.formatTime(window.currentTime, "HH:mm")
                                font.family: window.textFontFamily
                                font.weight: Font.Black
                                font.pixelSize: 84
                                color: window.text
                                style: Text.Outline; styleColor: Qt.alpha(window.crust, 0.4)
                            }
                            Text {
                                text: Qt.formatTime(window.currentTime, ":ss")
                                font.family: window.textFontFamily
                                font.weight: Font.Bold
                                font.pixelSize: 32
                                color: window.textAccent
                                Layout.alignment: Qt.AlignBottom
                                Layout.bottomMargin: 15
                                opacity: window.secondPulse > 1.02 ? 1.0 : 0.6 
                                style: Text.Outline; styleColor: Qt.alpha(window.crust, 0.4)
                                Behavior on color { ColorAnimation { duration: 1000 } }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: Qt.formatDateTime(window.currentTime, "dddd, MMMM dd")
                            font.family: window.textFontFamily
                            font.weight: Font.Bold
                            font.pixelSize: 16
                            color: window.subtext0
                            opacity: 0.9
                        }
                    }

                    // TRUE 3D ORBITAL HOURLY FORECAST (Tied to Spin Transition)
                    Item {
                        anchors.fill: parent
                        opacity: window.weatherContentOpacity
                        
                        // Added Scale property to give a z-depth shrink effect when spinning
                        scale: window.transitionScale 
                        transform: Translate { x: window.weatherContentOffset * 1.5 }

                        Repeater {
                            id: hourRepeater
                            model: window.weatherData && window.weatherData.forecast[window.weatherView] && window.weatherData.forecast[window.weatherView].hourly ? window.weatherData.forecast[window.weatherView].hourly.slice(0, 8) : []
                            
                            delegate: Item {
                                property int mCount: hourRepeater.count
                                property bool isToday: window.weatherView === 0
                                property bool isHighlighted: isToday && index === window.activeHourIndex
                                
                                property real rx: 320 * centralHub.orbitBreath
                                property real ry: 140 * centralHub.orbitBreath
                                
                                property int relIdx: isToday ? (index - window.activeHourIndex) : index
                                
                                property real targetAngleDeg: isToday ? (65 + (relIdx * 30)) : (index * (360 / Math.max(1, mCount)))
                                
                                property real orbitOffset: isToday ? 0 : (window.globalOrbitAngle * (180 / Math.PI) * -1.5)
                                property real osc: isToday ? (Math.sin(window.globalOrbitAngle * 10 + index) * 5) : 0 
                                
                                // Integrated window.transitionSpin directly into the final angle calculation
                                property real rad: (targetAngleDeg + orbitOffset + osc + window.transitionSpin) * (Math.PI / 180)

                                x: Math.cos(rad) * rx - width/2
                                y: Math.sin(rad) * ry - height/2
                                z: Math.sin(rad) * 100 
                                
                                scale: isHighlighted ? 1.4 : (isToday ? (0.95 + 0.20 * Math.sin(rad)) : (0.90 + 0.25 * Math.sin(rad)))
                                opacity: isHighlighted ? 1.0 : (isToday ? (0.7 + 0.3 * ((Math.sin(rad) + 1) / 2)) : (0.65 + 0.35 * ((Math.sin(rad) + 1) / 2)))

                                width: 56; height: 95
                                
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 28
                                    color: isHighlighted ? window.textAccent : (hrMa.containsMouse ? window.surface2 : window.surface0)
                                    border.color: isHighlighted ? "transparent" : (hrMa.containsMouse ? window.textAccent : window.surface1)
                                    border.width: 1
                                    
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    
                                    ColumnLayout {
                                        anchors.centerIn: parent 
                                        spacing: 4
                                        
                                        Text { 
                                            Layout.alignment: Qt.AlignHCenter
                                            text: modelData.time
                                            font.family: window.textFontFamily; font.weight: Font.Bold; font.pixelSize: 12
                                            color: isHighlighted ? window.base : (hrMa.containsMouse ? window.text : window.overlay1)
                                        }
                                        
                                        Text { 
                                            Layout.alignment: Qt.AlignHCenter
                                            text: modelData.icon || (window.weatherData && window.weatherData.forecast[window.weatherView] ? window.weatherData.forecast[window.weatherView].icon : "")
                                            font.family: window.iconFontFamily; font.pixelSize: 18
                                            color: isHighlighted ? window.base : (modelData.hex || window.text)
                                            
                                            transform: Translate { y: hrMa.containsMouse ? -3 : 0 }
                                            Behavior on transform { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                                        }
                                        
                                        Text { 
                                            Layout.alignment: Qt.AlignHCenter; text: modelData.temp + "°"
                                            font.family: window.textFontFamily; font.weight: Font.Black; font.pixelSize: 14
                                            color: isHighlighted ? window.base : window.text 
                                        }
                                    }
                                }
                                MouseArea { id: hrMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }
                        }
                    }
                }

                // =======================================================
                // LEFT WING: FLOATING GLASS CALENDAR
                // =======================================================
                Rectangle {
                    id: calendarRect
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 40
                    width: 320
                    height: 420
                    color: Qt.alpha(window.surface0, 0.2) 
                    radius: 14
                    border.color: Qt.alpha(window.surface1, 0.4)
                    border.width: 1
                    z: 10 

                    opacity: window.introCalendar
                    transform: Translate { x: -40 * (1.0 - window.introCalendar) }

                    HoverHandler { id: calHover }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 25
                        spacing: 15

                        RowLayout {
                            Layout.fillWidth: true
                            
                            // "Return to Today" Home Button
                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: homeMa.containsMouse ? window.surface1 : "transparent"
                                opacity: window.targetMonthOffset !== 0 ? 1.0 : 0.0
                                visible: opacity > 0
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                                Text { anchors.centerIn: parent; text: "󰃭"; font.family: window.iconFontFamily; color: window.text; font.pixelSize: 16 }
                                MouseArea { 
                                    id: homeMa; anchors.fill: parent; hoverEnabled: window.targetMonthOffset !== 0; 
                                    onClicked: if (window.targetMonthOffset !== 0) window.setMonthOffset(0) 
                                }
                            }

                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: prevMa.containsMouse ? window.surface1 : "transparent"
                                Text { anchors.centerIn: parent; text: ""; font.family: window.iconFontFamily; color: window.text; font.pixelSize: 16 }
                                MouseArea { id: prevMa; anchors.fill: parent; hoverEnabled: true; onClicked: window.setMonthOffset(window.targetMonthOffset - 1) }
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: window.targetMonthName.toUpperCase()
                                font.family: window.textFontFamily
                                font.weight: Font.Black
                                font.pixelSize: 16
                                color: window.text
                                horizontalAlignment: Text.AlignHCenter
                                
                                opacity: window.calendarContentOpacity
                                transform: Translate { x: window.calendarContentOffset }
                            }

                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: nextMa.containsMouse ? window.surface1 : "transparent"
                                Text { anchors.centerIn: parent; text: ""; font.family: window.iconFontFamily; color: window.text; font.pixelSize: 16 }
                                MouseArea { id: nextMa; anchors.fill: parent; hoverEnabled: true; onClicked: window.setMonthOffset(window.targetMonthOffset + 1) }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Repeater {
                                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData
                                    font.family: window.textFontFamily
                                    font.weight: Font.Black
                                    font.pixelSize: 14
                                    color: window.overlay0
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            columns: 7
                            rowSpacing: 6
                            columnSpacing: 6

                            opacity: window.calendarContentOpacity
                            transform: Translate { x: window.calendarContentOffset }

                            Repeater {
                                model: calendarModel
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    
                                    color: isToday ? window.textAccent : (dayMa.containsMouse ? Qt.alpha(window.surface2, 0.4) : "transparent")
                                    radius: 10
                                    scale: dayMa.containsMouse ? 1.2 : 1.0
                                    border.color: isToday ? window.surface0 : (dayMa.containsMouse ? window.overlay0 : "transparent")
                                    border.width: isToday || dayMa.containsMouse ? 1 : 0
                                    
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: dayNum
                                        font.family: window.textFontFamily
                                        font.weight: isToday ? Font.Black : Font.Bold
                                        font.pixelSize: 14
                                        color: isToday ? window.base : (isCurrentMonth ? window.text : window.surface0)
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }

                                    MouseArea { id: dayMa; anchors.fill: parent; hoverEnabled: true }
                                }
                            }
                        }
                    }
                }

                // =======================================================
                // RIGHT WING: ORGANIC FLOATING WEATHER STATS
                // =======================================================
                Item {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 40
                    width: 320
                    height: 420
                    z: 10 

                    opacity: window.introWeather
                    transform: Translate { x: 40 * (1.0 - window.introWeather) }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 20

                        RowLayout {
                            Layout.alignment: Qt.AlignRight | Qt.AlignTop
                            spacing: 20
                            
                            MouseArea { 
                                id: wPrevMa; width: 30; height: 30; hoverEnabled: true
                                onClicked: window.setWeatherView(window.targetWeatherView - 1) 
                                
                                property real pulseOffset: 0
                                SequentialAnimation on pulseOffset {
                                    loops: Animation.Infinite; running: true
                                    NumberAnimation { to: -3; duration: 1000; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 0; duration: 1000; easing.type: Easing.InOutSine }
                                }
                                
                                Text { 
                                    anchors.centerIn: parent; text: ""; font.family: window.iconFontFamily; font.pixelSize: 18
                                    color: parent.containsMouse ? window.textAccent : window.overlay1
                                    transform: Translate { x: wPrevMa.containsMouse ? -5 : wPrevMa.pulseOffset }
                                    Behavior on transform { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                                }
                            }
                            
                            Text {
                                Layout.preferredWidth: 110 // Fixed width so the buttons don't jump around
                                horizontalAlignment: Text.AlignHCenter // Keeps the day name centered between the buttons
                                text: window.weatherData && window.weatherData.forecast[window.weatherView] ? window.weatherData.forecast[window.weatherView].day_full.toUpperCase() : "LOADING..."
                                font.family: window.textFontFamily
                                font.weight: Font.Black
                                font.pixelSize: 16
                                color: window.text
                            }
                            
                            MouseArea { 
                                id: wNextMa; width: 30; height: 30; hoverEnabled: true
                                onClicked: window.setWeatherView(window.targetWeatherView + 1)
                                
                                property real pulseOffset: 0
                                SequentialAnimation on pulseOffset {
                                    loops: Animation.Infinite; running: true
                                    NumberAnimation { to: 3; duration: 1000; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 0; duration: 1000; easing.type: Easing.InOutSine }
                                }
                                
                                Text { 
                                    anchors.centerIn: parent; text: ""; font.family: window.iconFontFamily; font.pixelSize: 18
                                    color: parent.containsMouse ? window.textAccent : window.overlay1
                                    transform: Translate { x: wNextMa.containsMouse ? 5 : wNextMa.pulseOffset }
                                    Behavior on transform { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignRight 
                            spacing: -5
                            
                            // BIG TEMPERATURE TEXT - Anchored so it doesn't slide with the wrapper
                            Text {
                                Layout.alignment: Qt.AlignHCenter 
                                text: Math.round(window.displayedTemp) + "°"
                                font.family: window.textFontFamily
                                font.weight: Font.Black
                                font.pixelSize: 84
                                color: window.tempGlowColor
                                style: Text.Outline; 
                                styleColor: window.isTempAnimating ? Qt.alpha(window.tempGlowColor, 0.5) : Qt.alpha(window.crust, 0.4)
                                
                                Behavior on color { ColorAnimation { duration: 300 } }
                                Behavior on styleColor { ColorAnimation { duration: 300 } }
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: window.weatherData && window.weatherData.forecast[window.weatherView] ? window.weatherData.forecast[window.weatherView].desc : ""
                                font.family: window.textFontFamily
                                font.weight: Font.Bold
                                font.pixelSize: 16
                                color: window.textAccent
                                Behavior on color { ColorAnimation { duration: 1000 } }
                                
                                opacity: window.weatherContentOpacity
                                transform: Translate { x: window.weatherContentOffset }
                            }
                        }

                        Item { Layout.fillHeight: true } 

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 10
                            spacing: 20
                            opacity: window.weatherContentOpacity
                            transform: Translate { x: window.weatherContentOffset }

                            Repeater {
                                model: window.weatherData && window.weatherData.forecast[window.weatherView] ? [
                                    { icon: "", val: window.weatherData.forecast[window.weatherView].wind + "m/s", lbl: "WIND", fill: Math.min(1.0, window.weatherData.forecast[window.weatherView].wind / 25.0) },
                                    { icon: "", val: window.weatherData.forecast[window.weatherView].humidity + "%", lbl: "HUMID", fill: window.weatherData.forecast[window.weatherView].humidity / 100.0 },
                                    { icon: "", val: window.weatherData.forecast[window.weatherView].pop + "%", lbl: "RAIN", fill: window.weatherData.forecast[window.weatherView].pop / 100.0 },
                                    { icon: "", val: window.weatherData.forecast[window.weatherView].feels_like + "°", lbl: "FEELS", fill: Math.max(0.0, Math.min(1.0, (window.weatherData.forecast[window.weatherView].feels_like + 15) / 55.0)) }
                                ] : []

                                Item {
                                    width: 68
                                    height: 100
                                    scale: gaugeMa.containsMouse ? 1.15 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                                    
                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 68; height: 68; radius: 34
                                        color: window.textAccent
                                        opacity: gaugeMa.containsMouse ? 0.3 : 0.0
                                        Behavior on opacity { NumberAnimation { duration: 200 } }
                                    }

                                    Item {
                                        id: circleItem
                                        width: 68; height: 68
                                        anchors.top: parent.top
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        
                                        Canvas {
                                            id: gaugeCanvas
                                            anchors.fill: parent
                                            rotation: -90 
                                            
                                            property real progress: modelData.fill
                                            property real animProgress: 0
                                            
                                            NumberAnimation on animProgress {
                                                to: gaugeCanvas.progress; duration: 1500; easing.type: Easing.OutExpo; running: true
                                            }
                                            
                                            onAnimProgressChanged: requestPaint()
                                            
                                            onPaint: {
                                                var ctx = getContext("2d");
                                                ctx.clearRect(0, 0, width, height);
                                                var r = width / 2;
                                                
                                                ctx.beginPath();
                                                ctx.arc(r, r, r - 4, 0, 2 * Math.PI);
                                                ctx.strokeStyle = Qt.alpha(window.text, 0.1);
                                                ctx.lineWidth = 3;
                                                ctx.stroke();
                                                
                                                if (animProgress > 0) {
                                                    ctx.beginPath();
                                                    ctx.arc(r, r, r - 4, 0, animProgress * 2 * Math.PI);
                                                    var grad = ctx.createLinearGradient(0, 0, width, height);
                                                    grad.addColorStop(0, window.timeAccent);
                                                    grad.addColorStop(1, window.sapphire);
                                                    ctx.strokeStyle = grad;
                                                    ctx.lineWidth = 4;
                                                    ctx.lineCap = "round";
                                                    ctx.stroke();
                                                }
                                            }
                                            Behavior on progress { NumberAnimation { duration: 1000; easing.type: Easing.OutExpo } }
                                        }
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.val
                                            font.family: window.textFontFamily
                                            font.weight: Font.Black
                                            font.pixelSize: 14
                                            color: window.text
                                        }
                                    }
                                    
                                    RowLayout {
                                        anchors.bottom: parent.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 4
                                        
                                        Text { 
                                            text: modelData.icon
                                            font.family: window.iconFontFamily
                                            font.pixelSize: 14
                                            color: gaugeMa.containsMouse ? window.textAccent : window.overlay0
                                            Behavior on color { ColorAnimation { duration: 200 } }
                                        }
                                        Text { 
                                            text: modelData.lbl
                                            font.family: window.textFontFamily
                                            font.weight: Font.Bold
                                            font.pixelSize: 12
                                            color: window.overlay0 
                                        }
                                    }
                                    
                                    MouseArea { id: gaugeMa; anchors.fill: parent; hoverEnabled: true }
                                }
                            }
                        }
                    }
                }

                // =======================================================
                // BOTTOM SECTION: HACKER NEWS FEED
                // =======================================================
                Item {
                    id: bottomSection
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 240
                    z: 20

                    opacity: window.introSchedule
                    transform: Translate { y: 50 * (1.0 - window.introSchedule) }

                    // Subtle gradient backdrop
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: Qt.alpha(window.crust, 0.6) }
                        }
                    }

                    // Top separator line
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Qt.alpha(window.surface1, 0.5) }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.topMargin: 18
                        anchors.leftMargin: 25
                        anchors.rightMargin: 25
                        anchors.bottomMargin: 18
                        spacing: 14

                        // ── Header row ──────────────────────────────────────
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 14

                            // Teal icon circle
                            Rectangle {
                                width: 38; height: 38; radius: 19
                                color: window.surface0
                                border.color: Qt.alpha(window.mauve, 0.55); border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    font.family: window.iconFontFamily
                                    font.pixelSize: 16
                                    color: window.mauve
                                }
                            }

                            Text {
                                text: "TECH NEWS"
                                font.family: window.textFontFamily
                                font.weight: Font.Bold
                                font.pixelSize: 15
                                font.letterSpacing: 1.5
                                color: window.mauve
                            }

                            Item { Layout.fillWidth: true }

                            // HN badge + last-updated timestamp
                            Rectangle {
                                height: 28
                                width: hnBadgeRow.implicitWidth + 20
                                radius: 8
                                color: Qt.alpha(window.surface1, 0.55)
                                border.color: Qt.alpha(window.mauve, 0.3); border.width: 1

                                RowLayout {
                                    id: hnBadgeRow
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text {
                                        text: "  HN"
                                        font.family: window.iconFontFamily
                                        font.weight: Font.Bold
                                        font.pixelSize: 13
                                        color: window.peach
                                    }

                                    Rectangle { width: 1; height: 16; color: Qt.alpha(window.surface2, 0.8) }

                                    Text {
                                        text: {
                                            const ts = window.newsData.fetched_at || 0;
                                            if (ts === 0) return "not yet fetched";
                                            const diff = Math.floor((Date.now() / 1000) - ts);
                                            if (diff < 60) return "just now";
                                            const mins = Math.floor(diff / 60);
                                            return mins + "m ago";
                                        }
                                        font.family: window.textFontFamily
                                        font.pixelSize: 12
                                        color: window.overlay0
                                    }
                                }
                            }
                        }

                        // ── News cards area ──────────────────────────────────
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            // Empty / loading state
                            Text {
                                anchors.centerIn: parent
                                text: "Fetching latest stories…"
                                font.family: window.textFontFamily
                                font.italic: true
                                font.pixelSize: 14
                                color: window.overlay0
                                visible: (window.newsData.articles || []).length === 0
                            }

                            // Horizontal scroll of cards
                            Flickable {
                                id: newsScroll
                                anchors.fill: parent
                                clip: true
                                flickableDirection: Flickable.HorizontalFlick
                                contentWidth: newsRow.implicitWidth
                                contentHeight: height
                                visible: (window.newsData.articles || []).length > 0
                                ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

                                Row {
                                    id: newsRow
                                    height: newsScroll.height
                                    spacing: 10

                                    Repeater {
                                        model: window.newsData.articles || []

                                        delegate: Item {
                                            id: cardRoot
                                            required property var modelData
                                            width: 260
                                            height: newsRow.height

                                            property bool hovered: cardMa.containsMouse

                                            scale: hovered ? 1.03 : 1.0
                                            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

                                             // Card background
                                            Rectangle {
                                                anchors.fill: parent
                                                anchors.topMargin: 4
                                                anchors.bottomMargin: 4
                                                radius: 10
                                                color: cardRoot.hovered ? Qt.alpha(window.mauve, 0.22) : Qt.alpha(window.mauve, 0.10)
                                                border.color: cardRoot.hovered ? Qt.alpha(window.mauve, 0.70) : Qt.alpha(window.mauve, 0.30)
                                                border.width: 1
                                                Behavior on color { ColorAnimation { duration: 160 } }
                                                Behavior on border.color { ColorAnimation { duration: 160 } }

                                                // Hover glow
                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: parent.radius
                                                    color: Qt.alpha(window.mauve, 0.10)
                                                    opacity: cardRoot.hovered ? 1.0 : 0.0
                                                    Behavior on opacity { NumberAnimation { duration: 160 } }
                                                }

                                                // Left accent bar
                                                Rectangle {
                                                    anchors.left: parent.left
                                                    anchors.top: parent.top
                                                    anchors.bottom: parent.bottom
                                                    anchors.topMargin: 6
                                                    anchors.bottomMargin: 6
                                                    width: cardRoot.hovered ? 4 : 3
                                                    radius: 2
                                                    color: window.mauve
                                                    Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                                                }

                                                ColumnLayout {
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    anchors.top: parent.top
                                                    anchors.bottom: parent.bottom
                                                    anchors.leftMargin: 16
                                                    anchors.rightMargin: 12
                                                    anchors.topMargin: 10
                                                    anchors.bottomMargin: 10
                                                    spacing: 6

                                                    // Domain pill
                                                    Rectangle {
                                                        visible: (cardRoot.modelData.domain || "") !== ""
                                                        height: 18
                                                        width: domainText.implicitWidth + 12
                                                        radius: 5
                                                        color: window.surface1
                                                        border.color: Qt.alpha(window.mauve, 0.35); border.width: 1

                                                        Text {
                                                            id: domainText
                                                            anchors.centerIn: parent
                                                            text: cardRoot.modelData.domain || ""
                                                            font.family: window.textFontFamily
                                                            font.pixelSize: 10
                                                            color: window.mauve
                                                            elide: Text.ElideRight
                                                        }
                                                    }

                                                    // Title
                                                    Text {
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true
                                                        text: cardRoot.modelData.title || ""
                                                        font.family: window.textFontFamily
                                                        font.weight: Font.Bold
                                                        font.pixelSize: 13
                                                        color: cardRoot.hovered ? window.text : window.subtext1
                                                        wrapMode: Text.WordWrap
                                                        maximumLineCount: 3
                                                        elide: Text.ElideRight
                                                        Behavior on color { ColorAnimation { duration: 160 } }
                                                    }

                                                    // Score + Comments + Author row
                                                    RowLayout {
                                                        Layout.fillWidth: true
                                                        spacing: 10

                                                        // Score
                                                        RowLayout {
                                                            spacing: 4
                                                            Text { text: "▲"; font.pixelSize: 10; color: window.green }
                                                            Text {
                                                                text: cardRoot.modelData.score || "0"
                                                                font.family: window.textFontFamily
                                                                font.weight: Font.Bold
                                                                font.pixelSize: 12
                                                                color: window.green
                                                            }
                                                        }

                                                        // Comments
                                                        RowLayout {
                                                            spacing: 4
                                                            Text { text: ""; font.family: window.iconFontFamily; font.pixelSize: 11; color: window.sapphire }
                                                            Text {
                                                                text: cardRoot.modelData.comments || "0"
                                                                font.family: window.textFontFamily
                                                                font.weight: Font.Bold
                                                                font.pixelSize: 12
                                                                color: window.sapphire
                                                            }
                                                        }

                                                        Item { Layout.fillWidth: true }

                                                        // Author
                                                        Text {
                                                            text: cardRoot.modelData.by || ""
                                                            font.family: window.textFontFamily
                                                            font.pixelSize: 11
                                                            color: window.subtext0
                                                            elide: Text.ElideRight
                                                            Layout.maximumWidth: 90
                                                        }
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                id: cardMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    const url = cardRoot.modelData.url || "";
                                                    if (url !== "") Quickshell.execDetached(["xdg-open", url]);
                                                }
                                            }
                                        }
                                    }
                                }

                                // Convert vertical wheel events to horizontal scroll
                                WheelHandler {
                                    orientation: Qt.Vertical
                                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                    onWheel: function(event) {
                                        const delta = -event.angleDelta.y * 1.5;
                                        const maxX = Math.max(0, newsScroll.contentWidth - newsScroll.width);
                                        newsScroll.contentX = Math.max(0, Math.min(maxX, newsScroll.contentX + delta));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
