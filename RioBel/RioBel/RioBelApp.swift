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
                case .welcome:
                    WelcomeView(viewModel: coordinator.makeWelcomeViewModel())
                        .transition(.opacity)

                case .login:
                    LoginWebView(
                        initialURL: coordinator.resolvedIntroURL,
                        candidateURLs: coordinator.loginCandidateURLs,
                        sessionUseCase: coordinator.manageSessionUseCase,
                        onLoginSuccess: { cpf, idU, idL in
                            coordinator.onLoginSuccess(cpf: cpf, idU: idU, idL: idL)
                        },
                        onDismiss: {
                            coordinator.returnToWelcome()
                        }
                    )
                    .transition(.move(edge: .bottom))

                case .register:
                    if let regURL = URL(string: AppConstants.HardcodedLinks.cadastreseURL) {
                        WebDetailSheetView(
                            url: regURL,
                            title: "Cadastre-se",
                            onDismiss: {
                                coordinator.returnToWelcome()
                            }
                        )
                        .transition(.move(edge: .bottom))
                    }

                case .terms:
                    if let termsURL = URL(string: AppConstants.HardcodedLinks.termosURL) {
                        WebDetailSheetView(
                            url: termsURL,
                            title: "Termos e Condições",
                            onDismiss: {
                                coordinator.returnToWelcome()
                            }
                        )
                        .transition(.move(edge: .bottom))
                    }

                case .home:
                    HomeView(viewModel: coordinator.makeHomeViewModel())
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: coordinator.currentRoute)
        }
    }
}
