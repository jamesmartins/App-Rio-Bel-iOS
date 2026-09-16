import Foundation

enum HomeMenuItem: String, CaseIterable, Identifiable {
    case offers = "Minhas Ofertas"
    case journal = "Jornal de Ofertas"
    case profile = "Meus Dados"
    case statement = "Extrato"
    case addresses = "Endereços"
    case contact = "Fale Conosco"
    case logout = "Sair"

    var id: String { rawValue }

    /// Chave correspondente no JSON retornado por `APP.do` em `novoMenu.links`
    var novoMenuLinkKey: String? {
        switch self {
        case .offers: return "ofertas"
        case .journal: return "jornal" // ou fallback no APP.do
        case .profile: return "meus_dados"
        case .statement: return "historico"
        case .addresses: return "enderecos"
        case .contact: return "fale_conosco"
        case .logout: return "logout"
        }
    }

    /// Ícones SF Symbols fiéis aos das imagens de referência
    var systemImage: String {
        switch self {
        case .offers:
            return "tag"
        case .journal:
            return "newspaper"
        case .profile:
            return "person.crop.rectangle"
        case .statement:
            return "doc.text"
        case .addresses:
            return "mappin.and.ellipse"
        case .contact:
            return "headphones"
        case .logout:
            return "rectangle.portrait.and.arrow.right"
        }
    }
}
