import SwiftUI

/// Displays the user's saved favorite idioms with search, swipe-to-delete, and tap-to-load.
struct FavoritesView: View {
    let favorites: [SavedIdiom]
    let onSelect: (SavedIdiom) -> Void
    let onDelete: (SavedIdiom) -> Void

    @State private var searchText = ""

    private var filteredFavorites: [SavedIdiom] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return favorites }

        return favorites.filter { item in
            item.sourceText.localizedCaseInsensitiveContains(query)
                || item.translatedText.localizedCaseInsensitiveContains(query)
                || item.sourceLanguage.displayName.localizedCaseInsensitiveContains(query)
                || item.targetLanguage.displayName.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "No Favorites Yet",
                        systemImage: "star",
                        description: Text("Tap Save on any translated idiom to keep it here for quick review.")
                    )
                } else if filteredFavorites.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredFavorites) { item in
                            FavoriteIdiomRow(item: item) {
                                onSelect(item)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    onDelete(item)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(IdiomBridgeTheme.groupedBackground.ignoresSafeArea())
            .navigationTitle("Favorites")
            .searchable(text: $searchText, prompt: "Search idioms or languages")
        }
    }
}

private struct FavoriteIdiomRow: View {
    let item: SavedIdiom
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("\(item.sourceLanguage.flagEmoji) \(item.sourceLanguage.displayName)")
                    Image(systemName: "arrow.right")
                        .font(.caption2.weight(.semibold))
                        .accessibilityHidden(true)
                    Text("\(item.targetLanguage.flagEmoji) \(item.targetLanguage.displayName)")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(IdiomBridgeTheme.textSecondary)

                Text(item.translatedText)
                    .font(.headline)
                    .foregroundStyle(IdiomBridgeTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(item.sourceText)
                    .font(.subheadline)
                    .foregroundStyle(IdiomBridgeTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Loads this idiom in the Translate tab")
    }
}

#Preview("Favorites - Populated") {
    FavoritesView(
        favorites: [
            SavedIdiom(
                id: "preview-1",
                sourceText: "It's raining cats and dogs",
                translatedText: "Está chovendo canivetes",
                sourceLanguage: .britishEnglish,
                targetLanguage: .brazilianPortuguese
            ),
            SavedIdiom(
                id: "preview-2",
                sourceText: "Du bist auf dem Holzweg",
                translatedText: "You're barking up the wrong tree",
                sourceLanguage: .german,
                targetLanguage: .britishEnglish
            ),
        ],
        onSelect: { _ in },
        onDelete: { _ in }
    )
}

#Preview("Favorites - Empty") {
    FavoritesView(
        favorites: [],
        onSelect: { _ in },
        onDelete: { _ in }
    )
}
