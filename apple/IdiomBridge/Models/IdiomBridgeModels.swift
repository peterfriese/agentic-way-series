import Foundation

/// Supported languages for idiom translation.
nonisolated enum IdiomLanguage: String, Sendable, CaseIterable, Identifiable, Hashable, Codable {
    case britishEnglish
    case brazilianPortuguese
    case german
    case chileanSpanish

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
        case .chileanSpanish:
            "Chilean Spanish"
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
        case .chileanSpanish:
            "Chilean Spanish idiom - the expression Chileans actually use"
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
        case .chileanSpanish:
            "CHILEAN IDIOM"
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
        case .chileanSpanish:
            "🇨🇱"
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
        case .chileanSpanish:
            "Type the Chilean Spanish idiom"
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
        case .chileanSpanish:
            "You'll see the Chilean Spanish version of this idiom here"
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
        case .chileanSpanish:
            "Finding the Chilean Spanish equivalent..."
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

/// A translated idiom saved by the user for later review.
struct SavedIdiom: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let sourceText: String
    let translatedText: String
    let sourceLanguage: IdiomLanguage
    let targetLanguage: IdiomLanguage
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        sourceText: String,
        translatedText: String,
        sourceLanguage: IdiomLanguage,
        targetLanguage: IdiomLanguage,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.createdAt = createdAt
    }
}
