import CryptoKit
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
import Security
import UIKit

/// Protocol abstracting Firebase Authentication, Google Sign-In, and Apple Sign-In for testability.
protocol AuthServicing: Sendable {
    func currentUser() async -> AuthUser?
    func authStateStream() -> AsyncStream<AuthUser?>
    func signInWithGoogle() async throws(AuthError) -> AuthUser
    func signInWithApple(
        idToken: String,
        rawNonce: String,
        fullName: PersonNameComponents?
    ) async throws(AuthError) -> AuthUser
    func signOut() async throws(AuthError)
}

/// Thread-safe wrapper around Firebase Auth's `AuthStateDidChangeListenerHandle` (`NSObjectProtocol`),
/// which is only passed to `Auth.auth().removeStateDidChangeListener(_:)` on stream termination.
private nonisolated final class ListenerHandleBox: @unchecked Sendable {
    let handle: any NSObjectProtocol

    init(_ handle: any NSObjectProtocol) {
        self.handle = handle
    }
}

/// Production authentication service backed by Firebase Auth, Google Sign-In, and Sign in with Apple.
struct FirebaseAuthService: AuthServicing {
    func currentUser() async -> AuthUser? {
        guard FirebaseApp.app() != nil else { return nil }
        return Auth.auth().currentUser.map(AuthUser.init(firebaseUser:))
    }

    func authStateStream() -> AsyncStream<AuthUser?> {
        AsyncStream { continuation in
            guard FirebaseApp.app() != nil else {
                continuation.yield(nil)
                continuation.finish()
                return
            }

            let handleBox = ListenerHandleBox(
                Auth.auth().addStateDidChangeListener { _, user in
                    continuation.yield(user.map(AuthUser.init(firebaseUser:)))
                }
            )

            continuation.onTermination = { _ in
                Auth.auth().removeStateDidChangeListener(handleBox.handle)
            }
        }
    }

    func signInWithGoogle() async throws(AuthError) -> AuthUser {
        guard let clientID = FirebaseApp.app()?.options.clientID, !clientID.isEmpty else {
            throw .missingClientID
        }

        let presentingViewController = await MainActor.run {
            Self.topViewController()
        }
        guard let presentingViewController else {
            throw .missingPresentingViewController
        }

        let idToken: String
        let accessToken: String
        do {
            let gidResult = try await Self.presentGoogleSignIn(
                clientID: clientID,
                presentingViewController: presentingViewController
            )
            guard let token = gidResult.user.idToken?.tokenString, !token.isEmpty else {
                throw AuthError.missingIDToken
            }
            idToken = token
            accessToken = gidResult.user.accessToken.tokenString
        } catch let error as AuthError {
            throw error
        } catch {
            let nsError = error as NSError
            if nsError.domain == kGIDSignInErrorDomain,
               nsError.code == GIDSignInError.canceled.rawValue {
                throw .cancelled
            }
            throw .signInFailed(error.localizedDescription)
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )

        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            return AuthUser(firebaseUser: authResult.user)
        } catch {
            throw .signInFailed(error.localizedDescription)
        }
    }

    func signInWithApple(
        idToken: String,
        rawNonce: String,
        fullName: PersonNameComponents?
    ) async throws(AuthError) -> AuthUser {
        guard !idToken.isEmpty else {
            throw .missingIDToken
        }
        guard !rawNonce.isEmpty else {
            throw .missingNonce
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: rawNonce,
            fullName: fullName
        )

        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            var resolvedDisplayName = authResult.user.displayName

            if let fullName {
                let formatted = PersonNameComponentsFormatter()
                    .string(from: fullName)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !formatted.isEmpty && (resolvedDisplayName?.isEmpty ?? true) {
                    let changeRequest = authResult.user.createProfileChangeRequest()
                    changeRequest.displayName = formatted
                    try await changeRequest.commitChanges()
                    resolvedDisplayName = formatted
                }
            }

            return AuthUser(
                uid: authResult.user.uid,
                displayName: resolvedDisplayName,
                email: authResult.user.email,
                photoURL: authResult.user.photoURL
            )
        } catch {
            throw .signInFailed(error.localizedDescription)
        }
    }

    func signOut() async throws(AuthError) {
        await MainActor.run {
            GIDSignIn.sharedInstance.signOut()
        }
        guard FirebaseApp.app() != nil else { return }

        do {
            try Auth.auth().signOut()
        } catch {
            throw .signOutFailed(error.localizedDescription)
        }
    }

    /// Generates a cryptographically secure random nonce string for Sign in with Apple.
    nonisolated static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            return UUID().uuidString.replacingOccurrences(of: "-", with: "")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    /// Computes the lowercase hex SHA-256 digest of the input nonce string.
    nonisolated static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    @MainActor
    private static func presentGoogleSignIn(
        clientID: String,
        presentingViewController: UIViewController
    ) async throws -> GIDSignInResult {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        return try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
    }

    @MainActor
    private static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let keyWindow = scenes
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
            ?? scenes.first?.windows.first

        var controller = keyWindow?.rootViewController
        while let presented = controller?.presentedViewController {
            controller = presented
        }
        return controller
    }
}

private extension AuthUser {
    init(firebaseUser: User) {
        self.init(
            uid: firebaseUser.uid,
            displayName: firebaseUser.displayName,
            email: firebaseUser.email,
            photoURL: firebaseUser.photoURL
        )
    }
}
