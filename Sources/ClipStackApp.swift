import AppKit
import SwiftUI

@main
struct ClipStackApp: App {
    @StateObject private var settings = SettingsStore()
    @StateObject private var historyStore: ClipboardHistoryStore
    @StateObject private var clipboardMonitor: ClipboardMonitor

    init() {
        let settings = SettingsStore()
        let historyStore = ClipboardHistoryStore(settings: settings)
        let clipboardMonitor = ClipboardMonitor(
            historyStore: historyStore,
            settings: settings
        )

        _settings = StateObject(wrappedValue: settings)
        _historyStore = StateObject(wrappedValue: historyStore)
        _clipboardMonitor = StateObject(wrappedValue: clipboardMonitor)

        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        #if compiler(>=5.7)
        MenuBarExtra("ClipStack", systemImage: "doc.on.clipboard") {
            ClipboardHistoryView()
                .environmentObject(settings)
                .environmentObject(historyStore)
                .environmentObject(clipboardMonitor)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(settings)
                .environmentObject(historyStore)
        }
        #else
        WindowGroup("ClipStack") {
            ClipboardHistoryView()
                .environmentObject(settings)
                .environmentObject(historyStore)
                .environmentObject(clipboardMonitor)
        }

        Settings {
            SettingsView()
                .environmentObject(settings)
                .environmentObject(historyStore)
        }
        #endif
    }
}
