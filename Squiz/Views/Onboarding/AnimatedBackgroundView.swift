import SwiftUI

struct AnimatedBackgroundView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            // Основной градиентный фон
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.15),
                    Color(red: 0.05, green: 0.1, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Плавающие квадратики
            ForEach(0..<18, id: \.self) { index in
                FloatingSquare(
                    size: CGFloat.random(in: 20...60),
                    color: randomColor(),
                    opacity: Double.random(in: 0.1...0.3),
                    duration: Double.random(in: 5...8),
                    delay: Double.random(in: 0...2),
                    startX: CGFloat.random(in: -100...UIScreen.main.bounds.width),
                    startY: CGFloat.random(in: -100...UIScreen.main.bounds.height),
                    animate: $animate
                )
            }
        }
        .onAppear {
            animate = true
        }
    }

    private func randomColor() -> Color {
        let colors: [Color] = [
            .purple,
            .blue,
            .cyan,
            .indigo,
            Color(red: 0.5, green: 0.3, blue: 0.8),
            Color(red: 0.3, green: 0.5, blue: 0.9)
        ]
        return colors.randomElement() ?? .purple
    }
}

struct FloatingSquare: View {
    let size: CGFloat
    let color: Color
    let opacity: Double
    let duration: Double
    let delay: Double
    let startX: CGFloat
    let startY: CGFloat
    @Binding var animate: Bool

    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var rotation: Double = 0

    var body: some View {
        RoundedRectangle(cornerRadius: size / 4)
            .fill(color)
            .frame(width: size, height: size)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .offset(x: startX + offsetX, y: startY + offsetY)
            .blur(radius: 2)
            .onChange(of: animate) { _, newValue in
                if newValue {
                    withAnimation(
                        .linear(duration: duration)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                    ) {
                        offsetX = CGFloat.random(in: -150...150)
                        offsetY = CGFloat.random(in: -200...200)
                    }

                    withAnimation(
                        .linear(duration: duration * 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                    ) {
                        rotation = Double.random(in: -45...45)
                    }
                }
            }
    }
}

#Preview {
    AnimatedBackgroundView()
}
