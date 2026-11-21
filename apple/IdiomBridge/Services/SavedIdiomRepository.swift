import FirebaseFirestore
import Foundation

/// Abstraction for persisting and observing a user's favorite idioms.
protocol SavedIdiomRepositoryProtocol: Sendable {
    func save(_ idiom: SavedIdiom, forUserID userID: String) async throws
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

    func save(_ idiom: SavedIdiom, forUserID userID: String) async throws {
        let data: [String: Any] = [
            "sourceText": idiom.sourceText,
            "translatedText": idiom.translatedText,
            "sourceLanguage": idiom.sourceLanguage.rawValue,
            "targetLanguage": idiom.targetLanguage.rawValue,
            "createdAt": Timestamp(date: idiom.createdAt),
        ]
        try await idiomsCollection(for: userID).document(idiom.id).setData(data)
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
                    let items = documents.compactMap { document -> SavedIdiom? in
                        let data = document.data()
                        guard
                            let sourceText = data["sourceText"] as? String,
                            let translatedText = data["translatedText"] as? String,
                            let sourceRaw = data["sourceLanguage"] as? String,
                            let targetRaw = data["targetLanguage"] as? String,
                            let sourceLanguage = IdiomLanguage(rawValue: sourceRaw),
                            let targetLanguage = IdiomLanguage(rawValue: targetRaw)
                        else {
                            return nil
                        }
                        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                        return SavedIdiom(
                            id: document.documentID,
                            sourceText: sourceText,
                            translatedText: translatedText,
                            sourceLanguage: sourceLanguage,
                            targetLanguage: targetLanguage,
                            createdAt: createdAt
                        )
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
