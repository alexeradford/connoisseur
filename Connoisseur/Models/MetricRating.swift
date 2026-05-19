//
//  MetricRating.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation
import SwiftData

@Model
final class MetricRating {
    var id: UUID
    var metricID: UUID
    var metricTitleSnapshot: String
    var value: Double
    var item: RankedItem?

    init(
        id: UUID = UUID(),
        metricID: UUID,
        metricTitleSnapshot: String,
        value: Double,
        item: RankedItem? = nil
    ) {
        self.id = id
        self.metricID = metricID
        self.metricTitleSnapshot = metricTitleSnapshot
        self.value = value
        self.item = item
    }
}
