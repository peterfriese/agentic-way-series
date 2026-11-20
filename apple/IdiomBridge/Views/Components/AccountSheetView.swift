import SwiftUI

/// Account details sheet presenting the signed-in user's profile and Sign Out action.
struct AccountSheetView: View {
    let user: AuthUser
    let onSignOut: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        avatarView
                            .frame(width: 52, height: 52)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 3) {
                            Text(user.displayName ?? "Idiom Bridge User")
                                .font(.headline)
                                .foregroundStyle(IdiomBridgeTheme.textPrimary)

                            if let email = user.email, !email.isEmpty {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundStyle(IdiomBridgeTheme.textSecondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        dismiss()
                        onSignOut()
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    @ViewBuilder
    private var avatarView: some View {
        if let photoURL = user.photoURL {
            AsyncImage(url: photoURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    fallbackAvatar
                }
            }
        } else {
            fallbackAvatar
        }
    }

    private var fallbackAvatar: some View {
        ZStack {
            Color.accentColor.opacity(0.15)
            Image(systemName: "person")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.accentColor)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Account Sheet") {
    AccountSheetView(
        user: AuthUser(
            uid: "123",
            displayName: "Peter Friese",
            email: "peter@example.com"
        ),
        onSignOut: {}
    )
}
