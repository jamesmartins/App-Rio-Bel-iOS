import SwiftUI
import Combine

enum AppRoute: Equatable {
    case welcome
    case login
    case register
    case terms
    case home
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var currentRoute: AppRoute = .welcome

    // Dependências Clean Architecture
    let sessionRepository: SessionRepositoryProtocol
    let dadosComprasRepository: DadosComprasRepositoryProtocol
    let appConfigRepository: AppConfigRepositoryProtocol
    let consultaCliRepository: ConsultaCliRepositoryProtocol

    let manageSessionUseCase: ManageSessionUseCase
    let fetchDadosComprasUseCase: FetchDadosComprasUseCase
    let fetchAppConfigUseCase: FetchAppConfigUseCase
    let consultCliUseCase: ConsultCliUseCase

    init(
        sessionRepository: SessionRepositoryProtocol = SessionRepository(),
        dadosComprasRepository: DadosComprasRepositoryProtocol = DadosComprasRepository(),
        appConfigRepository: AppConfigRepositoryProtocol = AppConfigRepository(),
        consultaCliRepository: ConsultaCliRepositoryProtocol = ConsultaCliRepository()
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
    }

    private func checkInitialRoute() {
        let session = manageSessionUseCase.currentSession()
        if session.isAuthenticated {
            currentRoute = .home
        } else {
            currentRoute = .welcome
        }
    }

    // MARK: - Transições de Fluxo

    func showLogin() {
        currentRoute = .login
    }

    func showRegister() {
        currentRoute = .register
    }

    func showTerms() {
        currentRoute = .terms
    }

    func returnToWelcome() {
        currentRoute = .welcome
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
            currentRoute = .welcome
        }
    }

    // MARK: - View Factory

    func makeWelcomeViewModel() -> WelcomeViewModel {
        let vm = WelcomeViewModel()
        vm.onLoginTapped = { [weak self] in
            self?.showLogin()
        }
        vm.onRegisterTapped = { [weak self] in
            self?.showRegister()
        }
        vm.onTermsTapped = { [weak self] in
            self?.showTerms()
        }
        return vm
    }

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
        vm.onBack = { [weak self] in
            self?.returnToWelcome()
        }
        return vm
    }
}
