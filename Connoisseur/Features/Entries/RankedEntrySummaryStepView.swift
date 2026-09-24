//
//  RankedEntrySummaryStepView.swift
//  Connoisseur
//
//  Created by Codex on 2026-06-22.
//

import SwiftUI

struct RankedEntrySummaryStepView: View {
    let list: RankedList
    let draft: RankedEntryDraft
    let metrics: [RankingMetric]
    let score: Double

    @State private var displayedScore = 0.0

    private var tint: Color {
        ConnoisseurTheme.tint(named: list.tintName)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                identityPreview
                scoreReveal
                ratingsPreview

                if !draft.trimmedNotes.isEmpty {
                    Text(draft.trimmedNotes)
                        .font(.body)
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .connoisseurField(cornerRadius: 22)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 122)
        }
        .scrollIndicators(.hidden)
        .task {
            revealScore()
        }
        .onChange(of: score) {
            revealScore()
        }
    }

    private var scoreReveal: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Overall")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(displayedScore.scoreString)
                    .font(.system(size: 104, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: displayedScore))

                Text("/10")
                    .font(.title2.weight(.black))
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(tint)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(26)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(tint.opacity(0.3), lineWidth: 1)
        }
    }

    private var identityPreview: some View {
        HStack(spacing: 14) {
            ZStack {
                if let data = draft.displayPhotoData {
                    PhotoThumbnail(data: data)
                } else {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(tint.opacity(0.16))
                        .overlay {
                            Image(systemName: "photo")
                                .font(.title.weight(.bold))
                                .foregroundStyle(tint)
                        }
                }
            }
            .frame(width: 92, height: 92)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(draft.trimmedTitle)
                    .font(.title2.bold())
                    .lineLimit(2)

                if !draft.trimmedLocationName.isEmpty {
                    Label(draft.trimmedLocationName, systemImage: "mappin.and.ellipse")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Label(draft.rankedAt.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .connoisseurField(cornerRadius: 24)
    }

    private var ratingsPreview: some View {
        VStack(spacing: 12) {
            ForEach(metrics) { metric in
                let value = draft.ratings[metric.id] ?? RankedEntryDraft.defaultRating(for: metric)

                MetricScoreRow(metric: metric, value: value, tint: tint)
            }
        }
        .padding(18)
        .connoisseurField(cornerRadius: 24)
    }

    private func revealScore() {
        displayedScore = 0

        withAnimation(.easeOut(duration: 1.45)) {
            displayedScore = score
        }
    }
}
