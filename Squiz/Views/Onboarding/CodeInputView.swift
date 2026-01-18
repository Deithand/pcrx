import SwiftUI

struct CodeInputView: View {
    @Binding var phoneNumber: String
    @Binding var onComplete: Bool
    @Binding var showPhoneInput: Bool

    @State private var code: [String] = Array(repeating: "", count: 6)
    @State private var appeared = false
    @State private var timeRemaining = 59
    @State private var timer: Timer?
    @FocusState private var focusedField: Int?

    var body: some View {
        ZStack {
            AnimatedBackgroundView()

            VStack(spacing: 40) {
                Spacer()

                // Заголовок
                VStack(spacing: 12) {
                    Text("Введи код")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -20)

                    Text("Мы отправили SMS на номер")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -20)

                    Text(phoneNumber)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -20)
                }
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: appeared)

                // Поля ввода кода
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        CodeDigitField(
                            text: $code[index],
                            isFocused: focusedField == index,
                            appeared: appeared,
                            index: index
                        )
                        .focused($focusedField, equals: index)
                        .onChange(of: code[index]) { _, newValue in
                            handleCodeChange(at: index, newValue: newValue)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: appeared)

                // Таймер и кнопка "Отправить снова"
                VStack(spacing: 16) {
                    if timeRemaining > 0 {
                        Text("Отправить снова через 0:\(String(format: "%02d", timeRemaining))")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    } else {
                        Button(action: {
                            resendCode()
                        }) {
                            Text("Отправить код снова")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.cyan)
                        }
                    }

                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showPhoneInput = true
                        }
                    }) {
                        Text("Изменить номер")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: appeared)

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = 0
            }
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func handleCodeChange(at index: Int, newValue: String) {
        // Оставляем только цифры и берем последний символ
        let filtered = newValue.filter { $0.isNumber }
        if filtered.count > 0 {
            code[index] = String(filtered.last!)

            // Haptic feedback
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()

            // Автопереход на следующее поле
            if index < 5 {
                focusedField = index + 1
            } else {
                // Если заполнили все поля
                focusedField = nil
                checkCode()
            }
        } else if newValue.isEmpty {
            code[index] = ""
        }
    }

    private func checkCode() {
        let enteredCode = code.joined()
        if enteredCode.count == 6 {
            // Имитация проверки кода (принимаем любой код)
            let successGenerator = UINotificationFeedbackGenerator()
            successGenerator.notificationOccurred(.success)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    onComplete = true
                }
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
            }
        }
    }

    private func resendCode() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()

        timeRemaining = 59
        code = Array(repeating: "", count: 6)
        focusedField = 0
        startTimer()
    }
}

struct CodeDigitField: View {
    @Binding var text: String
    let isFocused: Bool
    let appeared: Bool
    let index: Int

    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 50, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(text.isEmpty ? 0.05 : 0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isFocused ?
                            LinearGradient(
                                colors: [.purple, .blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(text.isEmpty ? 0.2 : 0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                        lineWidth: 2
                    )
            )
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .shadow(
                color: isFocused ? Color.purple.opacity(0.3) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: appeared)
    }
}

#Preview {
    CodeInputView(
        phoneNumber: .constant("+7 (999) 123-45-67"),
        onComplete: .constant(false),
        showPhoneInput: .constant(false)
    )
}
