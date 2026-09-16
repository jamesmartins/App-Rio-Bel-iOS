import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()

    var body: some View {
        WelcomeView(viewModel: coordinator.makeWelcomeViewModel())
    }
}

#Preview {
    ContentView()
}
