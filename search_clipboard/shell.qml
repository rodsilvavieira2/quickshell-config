//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell

import "./modules/search_clipboard"
import "./services"
import "./common"

ShellRoot {
    id: shellRoot

    Search {}
}
