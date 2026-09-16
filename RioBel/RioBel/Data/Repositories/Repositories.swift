import Foundation

final class DadosComprasRepository: DadosComprasRepositoryProtocol {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol = HTTPClient.shared) {
        self.client = client
    }

    func fetchDadosCompras(cpf: String, pagina: Int) async throws -> DadosComprasDashboard {
        let endpoint = Endpoint(
            urlString: AppConstants.dadosComprasURLString,
            method: .POST,
            headers: [
                "authorizationCode": AppSecrets.authorizationCode
            ],
            parameters: [
                "NUM_CGCECPF": cpf,
                "pagina": pagina
            ]
        )

        let response: DadosComprasResponseDTO = try await client.request(endpoint)

        guard response.coderro == 200 else {
            throw NetworkError.serverError(response.msgerro)
        }

        let cliente = response.cliente?.toDomain()
        let saldo = response.saldo?.toDomain()
        let compras = response.compras?.map { $0.toDomain() } ?? []

        return DadosComprasDashboard(cliente: cliente, saldo: saldo, compras: compras)
    }
}

final class AppConfigRepository: AppConfigRepositoryProtocol {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol = HTTPClient.shared) {
        self.client = client
    }

    func fetchAppConfig() async throws -> [String: String] {
        let endpoint = Endpoint(
            urlString: AppConstants.appConfigURLString,
            method: .GET,
            headers: [
                "authorizationCode": AppSecrets.authorizationCodePadded
            ],
            parameters: nil
        )

        let response: AppConfigResponseDTO = try await client.request(endpoint)
        return response.novoMenu?.links ?? [:]
    }
}

final class ConsultaCliRepository: ConsultaCliRepositoryProtocol {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol = HTTPClient.shared) {
        self.client = client
    }

    func consultCli(userIDBase64: String) async throws -> String? {
        let endpoint = Endpoint(
            urlString: AppConstants.consultaCliURLString,
            method: .POST,
            headers: [
                "authorizationCode": AppSecrets.authorizationCode
            ],
            parameters: [
                "RD_userId": userIDBase64,
                "RD_userCompany": AppConstants.userCompany
            ]
        )

        let (data, _) = try await client.requestRaw(endpoint)

        // Parse tolerante como no app de referência
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let name = json["RD_userName"] as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }

        return nil
    }
}

final class SessionRepository: SessionRepositoryProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func getSession() -> UserSession {
        UserSession(
            cpf: defaults.string(forKey: "cpf"),
            idU: defaults.string(forKey: "idU"),
            idL: defaults.string(forKey: "idL"),
            userName: defaults.string(forKey: "userName")
        )
    }

    func save(cpf: String) {
        defaults.set(cpf, forKey: "cpf")
    }

    func save(idU: String) {
        defaults.set(idU, forKey: "idU")
    }

    func save(idL: String) {
        defaults.set(idL, forKey: "idL")
    }

    func save(userName: String) {
        defaults.set(userName, forKey: "userName")
    }

    func clearSession() {
        defaults.removeObject(forKey: "cpf")
        defaults.removeObject(forKey: "idU")
        defaults.removeObject(forKey: "idL")
        defaults.removeObject(forKey: "userName")
        defaults.removeObject(forKey: "login")
        defaults.removeObject(forKey: "senha")
    }
}
