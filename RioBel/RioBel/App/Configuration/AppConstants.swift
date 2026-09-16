import Foundation

enum AppConstants {
    /// Host do backend Bunker
    static let bunkerAppHost = "https://adm.bunkerapp.com.br"
    static let bunkerMkHost = "https://adm.bunker.mk"

    /// Chave do aplicativo RioBel no Bunker
    /// Extraída da estrutura base64 do authorizationCode
    static let bunkerAppKey = "qfQ8Qoq6CzUuXhzo2aS66nXOEs"

    /// Código da empresa no Bunker (se aplicável para ConsultaCli)
    static let userCompany = "19"

    /// URLs padrão
    static let introURLString = "\(bunkerAppHost)/app/intro.do?key=\(bunkerAppKey)"
    static let appConfigURLString = "\(bunkerAppHost)/wsjson/APP.do"
    static let dadosComprasURLString = "\(bunkerMkHost)/wsjson/dadoscompras.php"
    static let consultaCliURLString = "\(bunkerAppHost)/wsjson/ConsultaCli.do"

    /// URLs de fallback para cards caso o APP.do não forneça
    enum HardcodedLinks {
        static let tokenBase = "\(bunkerAppHost)/app/tipoToken.do"
        static let tokenT = "SoLQBg0IJuLz78WQcIhp£FqskczAVVwLK"

        static let cadastreseURL = "\(bunkerAppHost)/app/cadastro_V2.do?key=\(bunkerAppKey)"
        static let termosURL = "\(bunkerAppHost)/app/termos.do?key=\(bunkerAppKey)"
    }
}
