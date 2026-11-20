import SwiftUI

/// Apple Translate / Google Translate-style language pair bar with native
/// dropdown `Menu` pickers on both sides and a center swap button.
struct LanguagePairBar: View {
    @Binding var sourceLanguage: IdiomLanguage
    @Binding var targetLanguage: IdiomLanguage
    let onSwap: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            languageMenu(
                title: "Source Language",
                selection: $sourceLanguage,
                accessibilityPrefix: "Source language",
                accessibilityHint: "Choose the source language"
            )

            Spacer(minLength: 2)

            Button("Swap languages", systemImage: "arrow.left.arrow.right", action: onSwap)
                .labelStyle(.iconOnly)
                .font(.caption.weight(.semibold))
                .foregroundStyle(IdiomBridgeTheme.textSecondary)
                .buttonStyle(.plain)
                .padding(6)
                .contentShape(Circle())
                .accessibilityHint("Swaps source and target languages")

            Spacer(minLength: 2)

            languageMenu(
                title: "Target Language",
                selection: $targetLanguage,
                accessibilityPrefix: "Target language",
                accessibilityHint: "Choose the target language"
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            IdiomBridgeTheme.cardBackground,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }

    private func languageMenu(
        title: String,
        selection: Binding<IdiomLanguage>,
        accessibilityPrefix: String,
        accessibilityHint: String
    ) -> some View {
        Menu {
            Picker(title, selection: selection) {
                ForEach(IdiomLanguage.allCases) { language in
                    Text("\(language.flagEmoji) \(language.displayName)")
                        .tag(language)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selection.wrappedValue.flagEmoji)
                    .accessibilityHidden(true)

                Text(selection.wrappedValue.displayName)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.accentColor.opacity(0.8))
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .layoutPriority(1)
        .accessibilityLabel("\(accessibilityPrefix): \(selection.wrappedValue.displayName)")
        .accessibilityHint(accessibilityHint)
    }
}

#Preview("Language Pair Bar", traits: .sizeThatFitsLayout) {
    @Previewable @State var source: IdiomLanguage = .britishEnglish
    @Previewable @State var target: IdiomLanguage = .brazilianPortuguese

    VStack(spacing: 12) {
        LanguagePairBar(
            sourceLanguage: $source,
            targetLanguage: $target,
            onSwap: {
                let current = source
                source = target
                target = current
            }
        )
        LanguagePairBar(
            sourceLanguage: .constant(.german),
            targetLanguage: .constant(.britishEnglish),
            onSwap: {}
        )
    }
    .padding()
    .background(IdiomBridgeTheme.groupedBackground)
}
