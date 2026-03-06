import QtQuick
import "../common"

Item {
    id: root

    property string state: "loading" // "loading", "data", "error", "rate_limited"
    property string errorMessage: ""
    
    // API Data
    property real usagePercentage: 0.0

    Timer {
        id: pollTimer
        interval: Config.pollingIntervalMs
        running: true
        repeat: true
        onTriggered: fetchQuota()
    }

    function fetchQuota() {
        if (!Config.githubUsername || !Config.githubToken) {
            root.state = "error";
            root.errorMessage = "Missing Credentials";
            return;
        }

        root.state = "loading";

        // Step 1: Fetch the Usage Summary to get the dynamic limit (includedUsage)
        var xhrSummary = new XMLHttpRequest();
        var urlSummary = "https://api.github.com/users/" + Config.githubUsername + "/settings/billing/usage/summary";
        
        xhrSummary.open("GET", urlSummary, true);
        xhrSummary.setRequestHeader("Accept", "application/vnd.github+json");
        xhrSummary.setRequestHeader("Authorization", "Bearer " + Config.githubToken);
        xhrSummary.setRequestHeader("X-GitHub-Api-Version", "2022-11-28");
        
        xhrSummary.onreadystatechange = function() {
            if (xhrSummary.readyState === XMLHttpRequest.DONE) {
                var dynamicLimit = Config.premiumRequestLimit || 300.0; // Fallback to Config

                if (xhrSummary.status === 200) {
                    try {
                        var summaryResponse = JSON.parse(xhrSummary.responseText);
                        var summaryItems = summaryResponse.usageItems || [];
                        for (var j = 0; j < summaryItems.length; j++) {
                            // Match Copilot Premium Requests SKU (usually "copilot_premium_request" or similar)
                            if (summaryItems[j].sku && summaryItems[j].sku.toLowerCase().indexOf("premium request") !== -1) {
                                if (summaryItems[j].includedUsage) {
                                    dynamicLimit = summaryItems[j].includedUsage;
                                }
                                break;
                            }
                        }
                    } catch(e) {
                        console.log("Summary Parse Error: " + e);
                    }
                }
                
                // Step 2: Fetch the actual Premium Request Usage
                fetchPremiumUsage(dynamicLimit);
            }
        }
        
        xhrSummary.send();
    }

    function fetchPremiumUsage(limit) {
        var xhr = new XMLHttpRequest();
        var url = "https://api.github.com/users/" + Config.githubUsername + "/settings/billing/premium_request/usage";
        
        xhr.open("GET", url, true);
        xhr.setRequestHeader("Accept", "application/vnd.github+json");
        xhr.setRequestHeader("Authorization", "Bearer " + Config.githubToken);
        xhr.setRequestHeader("X-GitHub-Api-Version", "2022-11-28");
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        
                        var used = 0;
                        var items = response.usageItems ? response.usageItems : (Array.isArray(response) ? response : []);
                        
                        if (items.length > 0) {
                            for (var i = 0; i < items.length; i++) {
                                used += items[i].grossQuantity || items[i].quantity || 0;
                            }
                        } else {
                            // Fallback if the structure is just simple key-value pairs
                            used = response.total_premium_requests_used || 0;
                        }

                        // Calculate percentage using the dynamically fetched limit
                        if (limit > 0) {
                            root.usagePercentage = (used / limit) * 100.0;
                        } else {
                            root.usagePercentage = 0.0;
                        }

                        root.state = "data";
                        root.errorMessage = "";
                    } catch (e) {
                        console.log("Parse Error: " + e);
                        root.state = "error";
                        root.errorMessage = "Parse Error";
                    }
                } else if (xhr.status === 401) {
                    root.state = "error";
                    root.errorMessage = "Invalid Token";
                } else if (xhr.status === 429) {
                    root.state = "rate_limited";
                    root.errorMessage = "Rate Limited";
                } else if (xhr.status === 404) {
                    root.state = "error";
                    root.errorMessage = "404 Not Found\nCheck username & scopes";
                } else {
                    root.state = "error";
                    root.errorMessage = "Network Error (" + xhr.status + ")";
                }
            }
        }
        
        xhr.send();
    }

    Component.onCompleted: {
        // Initialization removed so it doesn't automatically fetch on startup.
        // It now relies on the parent's explicitly calling fetchQuota()
        // when GlobalStates.dashboardOpen becomes true.
    }
}
