# ADR 0001: Firestore Codable Mapping with `@DocumentID` and Strict Security Rules

- **Status:** Accepted
- **Date:** 2026-11-21
- **Scope:** Apple (`apple/IdiomBridge`) and Cloud Firestore Security Rules (`firestore.rules`)

## Context

In SwiftUI and Swift, models stored in Cloud Firestore typically conform to `Identifiable` and `Codable`. At the same time, production-grade `firestore.rules` enforce strict schema validation using `request.resource.data.keys().hasOnly([...])` and `hasAll([...])` to reject unexpected fields.

When a Swift `Codable` model defines a plain `let id: String` property, `Firestore.Encoder` (`setData(from:)`) serializes `id` as a field inside the Firestore document body. That causes two common failure modes:

1. **Security rule rejection:** If `firestore.rules` allows only the domain fields (for example `sourceText`, `translatedText`, `sourceLanguage`, `targetLanguage`, `createdAt`) and does not expect `"id"` in the document body, `hasOnly(...)` rejects the write with `PERMISSION_DENIED`.
2. **Manual dictionary workarounds:** Developers work around the mismatch by abandoning `Codable` and writing manual `[String: Any]` dictionaries and `document.data()` casting, which reintroduces stringly-typed keys, silent field-name drift, and boilerplate `Timestamp` / enum conversion code.

## Decision

1. **Use Firestore's native `Codable` APIs (`setData(from:)` and `document.data(as:)`):** Do not hand-roll `[String: Any]` dictionaries or manual `document.data()` unpacking for Firestore models.
2. **Use `@DocumentID` for the document identifier:** Declare `@DocumentID var id: String?` on Firestore-backed `Codable` models. `FirebaseFirestore` automatically populates `id` from `document.documentID` when decoding and omits `id` from the encoded document fields when writing, keeping the document payload aligned with `hasOnly(...)` security rules.
3. **Keep `Identifiable` stable in SwiftUI:** When `id` is `String?` via `@DocumentID`, SwiftUI `List` / `ForEach` can either use `Identifiable` directly (since `String?` satisfies `Identifiable` when `ID == String?`) or expose a non-optional fallback `id` / `stableID` for local-only previews and tests.
4. **Use `@ServerTimestamp` (optional) for server-authored timestamps:** When `firestore.rules` requires `request.time` or server-assigned timestamps, annotate the `Date?` property with `@ServerTimestamp` rather than manually injecting `Timestamp(date:)`.

## Canonical Pattern

```swift
import FirebaseFirestore
import Foundation

struct SavedIdiom: Identifiable, Codable, Sendable, Equatable {
    @DocumentID var id: String?
    let sourceText: String
    let translatedText: String
    let sourceLanguage: IdiomLanguage
    let targetLanguage: IdiomLanguage
    let createdAt: Date
}
```

Writing, updating, and reading in a repository:

```swift
// Add a new document (Firestore auto-generates a canonical document ID)
try collection.addDocument(from: idiom)

// Update an existing document (requires an existing @DocumentID; never fall back to UUID())
guard let id = idiom.id else {
    throw RepositoryError.missingDocumentID
}
try collection.document(id).setData(from: idiom, merge: true)

// Read (id is populated from document.documentID)
let items = snapshot.documents.compactMap { document in
    try? document.data(as: SavedIdiom.self)
}
```

> **Note on document IDs:** Always use `collection.addDocument(from:)` when creating new documents so Firestore generates its own canonical document IDs, rather than generating `UUID().uuidString` on the client. Reserve `collection.document(id).setData(from:)` for updates where `id` already comes from `@DocumentID`.

## Consequences

- **Positive:** Eliminates manual dictionary serialization, keeps Swift types and `firestore.rules` schemas in sync, and surfaces decoding mismatches cleanly.
- **Trade-off:** Models using `@DocumentID` import `FirebaseFirestore` (or define a thin persistence DTO in `Services/` if `Models/` must remain framework-free).
