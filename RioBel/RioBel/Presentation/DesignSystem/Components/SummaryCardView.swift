import SwiftUI

struct SummaryCardView: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.85))

                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer(minLength: 4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RioBelColors.darkCardBlue)
        .cornerRadius(10)
    }
}

#Preview {
    ZStack {
        RioBelColors.primaryBlue.ignoresSafeArea()
        HStack {
            SummaryCardView(title: "Resgatado", value: "R$2,39")
            SummaryCardView(title: "Expirado", value: "R$13,96")
        }
        .padding()
    }
}
