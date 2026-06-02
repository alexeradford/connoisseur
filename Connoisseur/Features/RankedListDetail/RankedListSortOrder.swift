//
//  RankedListSortOrder.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation

enum RankedListSortOrder: String, CaseIterable, Identifiable {
    case scoreDescending
    case scoreAscending
    case titleAscending
    case newest
    case oldest

    var id: Self { self }

    var title: String {
        switch self {
        case .scoreDescending:
            "Highest score"
        case .scoreAscending:
            "Lowest score"
        case .titleAscending:
            "Name"
        case .newest:
            "Newest"
        case .oldest:
            "Oldest"
        }
    }

    var symbolName: String {
        switch self {
        case .scoreDescending:
            "arrow.down.circle"
        case .scoreAscending:
            "arrow.up.circle"
        case .titleAscending:
            "textformat"
        case .newest:
            "calendar.badge.clock"
        case .oldest:
            "calendar"
        }
    }

    func sort(_ entries: [RankedEntry], in list: RankedList) -> [RankedEntry] {
        entries.sorted { left, right in
            compare(
                left: left,
                right: right,
                leftScore: left.score(using: list.sortedMetrics),
                rightScore: right.score(using: list.sortedMetrics)
            )
        }
    }

    private func compare(
        left: RankedEntry,
        right: RankedEntry,
        leftScore: Double,
        rightScore: Double,
        leftListTitle: String? = nil,
        rightListTitle: String? = nil
    ) -> Bool {
        switch self {
        case .scoreDescending:
            if leftScore != rightScore {
                return leftScore > rightScore
            }

            return newestFirst(left, right)
        case .scoreAscending:
            if leftScore != rightScore {
                return leftScore < rightScore
            }

            return newestFirst(left, right)
        case .titleAscending:
            let titleComparison = left.title.localizedStandardCompare(right.title)
            if titleComparison != .orderedSame {
                return titleComparison == .orderedAscending
            }

            if let leftListTitle, let rightListTitle {
                let listComparison = leftListTitle.localizedStandardCompare(rightListTitle)
                if listComparison != .orderedSame {
                    return listComparison == .orderedAscending
                }
            }

            return newestFirst(left, right)
        case .newest:
            return newestFirst(left, right)
        case .oldest:
            if left.displayDate != right.displayDate {
                return left.displayDate < right.displayDate
            }

            return left.createdAt < right.createdAt
        }
    }

    private func newestFirst(_ left: RankedEntry, _ right: RankedEntry) -> Bool {
        if left.displayDate != right.displayDate {
            return left.displayDate > right.displayDate
        }

        return left.updatedAt > right.updatedAt
    }
}
