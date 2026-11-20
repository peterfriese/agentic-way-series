import SwiftUI

/// Compact language header pill displaying a flag emoji and language label.
struct LanguageBadge: View {
    private let flag: String
    private let title: LocalizedStringKey

    init(_ title: LocalizedStringKey, flag: String) {
        self.title = title
        self.flag = flag
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(flag)
                .font(.caption)
                .accessibilityHidden(true)

            Text(title)
                .font(.caption.weight(.semibold))
                .tracking(0.4)
                .foregroundStyle(IdiomBridgeTheme.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(IdiomBridgeTheme.badgeFill, in: .capsule)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Language Badges", traits: .sizeThatFitsLayout) {
    HStack(spacing: 12) {
        LanguageBadge("BRITISH IDIOM", flag: "🇬🇧")
        LanguageBadge("BRAZILIAN IDIOM", flag: "🇧🇷")
    }
    .padding()
}
