import Foundation
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

    @Test("Translates British English -> Chilean Spanish")
    func translateBritishToChileanSpanish() async {
        let service = MockIdiomTranslationService { idiom, source, target in
            #expect(idiom == "Piece of cake")
            #expect(source == .britishEnglish)
            #expect(target == .chileanSpanish)
            return "Papas"
        }
        let viewModel = IdiomBridgeViewModel(translationService: service)
        viewModel.targetLanguage = .chileanSpanish
        viewModel.idiomInput = "Piece of cake"

        await viewModel.translate()

        #expect(viewModel.translatedIdiomOutput == "Papas")
        #expect(viewModel.translationState == .translated("Papas"))
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
        let dePrompt = FirebaseIdiomTranslationService.makePrompt(
            for: "Daumen drücken",
            from: .german,
            to: .britishEnglish
        )
        #expect(dePrompt.contains("Daumen drücken"))
        #expect(dePrompt.contains("German idiom"))
        #expect(dePrompt.contains("British English idiom"))

        let clPrompt = FirebaseIdiomTranslationService.makePrompt(
            for: "Piece of cake",
            from: .britishEnglish,
            to: .chileanSpanish
        )
        #expect(clPrompt.contains("Piece of cake"))
        #expect(clPrompt.contains("Chilean Spanish idiom"))
    }

    @Test("IdiomLanguage provides display metadata for all cases")
    func languageMetadata() {
        #expect(IdiomLanguage.allCases == [.britishEnglish, .brazilianPortuguese, .german, .chileanSpanish])
        #expect(IdiomLanguage.britishEnglish.displayName == "British English")
        #expect(IdiomLanguage.britishEnglish.flagEmoji == "🇬🇧")
        #expect(IdiomLanguage.brazilianPortuguese.displayName == "Brazilian Portuguese")
        #expect(IdiomLanguage.brazilianPortuguese.flagEmoji == "🇧🇷")
        #expect(IdiomLanguage.german.displayName == "German")
        #expect(IdiomLanguage.german.flagEmoji == "🇩🇪")
        #expect(IdiomLanguage.chileanSpanish.displayName == "Chilean Spanish")
        #expect(IdiomLanguage.chileanSpanish.flagEmoji == "🇨🇱")
    }
}

private struct MockAuthService: AuthServicing {
    let initialUser: AuthUser?
    let streamUsers: [AuthUser?]
    let signInResult: Result<AuthUser, AuthError>
    let appleSignInResult: Result<AuthUser, AuthError>
    let signOutResult: Result<Void, AuthError>

    init(
        initialUser: AuthUser? = nil,
        streamUsers: [AuthUser?] = [nil],
        signInResult: Result<AuthUser, AuthError> = .failure(.cancelled),
        appleSignInResult: Result<AuthUser, AuthError> = .failure(.cancelled),
        signOutResult: Result<Void, AuthError> = .success(())
    ) {
        self.initialUser = initialUser
        self.streamUsers = streamUsers
        self.signInResult = signInResult
        self.appleSignInResult = appleSignInResult
        self.signOutResult = signOutResult
    }

    func currentUser() async -> AuthUser? {
        initialUser
    }

    func authStateStream() -> AsyncStream<AuthUser?> {
        let users = streamUsers
        return AsyncStream { continuation in
            for user in users {
                continuation.yield(user)
            }
            continuation.finish()
        }
    }

    func signInWithGoogle() async throws(AuthError) -> AuthUser {
        try signInResult.get()
    }

    func signInWithApple(
        idToken: String,
        rawNonce: String,
        fullName: PersonNameComponents?
    ) async throws(AuthError) -> AuthUser {
        try appleSignInResult.get()
    }

    func signOut() async throws(AuthError) {
        try signOutResult.get()
    }
}

@MainActor
@Suite("AuthViewModel")
struct AuthViewModelTests {
    @Test("Initial auth state starts loading and updates from auth stream")
    func initialAuthStateUpdatesFromStream() async {
        let expectedUser = AuthUser(
            uid: "user-123",
            displayName: "Ada Lovelace",
            email: "ada@example.com"
        )
        let viewModel = AuthViewModel(
            authService: MockAuthService(streamUsers: [expectedUser]),
            startsListening: false
        )

        #expect(viewModel.authState == .loading)
        #expect(viewModel.currentUser == nil)

        viewModel.startListening()
        for _ in 0..<50 {
            if viewModel.authState == .signedIn(expectedUser) { break }
            try? await Task.sleep(for: .milliseconds(10))
        }

        #expect(viewModel.authState == .signedIn(expectedUser))
        #expect(viewModel.currentUser == expectedUser)
    }

    @Test("Successful Google Sign-In updates authState to signedIn")
    func signInWithGoogleSucceeds() async {
        let expectedUser = AuthUser(
            uid: "user-456",
            displayName: "Grace Hopper",
            email: "grace@example.com"
        )
        let viewModel = AuthViewModel(
            authService: MockAuthService(signInResult: .success(expectedUser)),
            startsListening: false
        )

        await viewModel.signInWithGoogle()

        #expect(viewModel.authState == .signedIn(expectedUser))
        #expect(viewModel.currentUser == expectedUser)
        #expect(viewModel.isSigningIn == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Cancelled Google Sign-In does not surface an error banner")
    func cancelledSignInSetsNoError() async {
        let viewModel = AuthViewModel(
            authService: MockAuthService(signInResult: .failure(.cancelled)),
            startsListening: false
        )

        await viewModel.signInWithGoogle()

        #expect(viewModel.isSigningIn == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Failed Google Sign-In surfaces localized error message")
    func failedSignInSurfacesError() async {
        let viewModel = AuthViewModel(
            authService: MockAuthService(signInResult: .failure(.signInFailed("Network unavailable"))),
            startsListening: false
        )

        await viewModel.signInWithGoogle()

        #expect(viewModel.isSigningIn == false)
        #expect(viewModel.errorMessage == "Network unavailable")

        viewModel.dismissError()
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Sign out transitions authState to signedOut")
    func signOutTransitionsToSignedOut() async {
        let user = AuthUser(uid: "user-789", displayName: "Alan Turing")
        let viewModel = AuthViewModel(
            authService: MockAuthService(signInResult: .success(user)),
            startsListening: false
        )
        await viewModel.signInWithGoogle()
        #expect(viewModel.authState == .signedIn(user))

        await viewModel.signOut()

        #expect(viewModel.authState == .signedOut)
        #expect(viewModel.currentUser == nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Sign out failure surfaces error message")
    func signOutFailureSurfacesError() async {
        let viewModel = AuthViewModel(
            authService: MockAuthService(signOutResult: .failure(.signOutFailed("Keychain error"))),
            startsListening: false
        )

        await viewModel.signOut()

        #expect(viewModel.errorMessage == "Keychain error")
    }

    @Test("Successful Apple Sign-In updates authState to signedIn")
    func signInWithAppleSucceeds() async {
        let expectedUser = AuthUser(
            uid: "apple-user-123",
            displayName: "Tim Berners-Lee",
            email: "tim@example.com"
        )
        let viewModel = AuthViewModel(
            authService: MockAuthService(appleSignInResult: .success(expectedUser)),
            startsListening: false
        )

        var components = PersonNameComponents()
        components.givenName = "Tim"
        components.familyName = "Berners-Lee"

        await viewModel.signInWithApple(
            idToken: "mock-id-token",
            rawNonce: "mock-raw-nonce",
            fullName: components
        )

        #expect(viewModel.authState == .signedIn(expectedUser))
        #expect(viewModel.currentUser == expectedUser)
        #expect(viewModel.isSigningIn == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Failed Apple Sign-In surfaces error message")
    func failedAppleSignInSurfacesError() async {
        let viewModel = AuthViewModel(
            authService: MockAuthService(appleSignInResult: .failure(.signInFailed("Invalid Apple token"))),
            startsListening: false
        )

        await viewModel.signInWithApple(idToken: "bad-token", rawNonce: "nonce")

        #expect(viewModel.isSigningIn == false)
        #expect(viewModel.errorMessage == "Invalid Apple token")
    }

    @Test("Nonce generator and SHA-256 helper produce valid digests")
    func appleNonceAndSha256() {
        let nonce1 = FirebaseAuthService.randomNonceString()
        let nonce2 = FirebaseAuthService.randomNonceString()
        #expect(nonce1.count == 32)
        #expect(nonce1 != nonce2)

        let digest = FirebaseAuthService.sha256("hello")
        #expect(digest == "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }
}

@MainActor
@Suite("Favorites")
struct FavoritesTests {
    @Test("Saving current translation stores favorite and prevents duplicates")
    func saveCurrentTranslationAndPreventDuplicates() async {
        let viewModel = IdiomBridgeViewModel(
            translationService: MockIdiomTranslationService(result: .success("Está chovendo canivetes"))
        )

        viewModel.idiomInput = "It's raining cats and dogs"
        await viewModel.translate()
        #expect(viewModel.isCurrentTranslationSaved == false)

        viewModel.saveCurrentTranslation()
        #expect(viewModel.favorites.count == 1)
        #expect(viewModel.isCurrentTranslationSaved == true)

        // Second save should be ignored
        viewModel.saveCurrentTranslation()
        #expect(viewModel.favorites.count == 1)
    }

    @Test("Deleting a favorite removes it from favorites")
    func deleteFavorite() async {
        let viewModel = IdiomBridgeViewModel(
            translationService: MockIdiomTranslationService(result: .success("Ein Kinderspiel"))
        )

        viewModel.sourceLanguage = .brazilianPortuguese
        viewModel.targetLanguage = .german
        viewModel.idiomInput = "Mamão com açúcar"
        await viewModel.translate()
        viewModel.saveCurrentTranslation()
        #expect(viewModel.favorites.count == 1)

        let saved = viewModel.favorites[0]
        viewModel.deleteFavorite(saved)
        #expect(viewModel.favorites.isEmpty)
        #expect(viewModel.isCurrentTranslationSaved == false)
    }

    @Test("Loading a favorite restores language pair, input, and output")
    func loadFavorite() {
        let viewModel = IdiomBridgeViewModel(
            translationService: MockIdiomTranslationService(result: .success(""))
        )
        let saved = SavedIdiom(
            sourceText: "Du bist auf dem Holzweg",
            translatedText: "You're barking up the wrong tree",
            sourceLanguage: .german,
            targetLanguage: .britishEnglish
        )

        viewModel.loadFavorite(saved)

        #expect(viewModel.sourceLanguage == .german)
        #expect(viewModel.targetLanguage == .britishEnglish)
        #expect(viewModel.idiomInput == "Du bist auf dem Holzweg")
        #expect(viewModel.translatedIdiomOutput == "You're barking up the wrong tree")
        #expect(viewModel.translationState == .translated("You're barking up the wrong tree"))
    }
}
