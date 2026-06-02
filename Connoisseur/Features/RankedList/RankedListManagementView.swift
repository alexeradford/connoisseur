//
//  RankedListManagementView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftData
import SwiftUI

struct RankedListManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RankedList.createdAt) private var lists: [RankedList]
    @Binding var selectedListID: UUID?
    @State private var editingList: RankedList?
    
    var body: some View {
        List {
            Section {
                ForEach(lists) { list in
                    Button {
                        editingList = list
                    } label: {
                        RankedListManagementRow(list: list)
                    }
                    .buttonStyle(.plain)
                }
                .onMove(perform: moveLists)
                .onDelete(perform: deleteLists)
            } footer: {
                Text("Drag to reorder. Tap a list to edit it.")
            }
        }
        .navigationTitle("Manage Lists")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
#endif
        .sheet(item: $editingList) { list in
            RankedListEditorView(list: list)
        }
    }

    private func moveLists(from source: IndexSet, to destination: Int) {
        var relists = lists
        relists.move(fromOffsets: source, toOffset: destination)
        updateSortIndexes(for: relists)
    }

    private func deleteLists(at offsets: IndexSet) {
        let listsToDelete = offsets.map { lists[$0] }
        let deletedIDs = Set(listsToDelete.map(\.id))
        let remainingLists = lists.filter { !deletedIDs.contains($0.id) }

        if let selectedListID, deletedIDs.contains(selectedListID) {
            self.selectedListID = remainingLists.first?.id
        }

        for list in listsToDelete {
            modelContext.delete(list)
        }

        updateSortIndexes(for: remainingLists)
    }

    private func updateSortIndexes(for lists: [RankedList]) {
        for (index, list) in lists.enumerated() {
            list.sortIndex = index
            list.updatedAt = .now
        }
    }
}

private struct RankedListManagementRow: View {
    let list: RankedList

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(list.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if list.prompt.isEmpty {
                    Text("\(list.entryCount) entries, \(list.metricCount) metrics")
                        .foregroundStyle(.secondary)
                } else {
                    Text(list.prompt)
                        .foregroundStyle(.secondary)
                }
            }
        } icon: {
            RankedListIconView(
                list: list,
                size: 34,
                symbolFont: .headline
            )
        }
        .padding(.vertical, 4)
    }
}
