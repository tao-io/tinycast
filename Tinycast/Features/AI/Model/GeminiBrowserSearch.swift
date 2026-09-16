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
}
