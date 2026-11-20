import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthViewModel()
    @State private var idiomViewModel = IdiomBridgeViewModel()

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            switch authViewModel.authState {
            case .loading:
                ZStack {
                    IdiomBridgeTheme.groupedBackground
                        .ignoresSafeArea()
                    ProgressView()
                }
            case .signedOut:
                SignInView(viewModel: authViewModel)
            case .signedIn(let user):
                IdiomBridgeScreen(
                    viewModel: idiomViewModel,
                    user: user,
                    onSignOut: {
                        Task {
                            await authViewModel.signOut()
                        }
                    }
                )
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: authViewModel.authState)
    }
}

/// Main Idiom Bridge screen using native iOS navigation, grouped surfaces,
/// and restrained Liquid Glass action controls.
struct IdiomBridgeScreen: View {
    @Bindable var viewModel: IdiomBridgeViewModel
    var user: AuthUser = AuthUser(uid: "preview", displayName: "Preview User", email: "preview@example.com")
    var onSignOut: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @FocusState private var isInputFocused: Bool
    @State private var isShowingAccountSheet = false

    private var canClear: Bool {
        !viewModel.idiomInput.isEmpty
            || viewModel.translatedIdiomOutput != nil
            || viewModel.errorMessage != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                IdiomBridgeTheme.groupedBackground
                    .ignoresSafeArea()
                    .onTapGesture {
                        isInputFocused = false
                    }

                VStack(spacing: 12) {
                    LanguagePairBar(
                        sourceLanguage: $viewModel.sourceLanguage,
                        targetLanguage: $viewModel.targetLanguage,
                        onSwap: {
                            withAnimation(reduceMotion ? nil : .snappy) {
                                viewModel.swapLanguages()
                            }
                        }
                    )
                    .disabled(viewModel.isLoading)

                    if verticalSizeClass == .compact {
                        HStack(spacing: 12) {
                            cardPair
                        }
                    } else {
                        VStack(spacing: 12) {
                            cardPair
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle("Idiom Bridge")
            .navigationBarTitleDisplayMode(verticalSizeClass == .compact ? .inline : .large)
            .toolbar {
                if canClear {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear", systemImage: "xmark") {
                            isInputFocused = false
                            withAnimation(reduceMotion ? nil : .snappy) {
                                viewModel.clear()
                            }
                        }
                        .accessibilityLabel("Clear idiom and translation")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Account", systemImage: "person") {
                        isInputFocused = false
                        isShowingAccountSheet = true
                    }
                    .accessibilityLabel("Account")
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isInputFocused = false
                    }
                }
            }
            .sheet(isPresented: $isShowingAccountSheet) {
                AccountSheetView(user: user, onSignOut: onSignOut)
            }
        }
    }

    @ViewBuilder
    private var cardPair: some View {
        InputIdiomCard(
            text: $viewModel.idiomInput,
            sourceLanguage: viewModel.sourceLanguage,
            targetLanguage: viewModel.targetLanguage,
            isLoading: viewModel.isLoading,
            isFocused: $isInputFocused,
            onTranslate: triggerTranslation
        )

        OutputIdiomCard(
            state: viewModel.translationState,
            targetLanguage: viewModel.targetLanguage
        )
    }

    private func triggerTranslation() {
        isInputFocused = false
        Task {
            await viewModel.translate()
        }
    }
}

private struct PreviewTranslationService: IdiomTranslating {
    let result: Result<String, IdiomBridgeError>

    func translate(
        idiom: String,
        from sourceLanguage: IdiomLanguage,
        to targetLanguage: IdiomLanguage
    ) async throws(IdiomBridgeError) -> String {
        try result.get()
    }
}

#Preview("Idle - Light") {
    IdiomBridgeScreen(
        viewModel: IdiomBridgeViewModel(
            translationService: PreviewTranslationService(result: .success("Chovendo canivetes"))
        )
    )
}

#Preview("Idle - Dark") {
    IdiomBridgeScreen(
        viewModel: IdiomBridgeViewModel(
            translationService: PreviewTranslationService(result: .success("Chovendo canivetes"))
        )
    )
    .preferredColorScheme(.dark)
}
