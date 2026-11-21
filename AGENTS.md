# Agent Guidelines - Firebase: The Agentic Way

## Platform-Canonical Standards (Mandatory)
- **Strict platform-canonical quality:** Never cut corners, take shortcuts, or hand-roll approximations when official platform tools, APIs, or assets exist.
- **Visual assets & device frames:** Always use official raster/vendor assets (e.g., Apple Design Resources product bezels from `developer.apple.com/design/resources/` for iOS device frames) rather than hand-drawn SVG or CoreGraphics bezel paths.
- **Commit hygiene:** Use Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`) and never commit secrets (`GoogleService-Info.plist`, `google-services.json`).
- **Platform directories:** Keep `android/` and `apple/` symmetrical and self-contained.
- **No em-dashes:** Never use em-dashes anywhere in code, comments, documentation, or markdown files; use commas, colons, parentheses, or standard hyphens (`-`) instead.
- **Firebase skills (Mandatory):** Before writing or modifying any Cloud Firestore models, repositories, queries, or security rules, always read the `firebase-firestore` skill and its platform-specific setup guide (`ios_setup.md` or `android_sdk_usage.md`), and delegate `firestore.rules` authoring to `firestore-rules-author`.
