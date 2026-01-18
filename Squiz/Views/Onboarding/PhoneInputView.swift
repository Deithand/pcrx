import SwiftUI

struct PhoneInputView: View {
    @Binding var showCodeInput: Bool
    @Binding var phoneNumber: String
    @State private var rawPhone = ""
    @State private var selectedCountry = Country.russia
    @State private var appeared = false
    @FocusState private var isPhoneFocused: Bool

    var body: some View {
        ZStack {
            AnimatedBackgroundView()

            VStack(spacing: 40) {
                Spacer()

                // Заголовок
                VStack(spacing: 12) {
                    Text("Твой номер")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -20)

                    Text("Отправим код для входа")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -20)
                }
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: appeared)

                // Ввод номера
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        // Picker страны
                        Menu {
                            ForEach(Country.allCountries, id: \.code) { country in
                                Button(action: {
                                    selectedCountry = country
                                    let impactMed = UIImpactFeedbackGenerator(style: .soft)
                                    impactMed.impactOccurred()
                                }) {
                                    HStack {
                                        Text(country.flag)
                                        Text(country.name)
                                        Spacer()
                                        Text(country.dialCode)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(selectedCountry.flag)
                                    .font(.system(size: 28))
                                Text(selectedCountry.dialCode)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }

                        // Поле ввода номера
                        TextField("", text: $rawPhone)
                            .focused($isPhoneFocused)
                            .keyboardType(.numberPad)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .placeholder(when: rawPhone.isEmpty) {
                                Text("(999) 123-45-67")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                isPhoneFocused ?
                                                    LinearGradient(
                                                        colors: [.purple, .blue, .cyan],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    ) :
                                                    LinearGradient(
                                                        colors: [Color.white.opacity(0.2)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    ),
                                                lineWidth: 2
                                            )
                                    )
                            )
                            .onChange(of: rawPhone) { _, newValue in
                                rawPhone = formatPhoneNumber(newValue)
                            }
                    }
                }
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: appeared)

                Spacer()

                // Кнопка продолжить
                GradientButton(title: "Продолжить") {
                    phoneNumber = selectedCountry.dialCode + " " + rawPhone
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showCodeInput = true
                    }
                }
                .disabled(rawPhone.count < 15) // (999) 123-45-67 = 17 chars
                .opacity(rawPhone.count >= 15 ? 1 : 0.5)
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: appeared)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPhoneFocused = true
            }
        }
    }

    private func formatPhoneNumber(_ number: String) -> String {
        let cleaned = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let maxLength = 10
        let truncated = String(cleaned.prefix(maxLength))

        var formatted = ""
        for (index, char) in truncated.enumerated() {
            if index == 0 {
                formatted.append("(")
            }
            formatted.append(char)
            if index == 2 {
                formatted.append(") ")
            } else if index == 5 {
                formatted.append("-")
            } else if index == 7 {
                formatted.append("-")
            }
        }

        return formatted
    }
}

struct Country {
    let code: String
    let name: String
    let dialCode: String
    let flag: String

    static let russia = Country(code: "RU", name: "Россия", dialCode: "+7", flag: "🇷🇺")
    static let usa = Country(code: "US", name: "США", dialCode: "+1", flag: "🇺🇸")
    static let uk = Country(code: "GB", name: "Великобритания", dialCode: "+44", flag: "🇬🇧")
    static let germany = Country(code: "DE", name: "Германия", dialCode: "+49", flag: "🇩🇪")
    static let france = Country(code: "FR", name: "Франция", dialCode: "+33", flag: "🇫🇷")

    static let allCountries = [russia, usa, uk, germany, france]
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    PhoneInputView(showCodeInput: .constant(false), phoneNumber: .constant(""))
}
