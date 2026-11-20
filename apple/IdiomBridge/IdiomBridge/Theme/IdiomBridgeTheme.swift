import SwiftUI
import UIKit

/// Semantic iOS system surface and typography tokens for Idiom Bridge.
enum IdiomBridgeTheme {
    // MARK: - System Surfaces

    static let groupedBackground = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let badgeFill = Color(uiColor: .tertiarySystemFill)
    static let separator = Color(uiColor: .separator)

    // MARK: - Typography

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let placeholder = Color(uiColor: .placeholderText)
}
