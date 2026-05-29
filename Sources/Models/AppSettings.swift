import Combine
import Foundation

final class SettingsStore: ObservableObject {
    private enum Keys {
        static let maxHistoryItems = "maxHistoryItems"
        static let isMonitoringPaused = "isMonitoringPaused"
    }

    private let defaults: UserDefaults

    @Published var maxHistoryItems: Int {
        didSet {
            let sanitizedValue = Self.sanitizeMaxHistoryItems(maxHistoryItems)

            if sanitizedValue != maxHistoryItems {
                maxHistoryItems = sanitizedValue
                return
            }

            defaults.set(sanitizedValue, forKey: Keys.maxHistoryItems)
        }
    }

    @Published var isMonitoringPaused: Bool {
        didSet {
            defaults.set(isMonitoringPaused, forKey: Keys.isMonitoringPaused)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedMaxHistoryItems = defaults.object(forKey: Keys.maxHistoryItems) as? Int
        maxHistoryItems = Self.sanitizeMaxHistoryItems(storedMaxHistoryItems ?? 100)
        isMonitoringPaused = defaults.bool(forKey: Keys.isMonitoringPaused)
    }

    private static func sanitizeMaxHistoryItems(_ value: Int) -> Int {
        min(max(value, 1), 1_000)
    }
}
