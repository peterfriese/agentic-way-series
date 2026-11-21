import FirebaseAI
import Foundation

/// Protocol for translating idioms between culturally equivalent expressions in supported languages.
protocol IdiomTranslating: Sendable {
    func translate(
        idiom: String,
        from sourceLanguage: IdiomLanguage,
        to targetLanguage: IdiomLanguage
    ) async throws(IdiomBridgeError) -> String
}

extension IdiomTranslating {
    /// Convenience overload defaulting to German -> British English.
    func translate(
        idiom: String,
        from sourceLanguage: IdiomLanguage = .german,
        to targetLanguage: IdiomLanguage = .britishEnglish
    ) async throws(IdiomBridgeError) -> String {
        try await translate(idiom: idiom, from: sourceLanguage, to: targetLanguage)
    }
}

/// Firebase AI Logic implementation of `IdiomTranslating` using the Gemini Developer API.
actor FirebaseIdiomTranslationService: IdiomTranslating {
    private let modelName: String
    private var cachedModel: GenerativeModel?

    init(modelName: String = "gemini-4-hydrogen") {
        self.modelName = modelName
    }

    func translate(
        idiom: String,
        from sourceLanguage: IdiomLanguage = .german,
        to targetLanguage: IdiomLanguage = .britishEnglish
    ) async throws(IdiomBridgeError) -> String {
        let trimmed = idiom.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw .emptyInput
        }

        let model = resolveModel()
        let prompt = Self.makePrompt(
            for: trimmed,
            from: sourceLanguage,
            to: targetLanguage
        )

        do {
            let response = try await model.generateContent(prompt)
            guard let translated = response.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !translated.isEmpty else {
                throw IdiomBridgeError.emptyResponse
            }
            return translated
        } catch let error as IdiomBridgeError {
            throw error
        } catch {
            throw .translationFailed(error.localizedDescription)
        }
    }

    private func resolveModel() -> GenerativeModel {
        if let cachedModel {
            return cachedModel
        }
        let model = FirebaseAI.firebaseAI(backend: .googleAI())
            .generativeModel(modelName: modelName)
        cachedModel = model
        return model
    }

    nonisolated static func makePrompt(
        for idiom: String,
        from sourceLanguage: IdiomLanguage = .german,
        to targetLanguage: IdiomLanguage = .britishEnglish
    ) -> String {
        """
        You are a bilingual cultural translation expert. Translate the input \(sourceLanguage.promptLanguageName) idiom to its closest culturally equivalent \(targetLanguage.promptSpeakerDescription) to convey the exact same meaning, tone, and humor, not a literal word-for-word translation. Return the exact \(targetLanguage.promptLanguageName) idiom as your response.

        \(idiom)
        """
    }
}
