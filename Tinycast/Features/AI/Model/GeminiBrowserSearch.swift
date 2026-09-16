import Foundation

enum GeminiBrowserSearch {
    static let historyPrefix = "Google AI Mode: "

    static func searchURL(for query: String) -> URL? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard var components = URLComponents(string: "https://www.google.com/search") else {
            return nil
        }
        components.queryItems = [
            URLQueryItem(name: "q", value: trimmed),
            URLQueryItem(name: "udm", value: "50"),
            URLQueryItem(name: "sourceid", value: "chrome"),
            URLQueryItem(name: "ie", value: "UTF-8"),
        ]
        return components.url
    }

    static func historyText(for query: String) -> String {
        historyPrefix + query
    }

    static func searchURL(fromHistoryText text: String) -> URL? {
        guard text.hasPrefix(historyPrefix) else { return nil }
        return searchURL(for: String(text.dropFirst(historyPrefix.count)))
    }

    static func isAllowed(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.scheme?.lowercased() == "https",
            ["google.com", "www.google.com"].contains(components.host?.lowercased() ?? ""),
            components.path == "/search"
        else { return false }
        let items = components.queryItems ?? []
        return items.contains { $0.name == "udm" && $0.value == "50" }
            || items.contains { $0.name == "mstk" || $0.name == "mtid" }
    }
}
