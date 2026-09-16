import AppKit
import Foundation

@MainActor
enum GeminiBrowserLauncher {
    static let arcBundleID = "company.thebrowser.Browser"

    static func openInArc(url: URL) {
        let configuration = NSWorkspace.OpenConfiguration()
        if let arcURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: arcBundleID) {
            NSWorkspace.shared.open([url], withApplicationAt: arcURL, configuration: configuration)
        } else {
            NSWorkspace.shared.open(url, configuration: configuration)
        }
    }
}
