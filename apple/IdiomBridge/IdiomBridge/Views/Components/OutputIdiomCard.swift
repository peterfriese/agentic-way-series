import SwiftUI
import UIKit

/// Lower card displaying the idle placeholder, loading state, error message,
/// or translated idiom in the selected target language.
struct OutputIdiomCard: View {
    let state: TranslationState
    let targetLanguage: IdiomLanguage

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .title3) private var emptyIconSize: CGFloat = 28
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                LanguageBadge(LocalizedStringKey(targetLanguage.badgeLabel), flag: targetLanguage.flagEmoji)

                Spacer(minLength: 0)

                if case .translated(let output) = state {
                    GlassEffectContainer {
                        Button(
                            copied ? "Copied" : "Copy",
                            systemImage: copied ? "checkmark" : "doc.on.doc"
                        ) {
                            copyToClipboard(output)
                        }
                        .buttonStyle(.glass)
                        .buttonBorderShape(.capsule)
                        .controlSize(.small)
                        .font(.caption.weight(.medium))
                        .transition(.opacity)
                    }
                }
            }
            .frame(minHeight: 30)

            stateContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            IdiomBridgeTheme.cardBackground,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: state)
        .onChange(of: state) { _, _ in
            copied = false
        }
    }

    @ViewBuilder
    private var stateContent: some View {
        switch state {
        case .idle:
            VStack(spacing: 12) {
                Image(systemName: "text.bubble")
                    .font(.system(size: emptyIconSize, weight: .regular))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)

                Text(targetLanguage.emptyStatePrompt)
                    .font(.subheadline)
                    .foregroundStyle(IdiomBridgeTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 260)
            }
            .transition(.opacity)

        case .loading:
            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.regular)

                Text(targetLanguage.loadingMessage)
                    .font(.subheadline)
                    .foregroundStyle(IdiomBridgeTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .accessibilityElement(children: .combine)
            .transition(.opacity)

        case .failed(let message):
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title3)
                    .foregroundStyle(.red)
                    .accessibilityHidden(true)

                Text(message)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Error: \(message)")
            .transition(.opacity)

        case .translated(let output):
            Text(output)
                .font(.title3.weight(.semibold))
                .foregroundStyle(IdiomBridgeTheme.textPrimary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .transition(.opacity)
        }
    }

    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        withAnimation(reduceMotion ? nil : .snappy) {
            copied = true
        }
    }
}

#Preview("Output States") {
    VStack(spacing: 16) {
        OutputIdiomCard(state: .idle, targetLanguage: .brazilianPortuguese)
        OutputIdiomCard(state: .loading, targetLanguage: .german)
        OutputIdiomCard(state: .translated("Es regnet Bindfäden"), targetLanguage: .german)
        OutputIdiomCard(state: .failed("Please enter an idiom to translate."), targetLanguage: .brazilianPortuguese)
    }
    .padding()
    .background(IdiomBridgeTheme.groupedBackground)
}
