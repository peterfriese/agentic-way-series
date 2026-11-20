import AuthenticationServices
import SwiftUI

/// Native iOS sign-in screen offering Sign in with Apple and Sign in with Google.
struct SignInView: View {
    @Bindable var viewModel: AuthViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 68

    var body: some View {
        ZStack {
            IdiomBridgeTheme.groupedBackground
                .ignoresSafeArea()

            VStack(spacing: verticalSizeClass == .compact ? 16 : 28) {
                Spacer(minLength: 0)

                heroSection

                if let errorMessage = viewModel.errorMessage {
                    errorBanner(message: errorMessage)
                }

                signInButtons
                    .frame(maxWidth: 360)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }

    private var heroSection: some View {
        VStack(spacing: verticalSizeClass == .compact ? 8 : 14) {
            Image(systemName: "translate")
                .font(.system(size: heroIconSize * 0.48, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: heroIconSize, height: heroIconSize)
                .background(
                    Color.accentColor.gradient,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .accessibilityHidden(true)

            Text("Idiom Bridge")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(IdiomBridgeTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Sign in to translate idioms across British English, Brazilian Portuguese, German, and Chilean Spanish.")
                .font(.subheadline)
                .foregroundStyle(IdiomBridgeTheme.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
        }
    }

    private var signInButtons: some View {
        VStack(spacing: 12) {
            SignInWithAppleButton(.signIn) { request in
                viewModel.prepareAppleSignInRequest(request)
            } onCompletion: { result in
                Task {
                    await viewModel.handleAppleSignInCompletion(result)
                }
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .disabled(viewModel.isSigningIn)

            Button {
                Task {
                    await viewModel.signInWithGoogle()
                }
            } label: {
                ZStack {
                    HStack(spacing: 10) {
                        GoogleLogoMark()
                            .frame(width: 18, height: 18)
                            .accessibilityHidden(true)

                        Text("Sign in with Google")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(IdiomBridgeTheme.textPrimary)
                    }
                    .opacity(viewModel.isSigningIn ? 0 : 1)

                    ProgressView()
                        .controlSize(.small)
                        .opacity(viewModel.isSigningIn ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    IdiomBridgeTheme.cardBackground,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(IdiomBridgeTheme.separator.opacity(0.35), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSigningIn)
            .accessibilityLabel("Sign in with Google")
        }
    }

    private func errorBanner(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.red)
                .accessibilityHidden(true)

            Text(message)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Dismiss", systemImage: "xmark") {
                viewModel.dismissError()
            }
            .labelStyle(.iconOnly)
            .font(.caption.weight(.semibold))
            .foregroundStyle(IdiomBridgeTheme.textSecondary)
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(maxWidth: 360)
        .background(
            Color.red.opacity(0.10),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}

/// Vector Google "G" mark following Google Sign-In branding proportions.
private struct GoogleLogoMark: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let center = CGPoint(x: w / 2, y: h / 2)
            let radius = min(w, h) * 0.42
            let strokeWidth = min(w, h) * 0.19

            func arc(start: Angle, end: Angle, color: Color) {
                var path = Path()
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: start,
                    endAngle: end,
                    clockwise: false
                )
                context.stroke(
                    path,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .butt)
                )
            }

            arc(start: .degrees(-40), end: .degrees(45), color: Color(red: 0.259, green: 0.522, blue: 0.957))
            arc(start: .degrees(45), end: .degrees(145), color: Color(red: 0.204, green: 0.659, blue: 0.325))
            arc(start: .degrees(145), end: .degrees(215), color: Color(red: 0.984, green: 0.737, blue: 0.020))
            arc(start: .degrees(215), end: .degrees(320), color: Color(red: 0.918, green: 0.263, blue: 0.208))

            var bar = Path()
            bar.move(to: CGPoint(x: center.x, y: center.y))
            bar.addLine(to: CGPoint(x: center.x + radius + strokeWidth * 0.35, y: center.y))
            context.stroke(
                bar,
                with: .color(Color(red: 0.259, green: 0.522, blue: 0.957)),
                style: StrokeStyle(lineWidth: strokeWidth, lineCap: .butt)
            )
        }
    }
}

private struct PreviewAuthService: AuthServicing {
    func currentUser() async -> AuthUser? { nil }

    func authStateStream() -> AsyncStream<AuthUser?> {
        AsyncStream { $0.finish() }
    }

    func signInWithGoogle() async throws(AuthError) -> AuthUser {
        AuthUser(uid: "preview", displayName: "Preview User", email: "preview@example.com")
    }

    func signInWithApple(idToken: String, rawNonce: String, fullName: PersonNameComponents?) async throws(AuthError) -> AuthUser {
        AuthUser(uid: "preview", displayName: "Preview User", email: "preview@example.com")
    }

    func signOut() async throws(AuthError) {}
}

#Preview("Sign In - Light") {
    SignInView(viewModel: AuthViewModel(authService: PreviewAuthService(), startsListening: false))
}

#Preview("Sign In - Dark") {
    SignInView(viewModel: AuthViewModel(authService: PreviewAuthService(), startsListening: false))
        .preferredColorScheme(.dark)
}
