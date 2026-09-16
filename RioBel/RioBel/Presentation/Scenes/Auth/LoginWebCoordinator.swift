import SwiftUI
import WebKit
import LocalAuthentication

final class LoginWebCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    var onLoginSuccess: ((_ cpf: String?, _ idU: String, _ idL: String?) -> Void)?
    var onDismiss: (() -> Void)?
    var onLoadingChange: ((Bool) -> Void)?

    private var capturedCPF: String?
    private var hasReportedSuccess = false
    private let sessionUseCase: ManageSessionUseCase

    init(sessionUseCase: ManageSessionUseCase) {
        self.sessionUseCase = sessionUseCase
        self.capturedCPF = sessionUseCase.currentSession().cpf
        super.init()
    }

    // MARK: - Script Message Handler (CPF Capture)

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "cpfCapture", let value = message.body as? String else { return }
        let digits = value.filter(\.isNumber)
        if digits.count >= 10 && digits.count <= 11 {
            self.capturedCPF = digits
            self.sessionUseCase.save(cpf: digits)
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        onLoadingChange?(true)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoadingChange?(false)

        guard let url = webView.url?.absoluteString else { return }

        // Fluxo Face ID / Biometria com idL
        if url.contains("app.do") && url.contains("idL=") {
            evaluateBiometrics(for: webView)
        } else if url.contains("app.do") && !url.contains("idL=") {
            if let idL = sessionUseCase.currentSession().idL, !idL.isEmpty {
                webView.stopLoading()
                let separator = url.contains("?") ? "&" : "?"
                if let newURL = URL(string: "\(url)\(separator)\(idL)") {
                    webView.load(URLRequest(url: newURL))
                }
            }
        } else if url.contains("idL=") && !url.contains("app.do") {
            let after = url.components(separatedBy: "idL=").last ?? ""
            let idLValue = after.components(separatedBy: "&").first ?? after
            if !idLValue.isEmpty {
                sessionUseCase.save(idL: "idL=\(idLValue)")
            }
        }

        // Detecção de pós-login (novoMenu)
        if url.contains("novoMenu") {
            handlePostLoginNavigation(url: url)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onLoadingChange?(false)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onLoadingChange?(false)
    }

    private func handlePostLoginNavigation(url: String) {
        guard !hasReportedSuccess else { return }

        var extractedIDU: String?
        if url.contains("idU=") {
            let after = url.components(separatedBy: "idU=").last ?? ""
            let rawIDU = after.components(separatedBy: "&").first ?? after
            extractedIDU = rawIDU.removingPercentEncoding ?? rawIDU
        }

        guard let idU = extractedIDU, !idU.isEmpty else { return }

        hasReportedSuccess = true
        sessionUseCase.save(idU: idU)

        // Se CPF ainda não foi capturado do script, tenta ler da sessão salva
        let finalCPF = self.capturedCPF ?? sessionUseCase.currentSession().cpf
        let currentIDL = sessionUseCase.currentSession().idL

        DispatchQueue.main.async {
            self.onLoginSuccess?(finalCPF, idU, currentIDL)
        }
    }

    private func evaluateBiometrics(for webView: WKWebView) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Autentique para entrar no RioBel") { success, _ in
                if success {
                    DispatchQueue.main.async {
                        webView.evaluateJavaScript("login()") { _, _ in }
                    }
                }
            }
        }
    }

    static let cpfCaptureJavaScript = """
    (function() {
      if (window.__riobelCpfCaptureInstalled) { return; }
      window.__riobelCpfCaptureInstalled = true;
      function digits(v){ return String(v||'').replace(/\\D/g,''); }
      function send(v){
        var d = digits(v);
        if (d.length < 10 || d.length > 11) { return; }
        try {
          window.webkit.messageHandlers.cpfCapture.postMessage(d);
        } catch (e) {}
      }
      function scan(){
        try {
          ['login','cpf','NUM_CGCECPF','num_cgcecpf','usuario','user','documento'].forEach(function(k){
            send(window.localStorage.getItem(k));
            send(window.sessionStorage.getItem(k));
          });
        } catch (e) {}
        try {
          var parts = (document.cookie || '').split(';');
          for (var i = 0; i < parts.length; i++) {
            var kv = parts[i].split('=');
            if (kv.length >= 2) send(decodeURIComponent(kv.slice(1).join('=').trim()));
          }
        } catch (e) {}
        try {
          document.querySelectorAll('input').forEach(function(el){ send(el.value); });
        } catch (e) {}
      }
      document.addEventListener('submit', function(){ setTimeout(scan, 0); }, true);
      document.addEventListener('change', function(e){
        if (e && e.target) { send(e.target.value); }
      }, true);
      document.addEventListener('input', function(e){
        if (e && e.target) { send(e.target.value); }
      }, true);
      setTimeout(scan, 300);
      setTimeout(scan, 1000);
    })();
    """
}

struct WKWebViewRepresentable: UIViewRepresentable {
    let url: URL
    let coordinator: LoginWebCoordinator

    func makeCoordinator() -> LoginWebCoordinator {
        coordinator
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let contentController = configuration.userContentController
        contentController.add(context.coordinator, name: "cpfCapture")
        contentController.addUserScript(WKUserScript(
            source: LoginWebCoordinator.cpfCaptureJavaScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        ))

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = UIColor(RioBelColors.primaryBlue)
        webView.isOpaque = false

        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
