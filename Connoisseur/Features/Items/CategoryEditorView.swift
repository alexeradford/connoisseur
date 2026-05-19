//
//  CategoryEditorView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftData
import SwiftUI

#if canImport(ImagePlayground)
import ImagePlayground
#endif

struct CategoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    #if canImport(ImagePlayground)
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    #endif

    let category: RankingCategory?
    let sortIndex: Int?
    let onSave: ((RankingCategory) -> Void)?
    private let originalGeneratedIconFilename: String?

    @State private var title: String
    @State private var prompt: String
    @State private var symbolName: String
    @State private var tintName: String
    @State private var generatedIconFilename: String?
    @State private var isShowingImagePlaygroundLauncher = false
    @State private var isShowingImagePlayground = false
    @State private var iconGenerationError: String?
    @State private var metrics: [MetricDraft]

    init(category: RankingCategory?, sortIndex: Int? = nil, onSave: ((RankingCategory) -> Void)? = nil) {
        self.category = category
        self.sortIndex = sortIndex
        self.onSave = onSave
        self.originalGeneratedIconFilename = category?.generatedIconFilename
        _title = State(initialValue: category?.title ?? "")
        _prompt = State(initialValue: category?.prompt ?? "")
        _symbolName = State(initialValue: category?.symbolName ?? "sparkles")
        _tintName = State(initialValue: category?.tintName ?? "mint")
        _generatedIconFilename = State(initialValue: category?.generatedIconFilename)
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

                appearanceSection

                Section("Metrics") {
                    ForEach($metrics) { $metric in
                        MetricDraftRow(metric: $metric, tintName: tintName, showsBackground: false)
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
                        cancel()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Icon Not Saved", isPresented: Binding(
                get: { iconGenerationError != nil },
                set: { if !$0 { iconGenerationError = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(iconGenerationError ?? "")
            }
            #if canImport(ImagePlayground)
            .overlay {
                if isShowingImagePlaygroundLauncher {
                    ImagePlaygroundLauncherOverlay {
                        cancelImagePlaygroundLaunch()
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: isShowingImagePlaygroundLauncher)
            .imagePlaygroundSheet(
                isPresented: $isShowingImagePlayground,
                concept: iconGenerationConcept,
                sourceImage: nil,
                onCompletion: handleGeneratedIcon,
                onCancellation: {
                    isShowingImagePlaygroundLauncher = false
                }
            )
            #endif
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            VStack(alignment: .leading, spacing: 14) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 10)], spacing: 10) {
                    ForEach(CategoryAppearanceOptions.symbols) { option in
                        Button {
                            symbolName = option.systemName
                            clearGeneratedIcon()
                        } label: {
                            Image(systemName: option.systemName)
                                .font(.headline.weight(.semibold))
                                .frame(width: 42, height: 42)
                                .foregroundStyle(generatedIconFilename == nil && symbolName == option.systemName ? .white : ConnoisseurTheme.tint(named: tintName))
                                .background(
                                    generatedIconFilename == nil && symbolName == option.systemName
                                    ? ConnoisseurTheme.tint(named: tintName)
                                    : Color.secondary.opacity(0.12),
                                    in: RoundedRectangle(cornerRadius: 8)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(option.title)
                    }
                }

                #if canImport(ImagePlayground)
                Button {
                    openImagePlayground()
                } label: {
                    Label("Generate Icon", systemImage: "sparkles")
                }
                .disabled(!supportsImagePlayground)

                if !supportsImagePlayground {
                    Text("Image Playground is not available on this device.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                #endif

                if generatedIconFilename != nil {
                    Button("Use SF Symbol Instead", role: .destructive) {
                        clearGeneratedIcon()
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Color")
                    .font(.headline)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 46), spacing: 12)], spacing: 12) {
                    ForEach(CategoryAppearanceOptions.tints) { option in
                        Button {
                            tintName = option.name
                        } label: {
                            Circle()
                                .fill(ConnoisseurTheme.tint(named: option.name))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    if tintName == option.name {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                                .overlay {
                                    Circle()
                                        .stroke(.primary.opacity(tintName == option.name ? 0.22 : 0), lineWidth: 3)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(option.title)
                    }
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
        savedCategory.generatedIconFilename = generatedIconFilename
        savedCategory.updatedAt = .now

        if originalGeneratedIconFilename != generatedIconFilename {
            CategoryIconStorage.deleteIcon(named: originalGeneratedIconFilename)
        }

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

    private func cancel() {
        if originalGeneratedIconFilename != generatedIconFilename {
            CategoryIconStorage.deleteIcon(named: generatedIconFilename)
        }

        dismiss()
    }

    private func clearGeneratedIcon() {
        if originalGeneratedIconFilename != generatedIconFilename {
            CategoryIconStorage.deleteIcon(named: generatedIconFilename)
        }

        generatedIconFilename = nil
    }

    #if canImport(ImagePlayground)
    private func openImagePlayground() {
        isShowingImagePlaygroundLauncher = true
        isShowingImagePlayground = true
    }

    private func cancelImagePlaygroundLaunch() {
        isShowingImagePlayground = false
        isShowingImagePlaygroundLauncher = false
    }
    #endif

    private var iconGenerationConcept: String {
        let titleText = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let promptText = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let categoryDescription = titleText.isEmpty ? "a personal ranking category" : titleText
        let note = promptText.isEmpty ? "" : " inspired by \(promptText)"

        return "A clean icon for \(categoryDescription)\(note), with \(ConnoisseurTheme.tintTitle(named: tintName).lowercased()) color accents, no words or letters"
    }

    private func handleGeneratedIcon(_ sourceURL: URL) {
        isShowingImagePlaygroundLauncher = false

        do {
            let previousGeneratedIconFilename = generatedIconFilename == originalGeneratedIconFilename ? nil : generatedIconFilename
            let filename = try CategoryIconStorage.storeGeneratedIcon(from: sourceURL, replacing: previousGeneratedIconFilename)
            generatedIconFilename = filename
        } catch {
            iconGenerationError = error.localizedDescription
        }
    }
}
