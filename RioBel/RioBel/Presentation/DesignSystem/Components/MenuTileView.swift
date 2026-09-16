import SwiftUI

struct MenuTileView: View {
    let title: String
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(RioBelColors.tileForeground)

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(RioBelColors.tileForeground)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 112)
            .background(RioBelColors.tileBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
