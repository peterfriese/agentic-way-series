import Foundation

/// Supported languages for idiom translation.
nonisolated enum IdiomLanguage: String, Sendable, CaseIterable, Identifiable, Hashable {
    case britishEnglish
    case brazilianPortuguese
    case german

    var id: Self { self }

    /// Human-readable language name for display and menus.
    var displayName: String {
        switch self {
        case .britishEnglish:
            "British English"
        case .brazilianPortuguese:
            "Brazilian Portuguese"
        case .german:
            "German"
        }
    }

    /// Language name used inside translation prompts.
    var promptLanguageName: String {
        displayName
    }

    /// Natural-speaker description used in translation prompts.
    var promptSpeakerDescription: String {
        switch self {
        case .britishEnglish:
            "British English idiom - the expression British English speakers actually use"
        case .brazilianPortuguese:
            "Brazilian Portuguese idiom - the expression Brazilians actually use"
        case .german:
            "German idiom - the expression German speakers actually use"
        }
    }

    /// Compact uppercase badge label for input and output cards.
    var badgeLabel: String {
        switch self {
        case .britishEnglish:
            "BRITISH IDIOM"
        case .brazilianPortuguese:
            "BRAZILIAN IDIOM"
        case .german:
            "GERMAN IDIOM"
        }
    }

    /// Flag emoji representing the language.
    var flagEmoji: String {
        switch self {
        case .britishEnglish:
            "🇬🇧"
        case .brazilianPortuguese:
            "🇧🇷"
        case .german:
            "🇩🇪"
        }
    }

    /// Input placeholder copy for the source card.
    var inputPlaceholder: String {
        switch self {
        case .britishEnglish:
            "Type the British idiom"
        case .brazilianPortuguese:
            "Type the Brazilian idiom"
        case .german:
            "Type the German idiom"
        }
    }

    /// Empty-state placeholder copy for the output card.
    var emptyStatePrompt: String {
        switch self {
        case .britishEnglish:
            "You'll see the British English version of this idiom here"
        case .brazilianPortuguese:
            "You'll see the Brazilian version of this idiom here"
        case .german:
            "You'll see the German version of this idiom here"
        }
    }

    /// Loading-state message while waiting for Gemini.
    var loadingMessage: String {
        switch self {
        case .britishEnglish:
            "Finding the British English equivalent..."
        case .brazilianPortuguese:
            "Finding the Brazilian equivalent..."
        case .german:
            "Finding the German equivalent..."
        }
    }
}

/// Errors that can occur while translating an idiom.
enum IdiomBridgeError: Error, Sendable, Equatable, LocalizedError {
    case emptyInput
    case emptyResponse
    case translationFailed(String)

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            "Please enter an idiom to translate."
        case .emptyResponse:
            "No translation was returned. Please try again."
        case .translationFailed(let message):
            message.isEmpty ? "Failed to translate idiom. Please try again." : message
        }
    }
}

/// Represents the current translation state for the Idiom Bridge UI.
enum TranslationState: Sendable, Equatable {
    case idle
    case loading
    case translated(String)
    case failed(String)
}
