import Foundation

enum AppSecrets {
    /// Authorization code padrão fornecido para as APIs do RioBel
    private static let defaultAuthorizationCode = "cWZROFFvcTZDelV1WGh6bzJhUzY2blhPRXPCo1hqSHVYa1BGOUFwSlh0T0FVwqI="

    /// Lê do Secrets.plist ou faz fallback para o código padrão configurado
    static var authorizationCode: String {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let code = dict["authorizationCode"] as? String,
           !code.isEmpty,
           code != "REPLACE_WITH_AUTHORIZATION_CODE" {
            return code
        }
        return defaultAuthorizationCode
    }

    /// Garante padding Base64 ("==") quando exigido pelo backend (ex: APP.do)
    static var authorizationCodePadded: String {
        let value = authorizationCode
        let remainder = value.count % 4
        guard remainder != 0 else { return value }
        return value + String(repeating: "=", count: 4 - remainder)
    }
}
