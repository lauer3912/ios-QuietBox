import SwiftUI

struct AlertBanner: View {
    let message: String

    @State private var offset: CGFloat = -100

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundColor(.white)

            Text(message)
                .font(.headline)
                .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .background(ThemeManager.Colors.danger)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                offset = 60
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()

        AlertBanner(message: "Noise level exceeded!")
    }
}