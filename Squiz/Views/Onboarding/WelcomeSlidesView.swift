import SwiftUI

struct WelcomeSlidesView: View {
    @Binding var showPhoneInput: Bool
    @State private var currentPage = 0
    @State private var appeared = false

    let slides = [
        SlideData(
            icon: "bolt.fill",
            title: "Общайся\nмгновенно",
            description: "Отправляй сообщения, фото и видео без задержек"
        ),
        SlideData(
            icon: "photo.stack",
            title: "Делись\nбез границ",
            description: "Создавай группы, каналы и обменивайся файлами"
        ),
        SlideData(
            icon: "lock.shield",
            title: "Полная\nприватность",
            description: "Сквозное шифрование защищает твои разговоры"
        )
    ]

    var body: some View {
        ZStack {
            AnimatedBackgroundView()

            VStack(spacing: 0) {
                Spacer()

                // Пейджер со слайдами
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        SlideView(slide: slides[index], appeared: appeared)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 500)

                Spacer()

                // Кнопка "Начать"
                VStack(spacing: 16) {
                    GradientButton(title: "Начать") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showPhoneInput = true
                        }
                    }
                    .padding(.horizontal, 32)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: appeared)
                }
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appeared = true
            }
        }
    }
}

struct SlideData {
    let icon: String
    let title: String
    let description: String
}

struct SlideView: View {
    let slide: SlideData
    let appeared: Bool

    var body: some View {
        VStack(spacing: 32) {
            // Иконка с градиентом
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.3),
                                Color.blue.opacity(0.3),
                                Color.cyan.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)

                Image(systemName: slide.icon)
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.5)
            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1), value: appeared)

            VStack(spacing: 16) {
                // Заголовок
                Text(slide.title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: appeared)

                // Описание
                Text(slide.description)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: appeared)
            }
        }
    }
}

#Preview {
    WelcomeSlidesView(showPhoneInput: .constant(false))
}
