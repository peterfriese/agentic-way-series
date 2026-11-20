# Agent Guidelines — Firebase: The Agentic Way

## Platform-Canonical Standards (Mandatory)
- **Strict platform-canonical quality:** Never cut corners, take shortcuts, or hand-roll approximations when official platform tools, APIs, or assets exist.
- **Visual assets & device frames:** Always use official raster/vendor assets (e.g., Apple Design Resources product bezels from `developer.apple.com/design/resources/` for iOS device frames) rather than hand-drawn SVG or CoreGraphics bezel paths.
- **Commit hygiene:** Use Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`) and never commit secrets (`GoogleService-Info.plist`, `google-services.json`).
- **Platform directories:** Keep `android/` and `apple/` symmetrical and self-contained.
