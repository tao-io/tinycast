import AppKit
import Foundation

@MainActor
enum GeminiBrowserLauncher {
    static let arcBundleID = "company.thebrowser.browser"

    static func searchURL(for query: String) -> URL? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: trimmed),
            URLQueryItem(name: "udm", value: "50"),
            URLQueryItem(name: "sourceid", value: "chrome"),
            URLQueryItem(name: "ie", value: "UTF-8"),
        ]
        return components?.url
    }

    static func openInArc(query: String) {
        guard let url = searchURL(for: query) else { return }
        openInArc(url: url)
    }

    static func openInArc(url: URL) {
        let configuration = NSWorkspace.OpenConfiguration()
        if let arcURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: arcBundleID) {
            NSWorkspace.shared.open([url], withApplicationAt: arcURL, configuration: configuration)
        } else {
            NSWorkspace.shared.open(url, configuration: configuration)
        }
    }
}
