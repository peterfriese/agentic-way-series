import Foundation

/// Authenticated user profile exposed to the UI.
nonisolated struct AuthUser: Sendable, Equatable, Identifiable {
    var id: String { uid }

    let uid: String
    let displayName: String?
    let email: String?
    let photoURL: URL?

    init(
        uid: String,
        displayName: String? = nil,
        email: String? = nil,
        photoURL: URL? = nil
    ) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.photoURL = photoURL
    }
}

/// Represents the authentication lifecycle state for the app.
nonisolated enum AuthState: Sendable, Equatable {
    case loading
    case signedOut
    case signedIn(AuthUser)
}

/// Errors that can occur during Google Sign-In, Apple Sign-In, or Firebase Authentication.
nonisolated enum AuthError: Error, Sendable, Equatable, LocalizedError {
    case missingClientID
    case missingPresentingViewController
    case missingIDToken
    case missingNonce
    case invalidAppleCredential
    case cancelled
    case signInFailed(String)
    case signOutFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            "Google Sign-In is not configured (missing Firebase client ID)."
        case .missingPresentingViewController:
            "Unable to find a window to present sign-in."
        case .missingIDToken:
            "Sign-in did not return an ID token."
        case .missingNonce:
            "Apple Sign-In state expired. Please try again."
        case .invalidAppleCredential:
            "Apple Sign-In did not return a valid credential."
        case .cancelled:
            "Sign-in was cancelled."
        case .signInFailed(let message):
            message.isEmpty ? "Failed to sign in." : message
        case .signOutFailed(let message):
            message.isEmpty ? "Failed to sign out." : message
        }
    }
}
