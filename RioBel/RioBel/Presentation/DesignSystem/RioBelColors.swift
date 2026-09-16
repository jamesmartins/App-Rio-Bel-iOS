import SwiftUI

enum RioBelColors {
    /// Azul primário característico do RioBel Fidelidade (RGB: 0, 130, 230)
    static let primaryBlue = Color(red: 0.0, green: 0.51, blue: 0.90)

    /// Azul escuro translúcido para cards internos da Home (Resgatado/Expirado)
    static let darkCardBlue = Color(red: 0.0, green: 0.38, blue: 0.70).opacity(0.85)

    /// Amarelo vibrante do logo RioBel (usado no botão LOGIN e detalhes)
    static let accentYellow = Color(red: 0.98, green: 0.72, blue: 0.08)

    /// Fundo suave dos cards do menu (azul céu bem claro)
    static let tileBackground = Color(red: 0.92, green: 0.96, blue: 0.99)

    /// Cor de ícones e textos dos cards do menu
    static let tileForeground = Color(red: 0.0, green: 0.48, blue: 0.85)

    /// Fundo do aviso "Ainda não há saldo para gerar tokens"
    static let tokenBarBackground = Color(red: 0.65, green: 0.84, blue: 0.95).opacity(0.85)

    /// Texto do aviso do token
    static let tokenBarForeground = Color(red: 0.0, green: 0.40, blue: 0.75)

    /// Cores auxiliares
    static let backgroundWhite = Color.white
    static let textSecondary = Color.white.opacity(0.8)
}
