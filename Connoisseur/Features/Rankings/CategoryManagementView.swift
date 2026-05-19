//
//  CategoryManagementView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftData
import SwiftUI

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RankingCategory.createdAt) private var categories: [RankingCategory]
    @Binding var selectedCategoryID: UUID?
    @State private var editingCategory: RankingCategory?

    private var orderedCategories: [RankingCategory] {
        RankingCategory.ordered(categories)
    }

    var body: some View {
        List {
            Section {
                ForEach(orderedCategories) { category in
                    Button {
                        editingCategory = category
                    } label: {
                        CategoryManagementRow(category: category)
                    }
                    .buttonStyle(.plain)
                }
                .onMove(perform: moveCategories)
                .onDelete(perform: deleteCategories)
            } footer: {
                Text("Drag to reorder. Tap a category to edit it.")
            }
        }
        .navigationTitle("Manage Categories")
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
        .sheet(item: $editingCategory) { category in
            CategoryEditorView(category: category)
        }
    }

    private func moveCategories(from source: IndexSet, to destination: Int) {
        var reorderedCategories = orderedCategories
        reorderedCategories.move(fromOffsets: source, toOffset: destination)
        updateSortIndexes(for: reorderedCategories)
    }

    private func deleteCategories(at offsets: IndexSet) {
        let categoriesToDelete = offsets.map { orderedCategories[$0] }
        let deletedIDs = Set(categoriesToDelete.map(\.id))
        let remainingCategories = orderedCategories.filter { !deletedIDs.contains($0.id) }

        if let selectedCategoryID, deletedIDs.contains(selectedCategoryID) {
            self.selectedCategoryID = remainingCategories.first?.id
        }

        for category in categoriesToDelete {
            modelContext.delete(category)
        }

        updateSortIndexes(for: remainingCategories)
    }

    private func updateSortIndexes(for categories: [RankingCategory]) {
        for (index, category) in categories.enumerated() {
            category.sortIndex = index
            category.updatedAt = .now
        }
    }
}

private struct CategoryManagementRow: View {
    let category: RankingCategory

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(category.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if category.prompt.isEmpty {
                    Text("\(category.items.count) items, \(category.metrics.count) metrics")
                        .foregroundStyle(.secondary)
                } else {
                    Text(category.prompt)
                        .foregroundStyle(.secondary)
                }
            }
        } icon: {
            Image(systemName: category.symbolName)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(ConnoisseurTheme.tint(named: category.tintName), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 4)
    }
}
