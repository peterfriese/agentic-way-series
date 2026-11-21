# IdiomBridge

An Apple-platform app, built with [FlowDeck](https://flowdeck.studio).

`CLAUDE.md` in this project is a symlink to this file, so these instructions
apply to any coding agent.

## Building, running, testing

Use FlowDeck for all build / run / test work - it drives Xcode, simulators, and
devices for you:

- `flowdeck build` - build the app.
- `flowdeck run` - build and launch it.
- `flowdeck test` - run the test suites.

Run `flowdeck <command> --help` for options.

## Project format (Xcode 27 native JSON)

This project uses Xcode 27's native JSON-based `IdiomBridge.xcodeproj/project.xcproj`
with synchronized filesystem folders (`PBXFileSystemSynchronizedRootGroup`) and
a minimum deployment target of **iOS 27.0**.

- To add source files or resources, drop them into the target's folder; Xcode
  picks them up automatically without manual project registration.

## Architecture: MVVM

Source is organized by role:

- `Models/` - value types (`struct`/`enum`) holding data. No UI, no side effects.
- `ViewModels/` - `@Observable` classes that own state and logic for a screen.
  UI-agnostic (no SwiftUI imports beyond `Observation`) so they stay testable.
- `Views/` - SwiftUI views. Declarative and logic-free: they read from a view
  model and render. Push behavior down into the view model.

Guidelines:

- One primary type per file; name the file after the type.
- Keep views declarative; move decisions and mutations into the view model.
- Keep view models UI-agnostic and unit-testable; inject dependencies rather than
  reaching for globals.
- Models are value types.
- Add a view-model test alongside each new feature.
