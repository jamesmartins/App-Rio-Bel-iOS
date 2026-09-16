import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: WelcomeViewModel

    var body: some View {
        ZStack {
            RioBelColors.primaryBlue
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo RioBel com splashes amarelos (idêntico à IMG_0106)
                Image("LogoRiobelBadge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)

                Spacer()

                // Ações de entrada
                VStack(spacing: 16) {
                    RioBelButton(
                        title: "LOGIN",
                        style: .primaryYellow,
                        action: viewModel.login
                    )

                    RioBelButton(
                        title: "CADASTRE-SE",
                        style: .secondaryWhite,
                        action: viewModel.register
                    )

                    RioBelButton(
                        title: "TERMOS E CONDIÇÕES",
                        style: .textLinkWhite,
                        action: viewModel.terms
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    WelcomeView(viewModel: WelcomeViewModel())
}
