//
//  MetricDraftRow.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct MetricDraftRow: View {
    @Binding var metric: MetricDraft
    let tintName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Metric", text: $metric.title)
                .font(.headline)
                .textFieldStyle(.plain)

            HStack {
                Image(systemName: "scalemass.fill")
                    .foregroundStyle(.secondary)

                Slider(value: $metric.weight, in: 0...3, step: 0.1)
                    .tint(ConnoisseurTheme.tint(named: tintName))

                Text(metric.weight.compactWeightString)
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .frame(width: 32, alignment: .trailing)
            }

            Picker("Effect", selection: $metric.polarity) {
                ForEach(MetricPolarity.allCases) { polarity in
                    Label(polarity.title, systemImage: polarity.symbolName)
                        .tag(polarity)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
