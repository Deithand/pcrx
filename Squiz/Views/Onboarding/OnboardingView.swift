import SwiftUI

struct OnboardingView: View {
    @State private var showPhoneInput = false
    @State private var showCodeInput = false
    @State private var phoneNumber = ""
    @State private var isComplete = false

    var body: some View {
        ZStack {
            if !showPhoneInput && !showCodeInput {
                // Экран 1: Welcome Slides
                WelcomeSlidesView(showPhoneInput: $showPhoneInput)
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .opacity.combined(with: .scale(scale: 0.9))
                    ))
            } else if showPhoneInput && !showCodeInput {
                // Экран 2: Ввод номера телефона
                PhoneInputView(showCodeInput: $showCodeInput, phoneNumber: $phoneNumber)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else if showCodeInput && !isComplete {
                // Экран 3: Ввод кода
                CodeInputView(phoneNumber: $phoneNumber, onComplete: $isComplete, showPhoneInput: $showPhoneInput)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .onChange(of: showPhoneInput) { _, newValue in
                        if newValue {
                            // Возврат к экрану ввода номера
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showCodeInput = false
                            }
                        }
                    }
            } else {
                // Экран 4: Успешное завершение
                SuccessView()
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showPhoneInput)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCodeInput)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isComplete)
    }
}

struct SuccessView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            AnimatedBackgroundView()

            VStack(spacing: 32) {
                // Иконка успеха
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
                        .frame(width: 160, height: 160)
                        .blur(radius: 30)
                        .scaleEffect(appeared ? 1.2 : 0.8)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(appeared ? 1 : 0.5)
                        .rotationEffect(.degrees(appeared ? 0 : -90))
                }
                .opacity(appeared ? 1 : 0)

                VStack(spacing: 16) {
                    Text("Готово!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)

                    Text("Добро пожаловать в Squiz")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Haptic feedback
            let successGenerator = UINotificationFeedbackGenerator()
            successGenerator.notificationOccurred(.success)

            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
                appeared = true
            }
        }
    }
}

#Preview {
    OnboardingView()
}
