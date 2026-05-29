import XCTest
@testable import ClipStack

final class ClipboardHistoryStoreTests: XCTestCase {
    private var temporaryDirectoryURL: URL!
    private var defaultsSuiteName: String!
    private var defaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()

        temporaryDirectoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: temporaryDirectoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        defaultsSuiteName = "ClipStackTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: defaultsSuiteName)
        defaults.removePersistentDomain(forName: defaultsSuiteName)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: temporaryDirectoryURL)
        defaults.removePersistentDomain(forName: defaultsSuiteName)
        defaults = nil
        defaultsSuiteName = nil
        temporaryDirectoryURL = nil

        try super.tearDownWithError()
    }

    func testAddTextIgnoresEmptyStrings() {
        let store = makeStore()

        store.addText("")

        XCTAssertTrue(store.items.isEmpty)
    }

    func testAddTextIgnoresDuplicateLatestItem() {
        let store = makeStore()

        store.addText("First")
        store.addText("First")

        XCTAssertEqual(store.items.map(\.text), ["First"])
    }

    func testAddTextKeepsMostRecentItemFirst() {
        let store = makeStore()

        store.addText("First")
        store.addText("Second")

        XCTAssertEqual(store.items.map(\.text), ["Second", "First"])
    }

    func testAddTextTrimsToMaxHistoryItems() {
        let settings = makeSettings()
        settings.maxHistoryItems = 2
        let store = makeStore(settings: settings)

        store.addText("First")
        store.addText("Second")
        store.addText("Third")

        XCTAssertEqual(store.items.map(\.text), ["Third", "Second"])
    }

    func testDeleteRemovesItem() {
        let store = makeStore()

        store.addText("First")
        store.addText("Second")
        let item = store.items[1]

        store.delete(item)

        XCTAssertEqual(store.items.map(\.text), ["Second"])
    }

    func testClearRemovesAllItems() {
        let store = makeStore()

        store.addText("First")
        store.addText("Second")
        store.clear()

        XCTAssertTrue(store.items.isEmpty)
    }

    func testHistoryPersistsToJSON() {
        let settings = makeSettings()
        let historyURL = makeHistoryURL()
        let firstStore = makeStore(settings: settings, historyURL: historyURL)

        firstStore.addText("Persisted")

        let secondStore = makeStore(settings: settings, historyURL: historyURL)

        XCTAssertEqual(secondStore.items.map(\.text), ["Persisted"])
    }

    func testSettingsPersistInUserDefaults() {
        let firstSettings = makeSettings()

        firstSettings.maxHistoryItems = 42
        firstSettings.isMonitoringPaused = true

        let secondSettings = makeSettings()

        XCTAssertEqual(secondSettings.maxHistoryItems, 42)
        XCTAssertTrue(secondSettings.isMonitoringPaused)
    }

    func testSettingsClampMaxHistoryItems() {
        let settings = makeSettings()

        settings.maxHistoryItems = 0

        XCTAssertEqual(settings.maxHistoryItems, 1)
    }

    private func makeSettings() -> SettingsStore {
        SettingsStore(defaults: defaults)
    }

    private func makeStore(
        settings: SettingsStore? = nil,
        historyURL: URL? = nil
    ) -> ClipboardHistoryStore {
        ClipboardHistoryStore(
            settings: settings ?? makeSettings(),
            historyURL: historyURL ?? makeHistoryURL()
        )
    }

    private func makeHistoryURL() -> URL {
        temporaryDirectoryURL
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("history.json", isDirectory: false)
    }
}
