# ClipStack

ClipStack is a small macOS menu-bar clipboard history app built with Swift and SwiftUI.

It watches `NSPasteboard.general` for text clipboard changes, keeps a local history of copied text, and lets you copy older items back to the clipboard from a menu-bar popup.

## How It Works

- Runs as a menu-bar app using `MenuBarExtra` with `.window` style.
- Polls `NSPasteboard.general.changeCount` every 1 second.
- Stores text-only clipboard items.
- Ignores empty strings and duplicate latest items.
- Avoids re-adding items copied internally from ClipStack.
- Persists history as Codable JSON at:

```text
~/Library/Application Support/ClipStack/history.json
```

- Stores settings in `UserDefaults`.

## Requirements

- macOS 13 or newer.
- Xcode 14 or newer.
- Swift 5.7 or newer.

## Build

From the project directory:

```bash
swift build
```

Run tests:

```bash
swift test
```

## Package As A macOS App

Build and package the app bundle:

```bash
scripts/package_app.sh
```

This creates:

```text
dist/ClipStack.app
```

The bundle is ad-hoc signed locally.

## Install

After packaging, move the app to Applications:

```bash
cp -R dist/ClipStack.app /Applications/ClipStack.app
```

Then launch it:

```bash
open /Applications/ClipStack.app
```

You can also run it directly from the project:

```bash
open dist/ClipStack.app
```

## Use

- Click the ClipStack menu-bar icon to open clipboard history.
- Click a history item to copy it back to the clipboard.
- Use the search field to filter history.
- Click the trash button next to an item to delete it.
- Click **Clear History** to remove all saved items.
- Toggle **Pause Monitoring** to stop or resume clipboard capture.
- Click **Open Settings** to configure max history size and monitoring pause state.

Keyboard shortcuts:

- `Command + Delete`: Clear history.
- `Command + P`: Pause monitoring.
- `Command + ,`: Open settings.

## Settings

ClipStack currently supports:

- Max history size, default `100`.
- Pause monitoring toggle.

The max history size is clamped between `1` and `1000`.
