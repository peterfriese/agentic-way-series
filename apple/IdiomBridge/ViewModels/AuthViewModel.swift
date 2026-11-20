import AuthenticationServices
import Foundation
import Observation

/// ViewModel managing user authentication state, Google Sign-In, and Sign in with Apple.
@MainActor
@Observable
final class AuthViewModel {
    /// Current authentication state (`.loading`, `.signedOut`, or `.signedIn(AuthUser)`).
    private(set) var authState: AuthState = .loading

    /// Whether a sign-in flow is currently in progress.
    private(set) var isSigningIn: Bool = false

    /// User-facing error message from sign-in or sign-out failure.
    private(set) var errorMessage: String?

    /// Convenience accessor for the currently signed-in user.
    var currentUser: AuthUser? {
        if case .signedIn(let user) = authState {
            return user
        }
        return nil
    }

    private let authService: any AuthServicing
    private var authListenerTask: Task<Void, Never>?
    private var currentAppleNonce: String?

    init(
        authService: any AuthServicing = FirebaseAuthService(),
        startsListening: Bool = true
    ) {
        self.authService = authService
        if startsListening {
            startListening()
        }
    }

    isolated deinit {
        authListenerTask?.cancel()
    }

    /// Starts observing Firebase auth state changes if not already listening.
    func startListening() {
        guard authListenerTask == nil else { return }
        authListenerTask = Task { [weak self] in
            guard let self else { return }
            for await user in authService.authStateStream() {
                if Task.isCancelled { break }
                self.authState = user.map(AuthState.signedIn) ?? .signedOut
            }
        }
    }

    /// Initiates Google Sign-In and exchanges credentials with Firebase Auth.
    func signInWithGoogle() async {
        guard !isSigningIn else { return }
        isSigningIn = true
        errorMessage = nil
        defer { isSigningIn = false }

        do {
            let user = try await authService.signInWithGoogle()
            authState = .signedIn(user)
        } catch .cancelled {
            // User dismissed the sign-in sheet; no error banner needed.
        } catch {
            errorMessage = error.errorDescription ?? "Failed to sign in with Google."
        }
    }

    /// Configures a native `SignInWithAppleButton` request with scopes and a SHA-256 nonce.
    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = FirebaseAuthService.randomNonceString()
        currentAppleNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = FirebaseAuthService.sha256(nonce)
    }

    /// Handles the completion result from SwiftUI's `SignInWithAppleButton`.
    func handleAppleSignInCompletion(_ result: Result<ASAuthorization, any Error>) async {
        switch result {
        case .failure(let error):
            currentAppleNonce = nil
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                return
            }
            errorMessage = error.localizedDescription

        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = appleIDCredential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8),
                  !idToken.isEmpty else {
                currentAppleNonce = nil
                errorMessage = AuthError.invalidAppleCredential.errorDescription
                return
            }

            guard let rawNonce = currentAppleNonce, !rawNonce.isEmpty else {
                errorMessage = AuthError.missingNonce.errorDescription
                return
            }
            currentAppleNonce = nil

            await signInWithApple(
                idToken: idToken,
                rawNonce: rawNonce,
                fullName: appleIDCredential.fullName
            )
        }
    }

    /// Signs in with an Apple ID token and raw nonce via Firebase Auth.
    func signInWithApple(
        idToken: String,
        rawNonce: String,
        fullName: PersonNameComponents? = nil
    ) async {
        guard !isSigningIn else { return }
        isSigningIn = true
        errorMessage = nil
        defer { isSigningIn = false }

        do {
            let user = try await authService.signInWithApple(
                idToken: idToken,
                rawNonce: rawNonce,
                fullName: fullName
            )
            authState = .signedIn(user)
        } catch .cancelled {
            // No error banner on user cancellation.
        } catch {
            errorMessage = error.errorDescription ?? "Failed to sign in with Apple."
        }
    }

    /// Signs out of Google Sign-In and Firebase Auth.
    func signOut() async {
        errorMessage = nil
        do {
            try await authService.signOut()
            authState = .signedOut
        } catch {
            errorMessage = error.errorDescription ?? "Failed to sign out."
        }
    }

    /// Clears the current authentication error message.
    func dismissError() {
        errorMessage = nil
    }
}
