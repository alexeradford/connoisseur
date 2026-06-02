//
//  RankedListDetailView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct RankedListDetailView: View {
    private let horizontalPadding: CGFloat = 22
    private let topPadding: CGFloat = 22
    private let bottomPadding: CGFloat = 120

    let list: RankedList
    let entries: [RankedEntry]
    let addEntry: () -> Void

    init(
        list: RankedList,
        entries: [RankedEntry],
        addEntry: @escaping () -> Void
    ) {
        self.list = list
        self.entries = entries
        self.addEntry = addEntry
    }

    var body: some View {
        ScrollView {
            RankedListContainer(tintName: list.tintName) {
                RankedListHeaderView(list: list, style: .full)
            } content: {
                listContent
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
        }
        .background(RankedListBackground(list: list))
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var listContent: some View {
        if entries.isEmpty {
            EmptyRankedListView(list: list, addEntry: addEntry)
        } else {
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                VStack(spacing: 0) {
                    NavigationLink {
                        RankedEntryDetailView(list: list, entry: entry)
                    } label: {
                        RankedEntryCard(list: list, entry: entry, rank: index + 1)
                    }
                    .buttonStyle(.plain)

                    if index < entries.count - 1 {
                        Divider()
                            .overlay(ConnoisseurTheme.tint(named: list.tintName).opacity(0.14))
                    }
                }
            }
        }
    }
}
