//
//  RankingsHomeView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftData
import SwiftUI

struct RankingsHomeView: View {
    @Query(sort: \RankingCategory.createdAt) private var categories: [RankingCategory]
    @State private var selectedCategoryID: UUID?
    @State private var mode: RankingsMode = .list
    @State private var itemEditorCategory: RankingCategory?
    @State private var isCreatingCategory = false
    @State private var isManagingCategories = false

    private var orderedCategories: [RankingCategory] {
        RankingCategory.ordered(categories)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ConnoisseurTheme.background
                    .ignoresSafeArea()

                if let selectedCategory {
                    if mode == .list {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                CategorySwitcherView(
                                    categories: orderedCategories,
                                    selectedCategoryID: selectedCategory.id,
                                    selectedCategory: selectedCategory,
                                    selectCategory: selectCategory,
                                    moveSelection: moveSelection
                                )

                                RankingsListView(category: selectedCategory) {
                                    itemEditorCategory = selectedCategory
                                }
                            }
                            .padding()
                        }
                        .scrollIndicators(.hidden)
                    } else {
                        RankingMapView(
                            category: selectedCategory,
                            categories: orderedCategories,
                            selectedCategoryID: selectedCategory.id,
                            selectCategory: selectCategory,
                            moveSelection: moveSelection
                        )
                        .ignoresSafeArea(edges: [.horizontal, .bottom])
                    }
                }
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .navigation) {
                    Picker("Mode", selection: $mode) {
                        ForEach(RankingsMode.allCases) { mode in
                            Label(mode.title, systemImage: mode.symbolName)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(minWidth: 90)
                }
                
                ToolbarItem(placement: .automatic) {
                    if let selectedCategory {
                        categoryMenu(for: selectedCategory)
                    }
                }
#else
                ToolbarItem(placement: .topBarLeading) {
                    Picker("Mode", selection: $mode) {
                        ForEach(RankingsMode.allCases) { mode in
                            Label(mode.title, systemImage: mode.symbolName)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(minWidth: 90)
                }
                .sharedBackgroundVisibility(.hidden)
                
                ToolbarItem(placement: .topBarLeading) {
                    if let selectedCategory {
                        categoryMenu(for: selectedCategory)
                    }
                }
                .sharedBackgroundVisibility(.visible)
#endif

                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        if let selectedCategory {
                            itemEditorCategory = selectedCategory
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add item")
                    .buttonStyle(.borderedProminent)
                }
            }
            .sheet(item: $itemEditorCategory) { category in
                ItemEditorView(category: category, item: nil)
            }
            .sheet(isPresented: $isCreatingCategory) {
                CategoryEditorView(category: nil, sortIndex: nextCategorySortIndex) { category in
                    selectedCategoryID = category.id
                }
            }
            .navigationDestination(isPresented: $isManagingCategories) {
                CategoryManagementView(selectedCategoryID: $selectedCategoryID)
            }
            .onAppear {
                normalizeCategoryOrder()
                ensureSelection()
            }
            .onChange(of: categories.map(\.id)) {
                normalizeCategoryOrder()
                ensureSelection()
            }
        }
    }

    private var selectedCategory: RankingCategory? {
        if let selectedCategoryID, let category = orderedCategories.first(where: { $0.id == selectedCategoryID }) {
            return category
        }

        return orderedCategories.first
    }

    private var nextCategorySortIndex: Int {
        (categories.compactMap(\.sortIndex).max() ?? (categories.count - 1)) + 1
    }

    private func categoryMenu(for selectedCategory: RankingCategory) -> some View {
        Menu {
            Section("Categories") {
                ForEach(orderedCategories) { category in
                    Button {
                        selectCategory(category)
                    } label: {
                        if category.id == selectedCategory.id {
                            Label(category.title, systemImage: "checkmark")
                        } else {
                            Label(category.title, systemImage: category.symbolName)
                        }
                    }
                }
            }

            Section {
                Button {
                    isCreatingCategory = true
                } label: {
                    Label("New Category", systemImage: "plus")
                }

                Button {
                    isManagingCategories = true
                } label: {
                    Label("Manage Categories", systemImage: "slider.horizontal.3")
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selectedCategory.title)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Image(systemName: "chevron.down")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .font(.headline)
            .foregroundStyle(.primary)
            .frame(maxWidth: 200)
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
        .accessibilityLabel("Category")
    }

    private func ensureSelection() {
        if selectedCategoryID == nil || !orderedCategories.contains(where: { $0.id == selectedCategoryID }) {
            selectedCategoryID = orderedCategories.first?.id
        }
    }

    private func normalizeCategoryOrder() {
        let categoriesInOrder = orderedCategories

        for (index, category) in categoriesInOrder.enumerated() where category.sortIndex != index {
            category.sortIndex = index
        }
    }

    private func selectCategory(_ category: RankingCategory) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            selectedCategoryID = category.id
        }
    }

    private func moveSelection(_ direction: CategorySwitcherView.Direction) {
        guard let selectedCategory, let index = orderedCategories.firstIndex(where: { $0.id == selectedCategory.id }) else { return }

        let nextIndex: Int
        switch direction {
        case .previous:
            nextIndex = max(0, index - 1)
        case .next:
            nextIndex = min(orderedCategories.count - 1, index + 1)
        }

        guard nextIndex != index else { return }
        selectCategory(orderedCategories[nextIndex])
    }
}

enum RankingsMode: String, CaseIterable, Identifiable {
    case list
    case map

    var id: String { rawValue }

    var title: String {
        switch self {
        case .list:
            "Rank"
        case .map:
            "Map"
        }
    }

    var symbolName: String {
        switch self {
        case .list:
            "list.number"
        case .map:
            "map.fill"
        }
    }
}
