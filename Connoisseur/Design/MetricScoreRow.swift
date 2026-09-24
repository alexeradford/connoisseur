//
//  MetricScoreRow.swift
//  Connoisseur
//
//  Created by Codex on 2026-06-22.
//

import SwiftUI

struct MetricScoreRow: View {
    let metric: RankingMetric
    let value: Double
    let tint: Color
    var animatesMeter = true

    @State private var displayedProgress = 0.0

    private var targetProgress: Double {
        metric.normalizedValue(for: value)
    }

    private var fillTint: Color {
        metric.polarity == .negative ? .red : tint
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Label(metric.title, systemImage: metric.polarity.symbolName)
                    .font(.body.weight(.semibold))
                    .lineLimit(2)

                Spacer(minLength: 8)

                Text(value.scoreString)
                    .font(.body.monospacedDigit().weight(.bold))
            }

            MetricScoreMeter(progress: displayedProgress, tint: fillTint)
                .accessibilityLabel(metric.title)
                .accessibilityValue(value.scoreString)
        }
        .onAppear {
            revealMeter(reset: displayedProgress == 0)
        }
        .onChange(of: targetProgress) {
            revealMeter(reset: false)
        }
    }

    private func revealMeter(reset: Bool) {
        let targetProgress = targetProgress

        guard animatesMeter else {
            displayedProgress = targetProgress
            return
        }

        if reset {
            displayedProgress = 0
        }

        withAnimation(.snappy(duration: 0.68, extraBounce: 0.18)) {
            displayedProgress = targetProgress
        }
    }
}

private struct MetricScoreMeter: View {
    let progress: Double
    let tint: Color

    private static let height: CGFloat = 14

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            let fillWidth = proxy.size.width * clampedProgress

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.secondary.opacity(0.15))

                if clampedProgress > 0 {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    tint.opacity(0.72),
                                    tint,
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(Self.height, fillWidth))
                        .overlay(alignment: .trailing) {
                            Circle()
                                .fill(.white.opacity(0.56))
                                .frame(width: 5, height: 5)
                                .padding(.trailing, 4)
                        }
                }
            }
        }
        .frame(height: Self.height)
        .accessibilityElement(children: .ignore)
    }
}
