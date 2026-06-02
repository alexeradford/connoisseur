//
//  MapEntriesAccessoryView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-26.
//

import SwiftUI

struct MapEntriesAccessoryView: View {
    let entryItems: [MapEntryItem]
    let locatedEntryCount: Int
    let selectedItem: MapEntryItem?
    let context: TabSheetContext
    let toggleExpansion: () -> Void
    let focus: (MapEntryItem) -> Void
    let dismissOverview: () -> Void

    var body: some View {
        Group {
            if let selectedItem {
                MapEntryOverviewView(
                    item: selectedItem,
                    context: context,
                    dismiss: dismissOverview
                )
            } else {
                listContent
            }
        }
        .clipped()
    }

    private var listContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if entryItems.isEmpty {
                ContentUnavailableView("No entries", systemImage: "star", description: Text("Entries you add to any list will appear here."))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                entriesList
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("My Rankings")
                .font(.title)
                .bold()
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text("\(entryItems.count) entries, \(locatedEntryCount) mapped")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(24)
    }

    private var entriesList: some View {
        List(entryItems) { item in
            Button {
                focus(item)
            } label: {
                MapEntryRow(item: item, isSelected: false)
            }
        }
        .contentMargins(.top, 12)
        .contentMargins(.bottom, max(context.bottomSafeArea, 10) + 12 + 196)
        .scrollIndicators(.hidden)
        .scrollDisabled(!context.isAtLargestDetent)
    }
}
