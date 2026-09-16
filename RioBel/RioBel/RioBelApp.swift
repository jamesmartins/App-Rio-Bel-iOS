import SwiftUI

@main
struct RioBelApp: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            ZStack {
                RioBelColors.primaryBlue
                    .ignoresSafeArea()

                switch coordinator.currentRoute {
                case .login:
                    LoginWebView(
                        initialURL: coordinator.resolvedIntroURL,
                        candidateURLs: coordinator.loginCandidateURLs,
                        sessionUseCase: coordinator.manageSessionUseCase,
                        onLoginSuccess: { cpf, idU, idL in
                            coordinator.onLoginSuccess(cpf: cpf, idU: idU, idL: idL)
                        },
                        onDismiss: {
                            // Intro/login é a tela raiz — não há tela nativa para voltar.
                        }
                    )
                    .transition(.opacity)

                case .home:
                    HomeView(viewModel: coordinator.makeHomeViewModel())
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: coordinator.currentRoute)
        }
    }
}
