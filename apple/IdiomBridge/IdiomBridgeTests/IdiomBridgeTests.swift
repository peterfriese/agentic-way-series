import Testing
@testable import IdiomBridge

private struct MockIdiomTranslationService: IdiomTranslating {
    let handler: @Sendable (String, IdiomLanguage, IdiomLanguage) async throws(IdiomBridgeError) -> String

    init(result: Result<String, IdiomBridgeError>) {
        self.handler = { _, _, _ throws(IdiomBridgeError) in
            try result.get()
        }
    }

    init(handler: @escaping @Sendable (String, IdiomLanguage, IdiomLanguage) async throws(IdiomBridgeError) -> String) {
        self.handler = handler
    }

    func translate(
        idiom: String,
        from sourceLanguage: IdiomLanguage,
        to targetLanguage: IdiomLanguage
    ) async throws(IdiomBridgeError) -> String {
        try await handler(idiom, sourceLanguage, targetLanguage)
    }
}

@MainActor
@Suite("IdiomBridgeViewModel")
struct IdiomBridgeTests {
    @Test("Initial state defaults to British English -> Brazilian Portuguese")
    func initialState() {
        let viewModel = IdiomBridgeViewModel(
            translationService: MockIdiomTranslationService(result: .success(""))
        )

        #expect(viewModel.idiomInput.isEmpty)
        #expect(viewModel.sourceLanguage == .britishEnglish)
        #expect(viewModel.targetLanguage == .brazilianPortuguese)
        #expect(viewModel.translatedIdiomOutput == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.translationState == .idle)
    }

    @Test("Translating empty or whitespace input sets validation error")
    func emptyInputShowsError() async {
        let viewModel = IdiomBridgeViewModel(
            translationService: MockIdiomTranslationService(result: .success("Chovendo canivetes"))
        )
        viewModel.idiomInput = "   \n  "

        await viewModel.translate()

        #expect(viewModel.translatedIdiomOutput == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == IdiomBridgeError.emptyInput.errorDescription)
        #expect(viewModel.translationState == .failed(IdiomBridgeError.emptyInput.errorDescription!))
    }

    @Test("Translates from British English to Brazilian Portuguese")
    func translateBritishToBrazilianPortuguese() async {
        let service = MockIdiomTranslationService { idiom, source, target in
            #expect(idiom == "It's raining cats and dogs")
            #expect(source == .britishEnglish)
            #expect(target == .brazilianPortuguese)
            return "Está chovendo canivetes"
        }
        let viewModel = IdiomBridgeViewModel(translationService: service)
        viewModel.idiomInput = "It's raining cats and dogs"

        await viewModel.translate()

        #expect(viewModel.translatedIdiomOutput == "Está chovendo canivetes")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.translationState == .translated("Está chovendo canivetes"))
    }

    @Test("Translates arbitrary language pair (German -> British English)")
    func translateGermanToBritishEnglish() async {
        let service = MockIdiomTranslationService { idiom, source, target in
            #expect(idiom == "Es gießt wie aus Eimern")
            #expect(source == .german)
            #expect(target == .britishEnglish)
            return "It's raining cats and dogs"
        }
        let viewModel = IdiomBridgeViewModel(translationService: service)
        viewModel.sourceLanguage = .german
        viewModel.targetLanguage = .britishEnglish
        viewModel.idiomInput = "Es gießt wie aus Eimern"

        await viewModel.translate()

        #expect(viewModel.translatedIdiomOutput == "It's raining cats and dogs")
        #expect(viewModel.translationState == .translated("It's raining cats and dogs"))
    }

    @Test("Translates Brazilian Portuguese -> German")
    func translateBrazilianPortugueseToGerman() async {
        let service = MockIdiomTranslationService { idiom, source, target in
            #expect(idiom == "Mamão com açúcar")
            #expect(source == .brazilianPortuguese)
            #expect(target == .german)
            return "Ein Kinderspiel"
        }
        let viewModel = IdiomBridgeViewModel(translationService: service)
        viewModel.sourceLanguage = .brazilianPortuguese
        viewModel.targetLanguage = .german
        viewModel.idiomInput = "Mamão com açúcar"

        await viewModel.translate()

        #expect(viewModel.translatedIdiomOutput == "Ein Kinderspiel")
        #expect(viewModel.translationState == .translated("Ein Kinderspiel"))
    }

    @Test("Selecting the same language on source auto-swaps target")
    func selectingSameSourceAutoSwapsTarget() async {
        let viewModel = IdiomBridgeViewModel(
            translationService: MockIdiomTranslationService(result: .success("Mamão com açúcar"))
        )
        viewModel.idiomInput = "Piece of cake"
        await viewModel.translate()
        #expect(viewModel.translatedIdiomOutput == "Mamão com açúcar")

        // Source was .britishEnglish, Target was .brazilianPortuguese.
        // Setting source to .brazilianPortuguese should auto-swap target to .britishEnglish.
        viewModel.sourceLanguage = .brazilianPortuguese

        #expect(viewModel.sourceLanguage == .brazilianPortuguese)
        #expect(viewModel.targetLanguage == .britishEnglish)
        #expect(viewModel.translatedIdiomOutput == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.idiomInput == "Piece of cake")
    }

    @Test("Selecting the same language on target auto-swaps source")
    func selectingSameTargetAutoSwapsSource() {
        let viewModel = IdiomBridgeViewModel(
            translationService: MockIdiomTranslationService(result: .success(""))
        )

        // Source was .britishEnglish, Target was .brazilianPortuguese.
        // Setting target to .britishEnglish should auto-swap source to .brazilianPortuguese.
        viewModel.targetLanguage = .britishEnglish

        #expect(viewModel.sourceLanguage == .brazilianPortuguese)
        #expect(viewModel.targetLanguage == .britishEnglish)
    }

    @Test("swapLanguages swaps source and target and clears stale output")
    func swapLanguagesSwapsAndClearsOutput() async {
        let viewModel = IdiomBridgeViewModel(
            translationService: MockIdiomTranslationService(result: .success("Mamão com açúcar"))
        )
        viewModel.idiomInput = "Piece of cake"
        await viewModel.translate()
        #expect(viewModel.translatedIdiomOutput == "Mamão com açúcar")

        viewModel.swapLanguages()

        #expect(viewModel.sourceLanguage == .brazilianPortuguese)
        #expect(viewModel.targetLanguage == .britishEnglish)
        #expect(viewModel.translatedIdiomOutput == nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Translation failure surfaces error message")
    func failedTranslation() async {
        let viewModel = IdiomBridgeViewModel(
            translationService: MockIdiomTranslationService(result: .failure(.emptyResponse))
        )
        viewModel.idiomInput = "Bob's your uncle"

        await viewModel.translate()

        #expect(viewModel.translatedIdiomOutput == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == IdiomBridgeError.emptyResponse.errorDescription)
    }

    @Test("Editing input clears previous error message")
    func editingInputClearsError() async {
        let viewModel = IdiomBridgeViewModel(
            translationService: MockIdiomTranslationService(result: .failure(.emptyResponse))
        )
        await viewModel.translate()
        #expect(viewModel.errorMessage != nil)

        viewModel.idiomInput = "Piece of cake"
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Clear resets input, output, and error")
    func clearResetsState() async {
        let viewModel = IdiomBridgeViewModel(
            translationService: MockIdiomTranslationService(result: .success("Mamão com açúcar"))
        )
        viewModel.idiomInput = "Piece of cake"
        await viewModel.translate()

        viewModel.clear()

        #expect(viewModel.idiomInput.isEmpty)
        #expect(viewModel.translatedIdiomOutput == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.translationState == .idle)
    }

    @Test("Prompt builder includes idiom, source language, and target language")
    func promptIncludesIdiomAndLanguages() {
        let prompt = FirebaseIdiomTranslationService.makePrompt(
            for: "Daumen drücken",
            from: .german,
            to: .britishEnglish
        )
        #expect(prompt.contains("Daumen drücken"))
        #expect(prompt.contains("German idiom"))
        #expect(prompt.contains("British English idiom"))
    }

    @Test("IdiomLanguage provides display metadata for all cases")
    func languageMetadata() {
        #expect(IdiomLanguage.allCases == [.britishEnglish, .brazilianPortuguese, .german])
        #expect(IdiomLanguage.britishEnglish.displayName == "British English")
        #expect(IdiomLanguage.britishEnglish.flagEmoji == "🇬🇧")
        #expect(IdiomLanguage.brazilianPortuguese.displayName == "Brazilian Portuguese")
        #expect(IdiomLanguage.brazilianPortuguese.flagEmoji == "🇧🇷")
        #expect(IdiomLanguage.german.displayName == "German")
        #expect(IdiomLanguage.german.flagEmoji == "🇩🇪")
    }
}
