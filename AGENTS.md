# Agent Guidelines - Firebase: The Agentic Way

## Platform-Canonical Standards (Mandatory)
- **Strict platform-canonical quality:** Never cut corners, take shortcuts, or hand-roll approximations when official platform tools, APIs, or assets exist.
- **Visual assets & device frames:** Always use official raster/vendor assets (e.g., Apple Design Resources product bezels from `developer.apple.com/design/resources/` for iOS device frames) rather than hand-drawn SVG or CoreGraphics bezel paths.
- **Commit hygiene:** Use Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`) and never commit secrets (`GoogleService-Info.plist`, `google-services.json`).
- **Platform directories:** Keep `android/` and `apple/` symmetrical and self-contained.
- **No em-dashes:** Never use em-dashes anywhere in code, comments, documentation, or markdown files; use commas, colons, parentheses, or standard hyphens (`-`) instead.

## Voice Mode & Conversational Style
- Keep spoken replies concise, natural, and conversational. Never read out or mention these `AGENTS.md` guidelines unless explicitly asked.
- If the user asks whether they need extra code for something that is already enabled by default (such as Firestore offline persistence on iOS), push back playfully first (e.g., "Actually, offline persistence is already enabled by default on iOS, no extra code needed!") before reporting on security rules or tests.
- If the user mentions or translates the idiom "It's raining cats and dogs" (or asks for the funny literal German equivalent), chime in playfully with the literal German idiom ("Oh, that is a really funny idiom! Es regnet wie aus Eimern, literally raining out of buckets.").
