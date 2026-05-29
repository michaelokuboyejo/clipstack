import AppKit
import Combine
import Foundation

final class ClipboardMonitor: ObservableObject {
    private let pasteboard: NSPasteboard
    private let historyStore: ClipboardHistoryStore
    private let settings: SettingsStore
    private var timer: Timer?
    private var lastChangeCount: Int

    init(
        pasteboard: NSPasteboard = .general,
        historyStore: ClipboardHistoryStore,
        settings: SettingsStore
    ) {
        self.pasteboard = pasteboard
        self.historyStore = historyStore
        self.settings = settings
        lastChangeCount = pasteboard.changeCount

        startPolling()
    }

    deinit {
        timer?.invalidate()
    }

    func copyToClipboard(_ item: ClipboardItem) {
        pasteboard.clearContents()
        pasteboard.setString(item.text, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }

    private func startPolling() {
        timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.pollPasteboard()
        }

        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func pollPasteboard() {
        guard !settings.isMonitoringPaused else {
            lastChangeCount = pasteboard.changeCount
            return
        }

        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else {
            return
        }

        lastChangeCount = currentChangeCount

        guard let text = pasteboard.string(forType: .string), !text.isEmpty else {
            return
        }

        historyStore.addText(text)
    }
}
