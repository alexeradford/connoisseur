//
//  MetricSparklineView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct MetricSparklineView: View {
    let category: RankingCategory
    let item: RankedItem

    var body: some View {
        HStack(spacing: 5) {
            ForEach(category.sortedMetrics) { metric in
                let rawValue = item.rating(for: metric)?.value ?? metric.minimumValue
                let normalizedValue = metric.normalizedValue(for: rawValue)

                Capsule()
                    .fill(fill(for: metric))
                    .frame(width: 18, height: 6 + normalizedValue * 16)
                    .frame(height: 24, alignment: .bottom)
                    .accessibilityLabel(metric.title)
                    .accessibilityValue(rawValue.scoreString)
            }
        }
    }

    private func fill(for metric: RankingMetric) -> Color {
        switch metric.polarity {
        case .positive:
            ConnoisseurTheme.tint(named: category.tintName)
        case .neutral:
            .secondary
        case .negative:
            .red
        }
    }
}
