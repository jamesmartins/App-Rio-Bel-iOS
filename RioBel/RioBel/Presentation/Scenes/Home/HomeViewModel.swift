import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var userName: String
    @Published var firstName: String
    @Published var availableBalance: Double = 0.0
    @Published var redeemedBalance: Double = 0.0
    @Published var expiredBalance: Double = 0.0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedWebItem: (url: URL, title: String)?

    private let fetchDadosComprasUseCase: FetchDadosComprasUseCase
    private let fetchAppConfigUseCase: FetchAppConfigUseCase
    private let consultCliUseCase: ConsultCliUseCase
    private let sessionUseCase: ManageSessionUseCase

    private(set) var menuLinks: [String: String] = [:]
    var onLogout: (() -> Void)?
    var onBack: (() -> Void)?

    init(
        fetchDadosComprasUseCase: FetchDadosComprasUseCase,
        fetchAppConfigUseCase: FetchAppConfigUseCase,
        consultCliUseCase: ConsultCliUseCase,
        sessionUseCase: ManageSessionUseCase
    ) {
        self.fetchDadosComprasUseCase = fetchDadosComprasUseCase
        self.fetchAppConfigUseCase = fetchAppConfigUseCase
        self.consultCliUseCase = consultCliUseCase
        self.sessionUseCase = sessionUseCase

        let session = sessionUseCase.currentSession()
        let initialName = session.userName ?? "Cliente"
        self.userName = initialName
        self.firstName = Self.extractFirstName(from: initialName)
    }

    var greeting: String {
        "Olá, \(firstName)!"
    }

    var canGenerateToken: Bool {
        availableBalance > 0
    }

    func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.currencySymbol = "R$"
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "R$%.2f", value)
    }

    func loadData() {
        let session = sessionUseCase.currentSession()

        // 1. Carrega links de configuração do APP.do
        Task {
            await loadMenuLinks()
        }

        // 2. Se temos idU mas não nome, tenta consultar ConsultaCli
        if let idU = session.idU, session.userName == nil {
            Task {
                if let name = try? await consultCliUseCase.execute(userID: idU) {
                    self.applyUserName(name)
                    self.sessionUseCase.save(userName: name)
                }
            }
        }

        // 3. Carrega saldo e dados de compras via dadoscompras.php
        guard let cpf = session.cpf, !cpf.isEmpty else {
            errorMessage = "CPF não encontrado na sessão."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let dashboard = try await fetchDadosComprasUseCase.execute(cpf: cpf, pagina: 1)
                self.isLoading = false

                if let cliente = dashboard.cliente {
                    if let primeiroNome = cliente.primeiroNome, !primeiroNome.isEmpty {
                        self.firstName = primeiroNome
                        self.userName = cliente.nome
                    } else {
                        self.applyUserName(cliente.nome)
                    }
                    self.sessionUseCase.save(userName: self.userName)
                }

                if let saldo = dashboard.saldo {
                    self.availableBalance = saldo.disponivel
                    self.redeemedBalance = saldo.resgatado
                    self.expiredBalance = saldo.expirado
                }
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func loadMenuLinks() async {
        do {
            self.menuLinks = try await fetchAppConfigUseCase.execute()
        } catch {
            print("Erro ao carregar links do APP.do: \(error)")
        }
    }

    func applyUserName(_ raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        userName = trimmed
        firstName = Self.extractFirstName(from: trimmed)
    }

    private static func extractFirstName(from fullName: String) -> String {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Cliente" }
        return trimmed.components(separatedBy: .whitespaces).first ?? trimmed
    }

    func handleMenuItemSelection(_ item: HomeMenuItem) {
        if item == .logout {
            sessionUseCase.logout()
            onLogout?()
            return
        }

        let session = sessionUseCase.currentSession()

        // Tenta obter URL do APP.do
        if let linkKey = item.novoMenuLinkKey, let rawURL = menuLinks[linkKey] {
            if let builtURL = BunkerURLBuilder.build(from: rawURL, idU: session.idU) {
                selectedWebItem = (url: builtURL, title: item.rawValue)
                return
            }
        }

        // Fallback para itens não retornados ou se o APP.do ainda não respondeu
        let fallbackBase: String
        switch item {
        case .offers:
            fallbackBase = "\(AppConstants.bunkerAppHost)/app/ofertas.do"
        case .journal:
            fallbackBase = "\(AppConstants.bunkerAppHost)/app/jornalOfertas.do"
        case .profile:
            fallbackBase = "\(AppConstants.bunkerAppHost)/app/cadastro_V2.do"
        case .statement:
            fallbackBase = "\(AppConstants.bunkerAppHost)/app/relCompras.do"
        case .addresses:
            fallbackBase = "\(AppConstants.bunkerAppHost)/app/regioes.do"
        case .contact:
            fallbackBase = "\(AppConstants.bunkerAppHost)/app/faleConosco.do"
        case .logout:
            return
        }

        let builtURL = BunkerURLBuilder.build(from: fallbackBase, idU: session.idU)
        if let url = builtURL {
            selectedWebItem = (url: url, title: item.rawValue)
        } else {
            errorMessage = "Link temporariamente indisponível para \(item.rawValue)."
        }
    }

    func openGenerateToken() {
        guard canGenerateToken else { return }
        let session = sessionUseCase.currentSession()
        let tokenURL = BunkerURLBuilder.build(
            from: "\(AppConstants.HardcodedLinks.tokenBase)?t=\(AppConstants.HardcodedLinks.tokenT)",
            idU: session.idU
        )

        if let url = tokenURL {
            selectedWebItem = (url: url, title: "Gerar Token")
        }
    }
}
