import SwiftUI
import WebKit

@MainActor
struct AIWebView: NSViewRepresentable {
    let url: URL
    let onNavigate: (URL) -> Void

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var loadedURL: URL
        var onNavigate: (URL) -> Void

        init(url: URL, onNavigate: @escaping (URL) -> Void) {
            loadedURL = url
            self.onNavigate = onNavigate
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation?) {
            report(webView.url)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
            report(webView.url)
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard message.name == AIWebView.navigationHandler,
                let text = message.body as? String
            else { return }
            report(URL(string: text))
        }

        private func report(_ url: URL?) {
            guard let url, GeminiBrowserSearch.isAllowed(url), url != loadedURL else { return }
            loadedURL = url
            onNavigate(url)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url, onNavigate: onNavigate)
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.minimumFontSize = 13
        configuration.userContentController.add(
            context.coordinator, name: Self.navigationHandler)
        configuration.userContentController.addUserScript(
            WKUserScript(
                source: Self.readerScript, injectionTime: .atDocumentEnd,
                forMainFrameOnly: true))
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.pageZoom = 1.1
        webView.customUserAgent =
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
            + "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.onNavigate = onNavigate
        // Redirects change webView.url, so comparing it to the request retriggers the load.
        guard context.coordinator.loadedURL != url else { return }
        context.coordinator.loadedURL = url
        webView.load(URLRequest(url: url))
    }

    private static let navigationHandler = "tinycastNavigation"

    private static let readerScript = #"""
        (() => {
          const styleID = "tinycast-reader-style";
          const keepComposer = ':has(textarea), :has(input[aria-label*="Ask" i]), :has([contenteditable="true"][aria-label*="Ask" i])';
          if (!document.getElementById(styleID)) {
            const style = document.createElement("style");
            style.id = styleID;
            style.textContent = `
              body > header:not(${keepComposer}),
              body > nav:not(${keepComposer}),
              body > aside:not(${keepComposer}),
              body > footer:not(${keepComposer}),
              [role="banner"]:not(${keepComposer}),
              [role="navigation"][aria-label*="Google" i]:not(${keepComposer}),
              [role="complementary"]:not(${keepComposer}) {
                display: none !important;
              }
              main, [role="main"] {
                box-sizing: border-box !important;
                margin-inline: auto !important;
                max-width: 760px !important;
                padding-inline: 18px !important;
                width: 100% !important;
              }
              textarea,
              input[aria-label*="Ask" i],
              [contenteditable="true"][aria-label*="Ask" i] {
                font-size: 16px !important;
              }
            `;
            document.head.appendChild(style);
          }

          let lastURL = "";
          const reportURL = () => {
            if (location.href === lastURL) return;
            lastURL = location.href;
            window.webkit.messageHandlers.tinycastNavigation.postMessage(lastURL);
          };
          reportURL();
          new MutationObserver(reportURL).observe(document.documentElement, {
            childList: true,
            subtree: true
          });
          addEventListener("popstate", reportURL);
          addEventListener("hashchange", reportURL);
        })();
        """#
}
