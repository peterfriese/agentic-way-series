import Foundation
import Observation

/// ViewModel managing the Idiom Bridge screen state and translation workflow.
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
    var sourceLanguage: IdiomLanguage = .britishEnglish {
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
    var targetLanguage: IdiomLanguage = .brazilianPortuguese {
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
}
