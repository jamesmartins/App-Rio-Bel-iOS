import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()

    var body: some View {
        LoginWebView(
            initialURL: coordinator.resolvedIntroURL,
            candidateURLs: coordinator.loginCandidateURLs,
            sessionUseCase: coordinator.manageSessionUseCase,
            onLoginSuccess: { cpf, idU, idL in
                coordinator.onLoginSuccess(cpf: cpf, idU: idU, idL: idL)
            },
            onDismiss: {}
        )
    }
}

#Preview {
    ContentView()
}
