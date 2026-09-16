import SwiftUI
import Combine

enum AppRoute: Equatable {
    case login
    case home
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var currentRoute: AppRoute = .login

    // Dependências Clean Architecture
    let sessionRepository: SessionRepositoryProtocol
    let dadosComprasRepository: DadosComprasRepositoryProtocol
    let appConfigRepository: AppConfigRepositoryProtocol
    let consultaCliRepository: ConsultaCliRepositoryProtocol

    let manageSessionUseCase: ManageSessionUseCase
    let fetchDadosComprasUseCase: FetchDadosComprasUseCase
    let fetchAppConfigUseCase: FetchAppConfigUseCase
    let consultCliUseCase: ConsultCliUseCase

    var resolvedIntroURL: URL {
        AppRuntimeConfig.shared.dynamicIntroURL ?? AppConstants.loginCandidateURLs().first ?? URL(string: AppConstants.introURLString)!
    }

    var loginCandidateURLs: [URL] {
        AppConstants.loginCandidateURLs()
    }

    init(
        sessionRepository: SessionRepositoryProtocol,
        dadosComprasRepository: DadosComprasRepositoryProtocol,
        appConfigRepository: AppConfigRepositoryProtocol,
        consultaCliRepository: ConsultaCliRepositoryProtocol
    ) {
        self.sessionRepository = sessionRepository
        self.dadosComprasRepository = dadosComprasRepository
        self.appConfigRepository = appConfigRepository
        self.consultaCliRepository = consultaCliRepository

        self.manageSessionUseCase = ManageSessionUseCase(repository: sessionRepository)
        self.fetchDadosComprasUseCase = FetchDadosComprasUseCase(repository: dadosComprasRepository)
        self.fetchAppConfigUseCase = FetchAppConfigUseCase(repository: appConfigRepository)
        self.consultCliUseCase = ConsultCliUseCase(repository: consultaCliRepository)

        checkInitialRoute()
        prefetchAppConfig()
    }

    convenience init() {
        self.init(
            sessionRepository: SessionRepository(),
            dadosComprasRepository: DadosComprasRepository(),
            appConfigRepository: AppConfigRepository(),
            consultaCliRepository: ConsultaCliRepository()
        )
    }

    private func checkInitialRoute() {
        let session = manageSessionUseCase.currentSession()
        currentRoute = session.isAuthenticated ? .home : .login
    }

    private func prefetchAppConfig() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                _ = try await self.fetchAppConfigUseCase.execute()
                AppLogger.info(.auth, "Configurações do Bunker pré-carregadas com sucesso na inicialização.")
            } catch {
                AppLogger.logFailure(.auth, operation: "AppCoordinator.prefetchAppConfig", error: error)
            }
        }
    }

    // MARK: - Transições de Fluxo

    func showLogin() {
        currentRoute = .login
    }

    func onLoginSuccess(cpf: String?, idU: String, idL: String?) {
        if let cpf = cpf {
            manageSessionUseCase.save(cpf: cpf)
        }
        manageSessionUseCase.save(idU: idU)
        if let idL = idL {
            manageSessionUseCase.save(idL: idL)
        }
        withAnimation {
            currentRoute = .home
        }
    }

    func logout() {
        manageSessionUseCase.logout()
        withAnimation {
            currentRoute = .login
        }
    }

    // MARK: - View Factory

    func makeHomeViewModel() -> HomeViewModel {
        let vm = HomeViewModel(
            fetchDadosComprasUseCase: fetchDadosComprasUseCase,
            fetchAppConfigUseCase: fetchAppConfigUseCase,
            consultCliUseCase: consultCliUseCase,
            sessionUseCase: manageSessionUseCase
        )
        vm.onLogout = { [weak self] in
            self?.logout()
        }
        return vm
    }
}
