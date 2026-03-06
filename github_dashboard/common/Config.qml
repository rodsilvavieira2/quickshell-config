pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root
    
    // Read GitHub Username and Personal Access Token (PAT) from OS environment variables
    // Make sure to export GITHUB_USERNAME and GITHUB_TOKEN before running Quickshell
    property string githubUsername: Quickshell.env("GITHUB_USERNAME") || ""
    property string githubToken: Quickshell.env("GITHUB_TOKEN") || ""
    
    // Total monthly limit for premium requests (standard is often 300 or 500)
    property real premiumRequestLimit: 300.0
    
    // Default polling interval: 5 minutes
    property int pollingIntervalMs: 5 * 60 * 1000
}
