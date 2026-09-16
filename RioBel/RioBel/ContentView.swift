import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("LogoRiobel")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
            
            Text("RioBel Fidelidade")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
