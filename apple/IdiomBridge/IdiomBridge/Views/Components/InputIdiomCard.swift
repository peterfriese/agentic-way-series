import SwiftUI

/// Upper card where the user enters an idiom in `sourceLanguage` and triggers translation.
struct InputIdiomCard: View {
    @Binding var text: String
    let sourceLanguage: IdiomLanguage
    let targetLanguage: IdiomLanguage
    let isLoading: Bool
    var isFocused: FocusState<Bool>.Binding
    let onTranslate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            LanguageBadge(LocalizedStringKey(sourceLanguage.badgeLabel), flag: sourceLanguage.flagEmoji)

            TextField(
                sourceLanguage.inputPlaceholder,
                text: $text,
                prompt: Text(sourceLanguage.inputPlaceholder)
                    .foregroundStyle(IdiomBridgeTheme.placeholder),
                axis: .vertical
            )
            .focused(isFocused)
            .font(.title3.weight(.medium))
            .foregroundStyle(IdiomBridgeTheme.textPrimary)
            .lineLimit(1...6)
            .submitLabel(.go)
            .onSubmit(onTranslate)
            .disabled(isLoading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .accessibilityLabel("\(sourceLanguage.displayName) idiom input")

            HStack {
                Spacer(minLength: 0)

                GlassEffectContainer {
                    Button(action: onTranslate) {
                        ZStack {
                            HStack(spacing: 6) {
                                Text(targetLanguage.flagEmoji)
                                    .accessibilityHidden(true)

                                Text("Translate")
                                    .fontWeight(.semibold)

                                Image(systemName: "arrow.right")
                                    .font(.subheadline.weight(.semibold))
                                    .accessibilityHidden(true)
                            }
                            .opacity(isLoading ? 0 : 1)

                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                                .opacity(isLoading ? 1 : 0)
                        }
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.accentColor)
                    .buttonBorderShape(.capsule)
                    .controlSize(.regular)
                    .disabled(isLoading)
                    .accessibilityLabel(isLoading ? "Translating idiom" : "Translate to \(targetLanguage.displayName)")
                    .accessibilityHint("Finds the equivalent \(targetLanguage.displayName) idiom")
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            IdiomBridgeTheme.cardBackground,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

#Preview("Input Card") {
    @Previewable @State var text = "It's raining cats and dogs"
    @Previewable @FocusState var focused: Bool

    InputIdiomCard(
        text: $text,
        sourceLanguage: .britishEnglish,
        targetLanguage: .brazilianPortuguese,
        isLoading: false,
        isFocused: $focused,
        onTranslate: {}
    )
    .frame(height: 260)
    .padding()
    .background(IdiomBridgeTheme.groupedBackground)
}
