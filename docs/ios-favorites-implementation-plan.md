# Implementation Plan: Save & Retrieve Favorite Idioms (iOS)

## Overview
Add the ability for signed-in users to save translated idioms from the **Translate** screen and browse, search, load, or delete them in a dedicated **Favorites** tab, backed by Cloud Firestore with offline persistence enabled.

## Proposed Changes

### 1. Data Model & Firestore Persistence
- **Models** (`apple/IdiomBridge/Models/IdiomBridgeModels.swift`):
  - Add `SavedIdiom: Identifiable, Codable, Sendable, Equatable` with `id`, `sourceText`, `translatedText`, `sourceLanguage`, `targetLanguage`, and `createdAt`.
  - Make `IdiomLanguage` conform to `Codable` so language pairs serialize cleanly in Firestore.
- **Repository** (`apple/IdiomBridge/Services/SavedIdiomRepository.swift`, new file):
  - Define a `SavedIdiomRepositoryProtocol` (for unit testing and SwiftUI previews) and a `FirestoreSavedIdiomRepository` implementation.
  - Store documents under `users/{uid}/idioms` using the signed-in `AuthUser.uid`.
  - Rely on Cloud Firestore's default iOS offline persistence so saved idioms stay available offline and sync automatically when online.
- **Xcode Project Setup**:
  - Add `FirebaseFirestore` product dependency to the `IdiomBridge` target and register new Swift source files.
- **Security Rules** (`firestore.rules`):
  - Restrict read and write access on `users/{userId}/idioms/{idiomId}` to `request.auth != null && request.auth.uid == userId`.

### 2. State Management
- **`IdiomBridgeViewModel`** (`apple/IdiomBridge/ViewModels/IdiomBridgeViewModel.swift`):
  - Inject `SavedIdiomRepositoryProtocol` alongside `IdiomTranslating`.
  - Track `favorites: [SavedIdiom]`, `isSaving: Bool`, and whether the current translation is already saved (`isCurrentTranslationSaved`).
  - Add `saveCurrentTranslation(forUserID:)`, `deleteFavorite(_:forUserID:)`, `startListeningToFavorites(forUserID:)`, and `loadFavorite(_:)` (which populates `idiomInput`, `sourceLanguage`, `targetLanguage`, and `translatedIdiomOutput`).

### 3. UI Updates (HIG & Liquid Glass Aligned)
- **Save Action on Output Card** (`apple/IdiomBridge/Views/Components/OutputIdiomCard.swift`):
  - Inside a single `GlassEffectContainer(spacing: 8)` in the header, place a **Save** / **Saved** button next to **Copy** inside an `HStack(spacing: 8)` when `state` is `.translated`.
  - Use `.buttonStyle(.glass)` and `.buttonBorderShape(.capsule)` with `.controlSize(.small)` so both secondary actions share one glass sampling region and never compete with the primary `.glassProminent` **Translate** button on `InputIdiomCard`.
  - Use unenclosed SF Symbols (`star` / `star.fill` or `bookmark` / `bookmark.fill`, never `.circle` variants) so the glass capsule provides the sole enclosure.
  - Respect `@Environment(\.accessibilityReduceMotion)` and include `value:` on any `.animation(_:value:)`.
- **Tab Bar Navigation** (`apple/IdiomBridge/Views/ContentView.swift`):
  - Wrap the signed-in experience in a native `TabView` using SwiftUI's `Tab` API:
    1. **Translate** (`Tab("Translate", systemImage: "character.book.closed")`): hosts `IdiomBridgeScreen`.
    2. **Favorites** (`Tab("Favorites", systemImage: "star")`): hosts `FavoritesView`.
  - On iOS 26+, the native `TabView` automatically provides the system Liquid Glass tab bar; verify keyboard avoidance on `IdiomBridgeScreen` when the input field is focused.
- **Favorites Screen** (`apple/IdiomBridge/Views/FavoritesView.swift`, new file):
  - Native `NavigationStack` with `.navigationTitle("Favorites")`, a grouped `List` on `IdiomBridgeTheme.groupedBackground`, and `.searchable(text: $searchText)` filtering by idiom text or language.
  - Keep `List` rows strictly free of Liquid Glass (use standard grouped list row surfaces, never `.glassEffect` or `.glass` buttons inside scrolling rows).
  - Extract a unary `FavoriteIdiomRow` subview using stable `SavedIdiom.id` identity in `ForEach`.
  - Support swipe-to-delete (`.swipeActions` / `.onDelete`) and tap-to-load into the **Translate** tab.
  - Use `ContentUnavailableView` for the empty state ("No Favorites Yet") and `ContentUnavailableView.search(text: searchText)` when a search returns no matches.

## Verification Plan
- **Unit Tests** (`apple/IdiomBridgeTests/IdiomBridgeTests.swift`):
  - Test saving, duplicate prevention, deleting, and loading favorites in `IdiomBridgeViewModel` using a mock `SavedIdiomRepositoryProtocol`.
- **Build & Test**:
  - Run `flowdeck build` and `flowdeck test` on the iOS Simulator to verify compilation and all unit tests pass.
  - Visually inspect both the **Translate** tab (with **Save** next to **Copy**) and the **Favorites** tab in the iOS Simulator using FlowDeck.
