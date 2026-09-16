import SwiftUI

struct LoginWebView: View {
    let initialURL: URL
    let sessionUseCase: ManageSessionUseCase
    let onLoginSuccess: (_ cpf: String?, _ idU: String, _ idL: String?) -> Void
    let onDismiss: () -> Void

    @State private var isLoading = true
    @State private var coordinator: LoginWebCoordinator?

    var body: some View {
        ZStack {
            RioBelColors.primaryBlue.ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra superior de navegação
                HStack {
                    Button(action: onDismiss) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                            Text("Fechar")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                    }

                    Spacer()

                    Text("Login RioBel")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    // Espaçador para manter o título centralizado
                    Color.clear
                        .frame(width: 70, height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(RioBelColors.primaryBlue)

                // WebView nativa UIKit
                if let coordinator = coordinator {
                    WKWebViewRepresentable(url: initialURL, coordinator: coordinator)
                } else {
                    Color.clear
                }
            }

            if isLoading {
                Color.black.opacity(0.15).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.3)
            }
        }
        .onAppear {
            let coord = LoginWebCoordinator(sessionUseCase: sessionUseCase)
            coord.onLoginSuccess = onLoginSuccess
            coord.onDismiss = onDismiss
            coord.onLoadingChange = { loading in
                self.isLoading = loading
            }
            self.coordinator = coord
        }
    }
}
