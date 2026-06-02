//
//  RankedListViewMode.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

enum RankedListViewMode: String {
    case list
    case map

    var toggleSymbolName: String {
        switch self {
        case .list:
            "map.fill"
        case .map:
            "list.number"
        }
    }

    var toggleAccessibilityLabel: String {
        switch self {
        case .list:
            "Show map"
        case .map:
            "Show list"
        }
    }
}
