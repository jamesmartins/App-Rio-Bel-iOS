import SwiftUI
import Combine

enum AppRoute: Equatable {
    case login
    case home
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var currentRoute: AppRoute = .login
    /// Evita abrir a WebView de login antes de limpar cache e carregar APP.do.
    @Published var isLoginReady = false

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
        AppRuntimeConfig.shared.dynamicIntroURL
            ?? AppConstants.loginCandidateURLs().first
            ?? URL(string: AppConstants.introURLString)!
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
        Task { await bootstrap() }
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

    /// Limpa sessão/cache quando não autenticado e pré-carrega APP.do.
    private func bootstrap() async {
        if !manageSessionUseCase.currentSession().isAuthenticated {
            AppLogger.info(.auth, "🧹 Bootstrap: forçando limpeza de sessão/cache para recuperar a intro")
            await manageSessionUseCase.logoutCompletely()
            currentRoute = .login
        }

        do {
            _ = try await fetchAppConfigUseCase.execute()
            AppLogger.info(.auth, "Configurações do Bunker pré-carregadas com sucesso.")
        } catch {
            AppLogger.logFailure(.auth, operation: "AppCoordinator.bootstrap", error: error)
        }

        isLoginReady = true
    }

    /// Usado após logout ou "Tentar Novamente" na intro.
    func prepareFreshLogin() async {
        isLoginReady = false
        await manageSessionUseCase.logoutCompletely()
        _ = try? await fetchAppConfigUseCase.execute()
        currentRoute = .login
        isLoginReady = true
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

    // MARK: - View Factory

    func makeHomeViewModel() -> HomeViewModel {
        let vm = HomeViewModel(
            fetchDadosComprasUseCase: fetchDadosComprasUseCase,
            fetchAppConfigUseCase: fetchAppConfigUseCase,
            consultCliUseCase: consultCliUseCase,
            sessionUseCase: manageSessionUseCase
        )
        vm.onLogout = { [weak self] in
            Task { @MainActor in
                await self?.prepareFreshLogin()
            }
        }
        return vm
    }
}
