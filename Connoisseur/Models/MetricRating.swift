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
    var id: UUID = UUID()
    var metricID: UUID = UUID()
    var metricTitleSnapshot: String = ""
    var value: Double = 0
    var entry: RankedEntry?

    init(
        id: UUID = UUID(),
        metricID: UUID,
        metricTitleSnapshot: String,
        value: Double,
        entry: RankedEntry? = nil
    ) {
        self.id = id
        self.metricID = metricID
        self.metricTitleSnapshot = metricTitleSnapshot
        self.value = value
        self.entry = entry
    }
}
