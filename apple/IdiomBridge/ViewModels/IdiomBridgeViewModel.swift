import Foundation
import Observation

/// ViewModel managing the Idiom Bridge screen state, translation workflow, and favorite idioms.
@MainActor
@Observable
final class IdiomBridgeViewModel {
    /// User's input text for the source idiom.
    var idiomInput: String = "" {
        didSet {
            if oldValue != idiomInput {
                errorMessage = nil
            }
        }
    }

    /// Selected source language for the input idiom.
    var sourceLanguage: IdiomLanguage = .german {
        didSet {
            guard !isUpdatingLanguages, oldValue != sourceLanguage else { return }
            isUpdatingLanguages = true
            defer { isUpdatingLanguages = false }

            if sourceLanguage == targetLanguage {
                targetLanguage = oldValue
            }
            translatedIdiomOutput = nil
            errorMessage = nil
        }
    }

    /// Selected target language for the translated idiom.
    var targetLanguage: IdiomLanguage = .britishEnglish {
        didSet {
            guard !isUpdatingLanguages, oldValue != targetLanguage else { return }
            isUpdatingLanguages = true
            defer { isUpdatingLanguages = false }

            if targetLanguage == sourceLanguage {
                sourceLanguage = oldValue
            }
            translatedIdiomOutput = nil
            errorMessage = nil
        }
    }

    /// The translated idiom in `targetLanguage`, if available.
    private(set) var translatedIdiomOutput: String?

    /// Whether a translation request is currently in flight.
    private(set) var isLoading: Bool = false

    /// User-facing error message from validation or translation failure.
    private(set) var errorMessage: String?

    /// Saved favorite idioms for the current session.
    private(set) var favorites: [SavedIdiom] = []

    /// Whether the currently displayed translation is already in `favorites`.
    var isCurrentTranslationSaved: Bool {
        let trimmedInput = idiomInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmedInput.isEmpty,
            let output = translatedIdiomOutput,
            !output.isEmpty
        else {
            return false
        }

        return favorites.contains { item in
            item.sourceText == trimmedInput
                && item.translatedText == output
                && item.sourceLanguage == sourceLanguage
                && item.targetLanguage == targetLanguage
        }
    }

    /// Unified state representation for declarative SwiftUI switching.
    var translationState: TranslationState {
        if isLoading {
            return .loading
        }
        if let errorMessage, !errorMessage.isEmpty {
            return .failed(errorMessage)
        }
        if let translatedIdiomOutput, !translatedIdiomOutput.isEmpty {
            return .translated(translatedIdiomOutput)
        }
        return .idle
    }

    private let translationService: any IdiomTranslating
    private var isUpdatingLanguages = false

    /// Creates a ViewModel with the default Firebase AI translation service, or an injected mock for testing.
    init(translationService: any IdiomTranslating = FirebaseIdiomTranslationService()) {
        self.translationService = translationService
    }

    /// Translates `idiomInput` from `sourceLanguage` to its cultural equivalent in `targetLanguage`.
    func translate() async {
        let trimmed = idiomInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = IdiomBridgeError.emptyInput.errorDescription
            return
        }
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        translatedIdiomOutput = nil
        defer { isLoading = false }

        do {
            translatedIdiomOutput = try await translationService.translate(
                idiom: trimmed,
                from: sourceLanguage,
                to: targetLanguage
            )
        } catch {
            errorMessage = error.errorDescription ?? "Failed to translate idiom. Please try again."
        }
    }

    /// Swaps `sourceLanguage` and `targetLanguage` and clears stale translation output.
    func swapLanguages() {
        isUpdatingLanguages = true
        defer { isUpdatingLanguages = false }

        let previousSource = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = previousSource
        translatedIdiomOutput = nil
        errorMessage = nil
    }

    /// Clears the current input, output, and error state.
    func clear() {
        idiomInput = ""
        translatedIdiomOutput = nil
        errorMessage = nil
    }

    /// Saves the current translation in memory.
    func saveCurrentTranslation() {
        let trimmedInput = idiomInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmedInput.isEmpty,
            let output = translatedIdiomOutput,
            !output.isEmpty,
            !isCurrentTranslationSaved
        else {
            return
        }

        let item = SavedIdiom(
            sourceText: trimmedInput,
            translatedText: output,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
        favorites.insert(item, at: 0)
    }

    /// Deletes a saved favorite idiom from memory.
    func deleteFavorite(_ idiom: SavedIdiom) {
        favorites.removeAll { $0.id == idiom.id }
    }

    /// Clears all in-memory favorites on sign out.
    func clearFavorites() {
        favorites = []
    }

    /// Loads a saved favorite into the Translate screen state.
    func loadFavorite(_ idiom: SavedIdiom) {
        isUpdatingLanguages = true
        defer { isUpdatingLanguages = false }

        sourceLanguage = idiom.sourceLanguage
        targetLanguage = idiom.targetLanguage
        idiomInput = idiom.sourceText
        translatedIdiomOutput = idiom.translatedText
        errorMessage = nil
    }
}
