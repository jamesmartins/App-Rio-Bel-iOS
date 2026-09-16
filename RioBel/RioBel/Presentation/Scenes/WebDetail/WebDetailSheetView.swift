import SwiftUI
import WebKit

final class WebDetailCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var onDismiss: (() -> Void)?
    var onLoadingChange: ((Bool) -> Void)?

    // MARK: - Script Message Handler (Intercepta Voltar da Web)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "menuBack" {
            onDismiss?()
        }
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        onLoadingChange?(true)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoadingChange?(false)
        if let url = webView.url?.absoluteString.lowercased(), shouldDismiss(for: url) {
            onDismiss?()
            return
        }
        webView.evaluateJavaScript(Self.backButtonJavaScript, completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onLoadingChange?(false)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onLoadingChange?(false)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let url = navigationAction.request.url?.absoluteString.lowercased(), shouldDismiss(for: url) {
            decisionHandler(.cancel)
            onDismiss?()
            return
        }
        decisionHandler(.allow)
    }

    private func shouldDismiss(for url: String) -> Bool {
        url.contains("novomenu") || url.contains("intro.do")
    }

    static let backButtonJavaScript = """
    (function() {
      if (window.__riobelMenuBackInstalled) { return; }
      window.__riobelMenuBackInstalled = true;
      function notifyBack() {
        try { window.webkit.messageHandlers.menuBack.postMessage('back'); } catch (e) {}
      }
      function isBack(el) {
        if (!el || el === document.body) return false;
        var href = (el.getAttribute && (el.getAttribute('href') || '') || '').toLowerCase();
        var onclick = (el.getAttribute && (el.getAttribute('onclick') || '') || '').toLowerCase();
        var cls = ((el.className && el.className.toString) ? el.className.toString() : '').toLowerCase();
        if (href.indexOf('novomenu') >= 0 || href.indexOf('intro.do') >= 0) return true;
        if (onclick.indexOf('novomenu') >= 0 || onclick.indexOf('intro.do') >= 0) return true;
        if (cls.indexOf('voltar') >= 0 || cls.indexOf('back') >= 0) return true;
        return false;
      }
      document.addEventListener('click', function(e) {
        var el = e.target;
        for (var i = 0; i < 6 && el; i++) {
          if (isBack(el)) {
            e.preventDefault();
            e.stopPropagation();
            notifyBack();
            return false;
          }
          el = el.parentElement;
        }
      }, true);
    })();
    """
}

struct WebDetailSheetView: View {
    let url: URL
    let title: String
    let onDismiss: () -> Void

    @State private var isLoading = true
    @State private var coordinator = WebDetailCoordinator()

    var body: some View {
        ZStack {
            RioBelColors.primaryBlue.ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra de navegação
                HStack {
                    Button(action: onDismiss) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                            Text("Voltar")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                    }

                    Spacer()

                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear
                        .frame(width: 70, height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(RioBelColors.primaryBlue)

                WebDetailRepresentable(url: url, coordinator: coordinator)
            }

            if isLoading {
                Color.black.opacity(0.15).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.3)
            }
        }
        .onAppear {
            coordinator.onDismiss = onDismiss
            coordinator.onLoadingChange = { loading in
                self.isLoading = loading
            }
        }
    }
}

struct WebDetailRepresentable: UIViewRepresentable {
    let url: URL
    let coordinator: WebDetailCoordinator

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        let contentController = configuration.userContentController
        contentController.add(coordinator, name: "menuBack")
        contentController.addUserScript(WKUserScript(
            source: WebDetailCoordinator.backButtonJavaScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        ))

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
