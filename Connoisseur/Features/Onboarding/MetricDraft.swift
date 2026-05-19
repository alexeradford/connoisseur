//
//  MetricDraft.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation

struct MetricDraft: Identifiable, Hashable {
    let id: UUID
    var title: String
    var weight: Double
    var polarity: MetricPolarity

    init(id: UUID = UUID(), title: String, weight: Double, polarity: MetricPolarity) {
        self.id = id
        self.title = title
        self.weight = weight
        self.polarity = polarity
    }
}
