//
//  CategoryEditorView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftData
import SwiftUI

struct CategoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let category: RankingCategory?
    let sortIndex: Int?
    let onSave: ((RankingCategory) -> Void)?

    @State private var title: String
    @State private var prompt: String
    @State private var symbolName: String
    @State private var tintName: String
    @State private var metrics: [MetricDraft]

    init(category: RankingCategory?, sortIndex: Int? = nil, onSave: ((RankingCategory) -> Void)? = nil) {
        self.category = category
        self.sortIndex = sortIndex
        self.onSave = onSave
        _title = State(initialValue: category?.title ?? "")
        _prompt = State(initialValue: category?.prompt ?? "")
        _symbolName = State(initialValue: category?.symbolName ?? "sparkles")
        _tintName = State(initialValue: category?.tintName ?? "mint")
        _metrics = State(initialValue: category?.sortedMetrics.map {
            MetricDraft(id: $0.id, title: $0.title, weight: $0.weight, polarity: $0.polarity)
        } ?? [
            MetricDraft(title: "Quality", weight: 1, polarity: .positive),
            MetricDraft(title: "Charm", weight: 1, polarity: .positive),
        ])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Note", text: $prompt)
                }

                Section {
                    Picker("Icon", selection: $symbolName) {
                        ForEach(["sparkles", "popcorn.fill", "wineglass.fill", "flag.checkered", "fork.knife", "music.note"], id: \.self) { icon in
                            Label(icon, systemImage: icon).tag(icon)
                        }
                    }

                    Picker("Color", selection: $tintName) {
                        ForEach(ConnoisseurTheme.tintNames, id: \.self) { name in
                            Text(name.capitalized).tag(name)
                        }
                    }
                }

                Section("Metrics") {
                    ForEach($metrics) { $metric in
                        MetricDraftRow(metric: $metric, tintName: tintName)
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    }
                    .onDelete { offsets in
                        metrics.remove(atOffsets: offsets)
                    }

                    Button {
                        metrics.append(MetricDraft(title: "", weight: 1, polarity: .positive))
                    } label: {
                        Label("Metric", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle(category == nil ? "Category" : "Edit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let savedCategory: RankingCategory
        if let category {
            savedCategory = category
        } else {
            savedCategory = RankingCategory(title: "", sortIndex: sortIndex ?? 0)
            modelContext.insert(savedCategory)
        }

        savedCategory.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        savedCategory.prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        savedCategory.symbolName = symbolName
        savedCategory.tintName = tintName
        savedCategory.updatedAt = .now

        let existingMetricsByID = Dictionary(uniqueKeysWithValues: savedCategory.metrics.map { ($0.id, $0) })
        let keptMetricIDs = Set(metrics.map(\.id))

        for oldMetric in savedCategory.metrics where !keptMetricIDs.contains(oldMetric.id) {
            modelContext.delete(oldMetric)
        }

        for (index, draft) in metrics.enumerated() {
            let metricTitle = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !metricTitle.isEmpty else { continue }

            if let existingMetric = existingMetricsByID[draft.id] {
                existingMetric.title = metricTitle
                existingMetric.weight = draft.weight
                existingMetric.polarity = draft.polarity
                existingMetric.sortIndex = index
            } else {
                let metric = RankingMetric(
                    id: draft.id,
                    title: metricTitle,
                    weight: draft.weight,
                    polarity: draft.polarity,
                    sortIndex: index,
                    category: savedCategory
                )
                modelContext.insert(metric)
                savedCategory.metrics.append(metric)
            }
        }

        onSave?(savedCategory)
        dismiss()
    }
}
