//
//  RankedListView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftData
import SwiftUI

struct RankedListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \RankedList.createdAt) private var lists: [RankedList]
    @State private var selectedListID: UUID?
    @State private var entryEditorList: RankedList?
    @State private var isCreatingList = false
    @State private var isManagingLists = false
    @State private var listNavigationPath: [UUID] = []
    @State private var didSetInitialNavigationPath = false
    @State private var sortOrder: RankedListSortOrder = .scoreDescending
    @Namespace private var listZoomNamespace
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]
    
    var body: some View {
        NavigationStack(path: $listNavigationPath) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(lists) { list in
                        NavigationLink(value: list.id) {
                            RankedListPreviewView(list: list)
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(id: list.id, in: listZoomNamespace)
                    }
                }
                .padding()
            }
            .zIndex(1)
            .background(ConnoisseurTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Lists")
            .sheet(item: $entryEditorList) { list in
                RankedEntryEditorView(list: list, entry: nil)
            }
            .sheet(isPresented: $isCreatingList) {
                RankedListEditorView(list: nil, sortIndex: nextListSortIndex) { list in
                    selectedListID = list.id
                    listNavigationPath = [list.id]
                }
            }
            .navigationDestination(isPresented: $isManagingLists) {
                RankedListManagementView(selectedListID: $selectedListID)
            }
            .onAppear {
                normalizeListOrder()
                ensureSelection()
                ensureInitialNavigationPath()
            }
            .onChange(of: lists.map(\.id)) {
                normalizeListOrder()
                ensureSelection()
                keepNavigationPathValid()
                ensureInitialNavigationPath()
            }
            .onChange(of: listNavigationPath) {
                updateSelectionFromNavigationPath()
            }
            .navigationDestination(for: UUID.self) { listID in
                if let list = lists.first(where: { $0.id == listID }) {
                    RankedListDetailView(
                        list: list,
                        entries: sortedEntries(for: list)
                    ) {
                        entryEditorList = list
                    }
                    .navigationBarBackButtonHidden(true)
                    .navigationTransition(.zoom(sourceID: list.id, in: listZoomNamespace))
                    .toolbar {
                        listToolbar(for: list)
                    }
                }
            }
            .toolbar {
                listPickerToolbar
            }
        }
    }
    
    private var nextListSortIndex: Int {
        (lists.compactMap(\.sortIndex).max() ?? (lists.count - 1)) + 1
    }
    
    @ToolbarContentBuilder
    private func listToolbar(for selectedList: RankedList) -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            RankedListPickerDismissButton()
        }

        ToolbarSpacer(.flexible, placement: .topBarLeading)

        ToolbarItem(placement: .topBarTrailing) {
            sortMenu
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            shareLink(for: selectedList)
        }

        ToolbarSpacer(.fixed, placement: .topBarTrailing)

        ToolbarItem(placement: .primaryAction) {
            Button {
                entryEditorList = selectedList
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add entry")
            .buttonStyle(.borderedProminent)
        }
    }
    
    @ToolbarContentBuilder
    private var listPickerToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button(action: presentListCreator) {
                Image(systemName: "plus")
            }
            .accessibilityLabel("New list")
            
            Button(action: presentListManager) {
                Image(systemName: "slider.horizontal.3")
            }
            .accessibilityLabel("Manage lists")
        }
    }
    
    private var sortMenu: some View {
        Menu {
            Picker("Sort", selection: $sortOrder) {
                ForEach(RankedListSortOrder.allCases) { sortOrder in
                    Label(sortOrder.title, systemImage: sortOrder.symbolName)
                        .tag(sortOrder)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.headline.weight(.bold))
        }
        .accessibilityLabel("Sort")
    }

    private func shareLink(for list: RankedList) -> some View {
        let image = RankedListShareImage(
            list: list,
            entries: sortedEntries(for: list),
            colorScheme: colorScheme
        )

        return ShareLink(
            item: image,
            subject: Text(list.title),
            preview: SharePreview(list.title)
        ) {
            Image(systemName: "square.and.arrow.up")
                .font(.headline.weight(.bold))
        }
        .accessibilityLabel("Share list")
    }
    
    private func sortedEntries(for list: RankedList) -> [RankedEntry] {
        sortOrder.sort(list.availableEntries, in: list)
    }
    
    private func ensureSelection() {
        if selectedListID == nil || !lists.contains(where: { $0.id == selectedListID }) {
            selectedListID = lists.first?.id
        }
    }
    
    private func updateSelectionFromNavigationPath() {
        guard let listID = listNavigationPath.last,
              lists.contains(where: { $0.id == listID })
        else { return }
        
        selectedListID = listID
    }
    
    private func ensureInitialNavigationPath() {
        guard !didSetInitialNavigationPath,
              listNavigationPath.isEmpty,
              let listID = selectedListID ?? lists.first?.id
        else { return }
        
        didSetInitialNavigationPath = true
        listNavigationPath = [listID]
    }
    
    private func keepNavigationPathValid() {
        guard let listID = listNavigationPath.last else { return }
        guard !lists.contains(where: { $0.id == listID }) else { return }
        
        if let fallbackID = selectedListID ?? lists.first?.id {
            listNavigationPath = [fallbackID]
        } else {
            listNavigationPath.removeAll()
            didSetInitialNavigationPath = false
        }
    }
    
    private func normalizeListOrder() {
        let listsInOrder = lists
        
        for (index, list) in listsInOrder.enumerated() where list.sortIndex != index {
            list.sortIndex = index
        }
    }
    
    private func presentListCreator() {
        isCreatingList = true
    }
    
    private func presentListManager() {
        isManagingLists = true
    }
}
