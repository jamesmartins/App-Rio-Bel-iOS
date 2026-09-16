import Foundation

enum AppConstants {
    /// Host do backend Bunker
    static let bunkerAppHost = "https://adm.bunkerapp.com.br"
    static let bunkerMkHost = "https://adm.bunker.mk"

    /// Chaves candidatas do aplicativo RioBel no Bunker
    /// Extraídas da estrutura do authorizationCode: qfQ8Qoq6CzUuXhzo2aS66nXOEs£XjHuXkPF9ApJXtOAU¢
    static let bunkerAppKey = "XjHuXkPF9ApJXtOAU¢"
    static let bunkerAppKeyWithoutCent = "XjHuXkPF9ApJXtOAU"
    static let bunkerAppKeyBase64 = "WGpIdVhrUEY5QXBKWHRPQVXCog=="
    static let bunkerAppKeyLegacy = "qfQ8Qoq6CzUuXhzo2aS66nXOEs"

    /// Código da empresa no Bunker para ConsultaCli
    static let userCompany = "19"

    /// URLs padrão
    static var introURLString: String {
        "\(bunkerAppHost)/app/intro.do?key=XjHuXkPF9ApJXtOAU%C2%A2"
    }

    static let appConfigURLString = "\(bunkerAppHost)/wsjson/APP.do"
    static let dadosComprasURLString = "\(bunkerMkHost)/wsjson/dadoscompras.php"
    static let consultaCliURLString = "\(bunkerAppHost)/wsjson/ConsultaCli.do"

    /// URLs de fallback para cards caso o APP.do não forneça
    enum HardcodedLinks {
        static let tokenBase = "\(bunkerAppHost)/app/tipoToken.do"
        static let tokenT = "SoLQBg0IJuLz78WQcIhp£FqskczAVVwLK"

        static let cadastreseURL = "\(bunkerAppHost)/app/cadastro_V2.do?key=XjHuXkPF9ApJXtOAU%C2%A2"
        static let termosURL = "\(bunkerAppHost)/app/termos.do?key=XjHuXkPF9ApJXtOAU%C2%A2"
    }

    /// Retorna a lista ordenada de URLs candidatas para a tela de Login / Intro
    @MainActor
    static func loginCandidateURLs() -> [URL] {
        var urls: [URL] = []

        // 1. URL dinâmica extraída diretamente do APP.do (se já resolvida)
        if let dynamic = AppRuntimeConfig.shared.dynamicIntroURL {
            urls.append(dynamic)
        }

        // 2. Chaves candidatas para intro.do
        let candidateKeys = [
            "XjHuXkPF9ApJXtOAU%C2%A2",
            "XjHuXkPF9ApJXtOAU",
            "WGpIdVhrUEY5QXBKWHRPQVXCog==",
            "qfQ8Qoq6CzUuXhzo2aS66nXOEs"
        ]

        for key in candidateKeys {
            if let url = URL(string: "\(bunkerAppHost)/app/intro.do?key=\(key)"), !urls.contains(url) {
                urls.append(url)
            }
        }

        // 3. URLs diretas de formulário de login (app.do) caso o intro.do não esteja disponível
        for key in candidateKeys.prefix(2) {
            if let url = URL(string: "\(bunkerAppHost)/app/app.do?key=\(key)"), !urls.contains(url) {
                urls.append(url)
            }
        }

        return urls
    }
}
