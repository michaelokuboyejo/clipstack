import Combine
import Foundation

final class ClipboardHistoryStore: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []

    private let settings: SettingsStore
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let fileManager: FileManager
    private let historyURL: URL

    init(
        settings: SettingsStore,
        fileManager: FileManager = .default,
        historyURL: URL? = nil
    ) {
        self.settings = settings
        self.fileManager = fileManager

        if let historyURL = historyURL {
            self.historyURL = historyURL
        } else {
            let applicationSupportURL = fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0]

            self.historyURL = applicationSupportURL
                .appendingPathComponent("ClipStack", isDirectory: true)
                .appendingPathComponent("history.json", isDirectory: false)
        }

        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        load()
        trimToMaxHistoryItems()
    }

    func addText(_ text: String) {
        guard !text.isEmpty else {
            return
        }

        if items.first?.text == text {
            return
        }

        items.insert(ClipboardItem(text: text), at: 0)
        trimToMaxHistoryItems()
        save()
    }

    func clear() {
        items.removeAll()
        save()
    }

    func delete(_ item: ClipboardItem) {
        deleteItem(withID: item.id)
    }

    func deleteItem(withID id: ClipboardItem.ID) {
        items.removeAll { $0.id == id }
        save()
    }

    func enforceMaxHistoryItems() {
        trimToMaxHistoryItems()
        save()
    }

    private func trimToMaxHistoryItems() {
        guard items.count > settings.maxHistoryItems else {
            return
        }

        items = Array(items.prefix(settings.maxHistoryItems))
    }

    private func load() {
        guard fileManager.fileExists(atPath: historyURL.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: historyURL)
            items = try decoder.decode([ClipboardItem].self, from: data)
        } catch {
            items = []
        }
    }

    private func save() {
        do {
            let directoryURL = historyURL.deletingLastPathComponent()
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )

            let data = try encoder.encode(items)
            try data.write(to: historyURL, options: [.atomic])
        } catch {
            assertionFailure("Failed to persist clipboard history: \(error)")
        }
    }
}
