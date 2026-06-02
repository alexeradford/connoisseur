//
//  ConnoisseurTabView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-26.
//

import SwiftUI

struct ConnoisseurTabView: View {
    @State private var selectedTab: ConnoisseurTab = .lists

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(ConnoisseurTab.lists.title, systemImage: ConnoisseurTab.lists.symbolName, value: .lists) {
                RankedListView()
            }

            Tab(ConnoisseurTab.map.title, systemImage: ConnoisseurTab.map.symbolName, value: .map) {
                MapView()
            }

            Tab(ConnoisseurTab.search.title, systemImage: ConnoisseurTab.search.symbolName, value: .search) {
                RankedListsSearchView()
            }
        }
    }
}

private enum ConnoisseurTab: Hashable {
    case lists
    case map
    case search

    var title: String {
        switch self {
        case .lists:
            "Lists"
        case .map:
            "Map"
        case .search:
            "Search"
        }
    }

    var symbolName: String {
        switch self {
        case .lists:
            "list.bullet.rectangle"
        case .map:
            "map"
        case .search:
            "magnifyingglass"
        }
    }
}
