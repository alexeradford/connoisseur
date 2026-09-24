//
//  RankedEntryRatingStepView.swift
//  Connoisseur
//
//  Created by Codex on 2026-06-22.
//

import SwiftUI

struct RankedEntryRatingStepView: View {
    let metric: RankingMetric
    let tint: Color
    @Binding var value: Double

    @State private var hapticTick = 0

    private var metricTint: Color {
        switch metric.polarity {
        case .positive:
            .green
        case .negative:
            .red
        case .neutral:
            .gray
        }
    }

    private var polarityIconName: String {
        switch metric.polarity {
        case .positive:
            "arrow.up.right.circle.fill"
        case .negative:
            "arrow.down.right.circle.fill"
        case .neutral:
            "equal.circle.fill"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 28)

            ratingBadge

            Spacer(minLength: 28)

            sliderPanel
                .padding(.horizontal, 24)
                .padding(.bottom, 122)
        }
#if os(iOS)
        .sensoryFeedback(.selection, trigger: hapticTick)
#endif
    }

    private var ratingBadge: some View {
        VStack(spacing: 16) {
            Text(metric.title)
                .font(.system(.title, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(value.scoreString)
                .font(.system(size: 118, weight: .black, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(value: value))
                .animation(.spring(response: 0.22, dampingFraction: 0.82), value: value)

            Label(metric.polarity.title, systemImage: polarityIconName)
                .font(.title3.weight(.bold))
                .foregroundStyle(metricTint)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }

    private var sliderPanel: some View {
        VStack(spacing: 14) {
            Slider(
                value: Binding(
                    get: { value },
                    set: updateRating
                ),
                in: metric.minimumValue...metric.maximumValue,
                step: 0.1
            )
            .tint(metricTint)

            HStack {
                Text(metric.minimumValue.scoreString)
                Spacer()
                Text(metric.maximumValue.scoreString)
            }
            .font(.caption.monospacedDigit().weight(.bold))
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .connoisseurField(cornerRadius: 24)
    }

    private func updateRating(_ newValue: Double) {
        value = newValue

        let tick = Int((newValue * 10).rounded())
        if tick != hapticTick {
            hapticTick = tick
        }
    }
}
