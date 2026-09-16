import Foundation

@MainActor
final class AppRuntimeConfig {
    static let shared = AppRuntimeConfig()

    private(set) var dynamicIntroURL: URL?
    private(set) var dynamicAppKey: String?
    private(set) var menuLinks: [String: String] = [:]

    private init() {}

    func update(from links: [String: String]) {
        self.menuLinks = links

        // 1. Extrair URL de intro / login direto do link 'logout' fornecido pelo APP.do
        if let logoutURLString = links["logout"], let url = URL(string: logoutURLString) {
            self.dynamicIntroURL = url
            AppLogger.info(.auth, "🔗 [AppRuntimeConfig] URL de intro dinâmica identificada via logout do APP.do: \(logoutURLString)")
        }

        // 2. Extrair a chave oficial da Bunker a partir de qualquer link do APP.do
        for (name, link) in links {
            if let rawKey = BunkerURLBuilder.queryValue(named: "key", in: link) {
                if let data = Data(base64Encoded: rawKey), let decoded = String(data: data, encoding: .utf8), !decoded.isEmpty {
                    self.dynamicAppKey = decoded
                    AppLogger.info(.auth, "🔑 [AppRuntimeConfig] Chave Bunker extraída de '\(name)' (decodificada): \(decoded)")
                    break
                } else {
                    self.dynamicAppKey = rawKey
                    AppLogger.info(.auth, "🔑 [AppRuntimeConfig] Chave Bunker extraída de '\(name)': \(rawKey)")
                    break
                }
            }
        }
    }
}
