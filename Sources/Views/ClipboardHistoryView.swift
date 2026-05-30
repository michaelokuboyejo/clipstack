import AppKit
import SwiftUI

struct ClipboardHistoryView: View {
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var historyStore: ClipboardHistoryStore
    @EnvironmentObject private var clipboardMonitor: ClipboardMonitor
    @State private var searchText = ""

    private var filteredItems: [ClipboardItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return historyStore.items
        }

        return historyStore.items.filter {
            $0.text.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            searchField

            Divider()

            historyList

            Divider()

            controls
        }
        .frame(width: 400, height: 520)
        .padding(14)
        .onChange(of: settings.maxHistoryItems) { _ in
            historyStore.enforceMaxHistoryItems()
        }
    }

    private var header: some View {
        HStack {
            Text("ClipStack")
                .font(.headline)

            Spacer()

            if settings.isMonitoringPaused {
                Text("Paused")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(itemCountText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var itemCountText: String {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(historyStore.items.count) items"
        }

        return "\(filteredItems.count) of \(historyStore.items.count)"
    }

    private var searchField: some View {
        TextField("Search history", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }

    @ViewBuilder
    private var historyList: some View {
        if historyStore.items.isEmpty {
            VStack {
                Spacer()

                Text("No clipboard history")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else if filteredItems.isEmpty {
            VStack {
                Spacer()

                Text("No matching items")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(filteredItems) { item in
                        HStack(spacing: 8) {
                            Button(action: {
                                clipboardMonitor.copyToClipboard(item)
                            }) {
                                ClipboardItemRow(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Button(action: {
                                historyStore.delete(item)
                            }) {
                                Image(systemName: "trash")
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .help("Delete")
                        }
                    }
                }
                .padding(.trailing, 12)
            }
        }
    }

    private var controls: some View {
        HStack {
            Button("Clear History") {
                historyStore.clear()
            }
            .keyboardShortcut(.delete, modifiers: [.command])

            Spacer()

            Toggle("Pause Monitoring", isOn: $settings.isMonitoringPaused)
                .toggleStyle(CheckboxToggleStyle())
                .keyboardShortcut("p", modifiers: [.command])

            Button("Open Settings") {
                openSettings()
            }
            .keyboardShortcut(",", modifiers: [.command])
        }
    }

    private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
