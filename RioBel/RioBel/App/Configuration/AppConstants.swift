import Foundation

enum AppConstants {
    /// Host do backend Bunker
    static let bunkerAppHost = "https://adm.bunkerapp.com.br"
    static let bunkerMkHost = "https://adm.bunker.mk"

    /// Chaves candidatas do aplicativo RioBel no Bunker
    static let bunkerAppKey = "XjHuXkPF9ApJXtOAU¢"
    static let bunkerAppKeyWithoutCent = "XjHuXkPF9ApJXtOAU"
    static let bunkerAppKeyBase64 = "WGpIdVhrUEY5QXBKWHRPQVXCog=="
    static let bunkerAppKeyLegacy = "qfQ8Qoq6CzUuXhzo2aS66nXOEs"

    /// Código da empresa no Bunker para ConsultaCli
    static let userCompany = "21"

    /// URLs padrão
    static var introURLString: String {
        AppRuntimeConfig.makeIntroURL(key: bunkerAppKey)?.absoluteString
            ?? "\(bunkerAppHost)/app/intro.do?key=XjHuXkPF9ApJXtOAU%C2%A2"
    }

    static let appConfigURLString = "\(bunkerAppHost)/wsjson/APP.do"
    static let dadosComprasURLString = "\(bunkerMkHost)/wsjson/dadoscompras.php"
    static let consultaCliURLString = "\(bunkerAppHost)/wsjson/ConsultaCli.do"

    /// URLs de fallback para cards caso o APP.do não forneça
    enum HardcodedLinks {
        static let tokenBase = "\(bunkerAppHost)/app/tipoToken.do"
        static let tokenT = "SoLQBg0IJuLz78WQcIhp£FqskczAVVwLK"

        static var cadastreseURL: String {
            AppRuntimeConfig.makeIntroURL(key: bunkerAppKey)?
                .absoluteString
                .replacingOccurrences(of: "intro.do", with: "cadastro_V2.do")
                ?? "\(bunkerAppHost)/app/cadastro_V2.do?key=XjHuXkPF9ApJXtOAU%C2%A2"
        }

        static var termosURL: String {
            AppRuntimeConfig.makeIntroURL(key: bunkerAppKey)?
                .absoluteString
                .replacingOccurrences(of: "intro.do", with: "termos.do")
                ?? "\(bunkerAppHost)/app/termos.do?key=XjHuXkPF9ApJXtOAU%C2%A2"
        }
    }

    /// Retorna a lista ordenada de URLs candidatas para a tela de Login / Intro
    @MainActor
    static func loginCandidateURLs() -> [URL] {
        var urls = AppRuntimeConfig.shared.introCandidateURLs()

        let appDoKeys = [
            AppConstants.bunkerAppKey,
            AppConstants.bunkerAppKeyWithoutCent
        ]
        for key in appDoKeys {
            var components = URLComponents(string: "\(bunkerAppHost)/app/app.do")
            components?.queryItems = [URLQueryItem(name: "key", value: key)]
            if let url = components?.url, !urls.contains(url) {
                urls.append(url)
            }
        }

        return urls
    }
}
