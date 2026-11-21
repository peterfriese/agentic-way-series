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

    /// Saved favorite idioms for the signed-in user.
    private(set) var favorites: [SavedIdiom] = []

    /// Whether a save operation is currently in flight.
    private(set) var isSaving: Bool = false

    /// User-facing error message from saving or deleting a favorite.
    private(set) var favoritesErrorMessage: String?

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
    private let injectedFavoritesRepository: (any SavedIdiomRepositoryProtocol)?
    private var favoritesRepository: any SavedIdiomRepositoryProtocol {
        if let injectedFavoritesRepository {
            return injectedFavoritesRepository
        }
        let repository = FirestoreSavedIdiomRepository()
        lazyFavoritesRepository = repository
        return repository
    }
    private var lazyFavoritesRepository: (any SavedIdiomRepositoryProtocol)?
    private var favoritesListenerTask: Task<Void, Never>?
    private var isUpdatingLanguages = false

    /// Creates a ViewModel with the default Firebase services, or injected mocks for testing.
    init(
        translationService: any IdiomTranslating = FirebaseIdiomTranslationService(),
        savedIdiomRepository: (any SavedIdiomRepositoryProtocol)? = nil
    ) {
        self.translationService = translationService
        self.injectedFavoritesRepository = savedIdiomRepository
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

    /// Starts observing favorite idioms for `userID`.
    func startListeningToFavorites(forUserID userID: String) {
        favoritesListenerTask?.cancel()
        favoritesErrorMessage = nil

        let stream = favoritesRepository.observeFavorites(forUserID: userID)
        favoritesListenerTask = Task { [weak self] in
            for await items in stream {
                guard !Task.isCancelled, let self else { break }
                self.favorites = items
            }
        }
    }

    /// Stops observing favorite idioms and clears the local cache.
    func stopListeningToFavorites() {
        favoritesListenerTask?.cancel()
        favoritesListenerTask = nil
        favorites = []
        favoritesErrorMessage = nil
    }

    /// Saves the current translation to the user's favorites.
    func saveCurrentTranslation(forUserID userID: String) async {
        let trimmedInput = idiomInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmedInput.isEmpty,
            let output = translatedIdiomOutput,
            !output.isEmpty,
            !isSaving,
            !isCurrentTranslationSaved
        else {
            return
        }

        isSaving = true
        favoritesErrorMessage = nil
        defer { isSaving = false }

        let item = SavedIdiom(
            sourceText: trimmedInput,
            translatedText: output,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )

        do {
            let saved = try await favoritesRepository.save(item, forUserID: userID)
            if !favorites.contains(where: { $0.id == saved.id }) {
                favorites.insert(saved, at: 0)
            }
        } catch {
            favoritesErrorMessage = error.localizedDescription
        }
    }

    /// Deletes a saved favorite idiom.
    func deleteFavorite(_ idiom: SavedIdiom, forUserID userID: String) async {
        guard let id = idiom.id else { return }
        favoritesErrorMessage = nil
        do {
            try await favoritesRepository.delete(id: id, forUserID: userID)
            favorites.removeAll { $0.id == id }
        } catch {
            favoritesErrorMessage = error.localizedDescription
        }
    }

    /// Clears the current favorites error message.
    func dismissFavoritesError() {
        favoritesErrorMessage = nil
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
