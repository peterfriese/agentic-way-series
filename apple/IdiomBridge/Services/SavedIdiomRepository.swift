import FirebaseFirestore
import Foundation

/// Abstraction for persisting and observing a user's favorite idioms.
protocol SavedIdiomRepositoryProtocol: Sendable {
    @discardableResult
    func save(_ idiom: SavedIdiom, forUserID userID: String) async throws -> SavedIdiom
    func delete(id: String, forUserID userID: String) async throws
    func observeFavorites(forUserID userID: String) -> AsyncStream<[SavedIdiom]>
}

/// Cloud Firestore implementation storing favorites under `users/{uid}/idioms`.
/// Offline persistence is enabled by default on iOS.
final class FirestoreSavedIdiomRepository: SavedIdiomRepositoryProtocol, @unchecked Sendable {
    private let database: Firestore

    init(database: Firestore = Firestore.firestore()) {
        self.database = database
    }

    private func idiomsCollection(for userID: String) -> CollectionReference {
        database.collection("users").document(userID).collection("idioms")
    }

    func save(_ idiom: SavedIdiom, forUserID userID: String) async throws -> SavedIdiom {
        let ref = try idiomsCollection(for: userID).addDocument(from: idiom)
        var saved = idiom
        saved.id = ref.documentID
        return saved
    }

    func delete(id: String, forUserID userID: String) async throws {
        try await idiomsCollection(for: userID).document(id).delete()
    }

    func observeFavorites(forUserID userID: String) -> AsyncStream<[SavedIdiom]> {
        let collection = idiomsCollection(for: userID)
            .order(by: "createdAt", descending: true)

        return AsyncStream { continuation in
            let listener = SendableListener(
                collection.addSnapshotListener { snapshot, _ in
                    guard let documents = snapshot?.documents else { return }
                    let items = documents.compactMap { document in
                        try? document.data(as: SavedIdiom.self)
                    }
                    continuation.yield(items)
                }
            )

            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
}

private nonisolated final class SendableListener: @unchecked Sendable {
    private let registration: any ListenerRegistration

    init(_ registration: any ListenerRegistration) {
        self.registration = registration
    }

    func remove() {
        registration.remove()
    }
}
