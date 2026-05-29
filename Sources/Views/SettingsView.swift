import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var historyStore: ClipboardHistoryStore

    var body: some View {
        Form {
            Stepper(
                value: $settings.maxHistoryItems,
                in: 1...1_000,
                step: 10
            ) {
                HStack {
                    Text("Max history size")

                    Spacer()

                    Text("\(settings.maxHistoryItems)")
                        .foregroundColor(.secondary)
                }
            }

            Toggle("Pause monitoring", isOn: $settings.isMonitoringPaused)
        }
        .padding(20)
        .frame(width: 360)
        .onChange(of: settings.maxHistoryItems) { _ in
            historyStore.enforceMaxHistoryItems()
        }
    }
}
