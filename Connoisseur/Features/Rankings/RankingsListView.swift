//
//  RankingsListView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct RankingsListView: View {
    let category: RankingCategory
    let addItem: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if category.items.isEmpty {
                EmptyRankingsView(category: category, addItem: addItem)
            } else {
                ForEach(Array(category.rankedItems.enumerated()), id: \.element.id) { index, item in
                    NavigationLink {
                        RankedItemDetailView(category: category, item: item)
                    } label: {
                        RankedItemCard(category: category, item: item, rank: index + 1)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
