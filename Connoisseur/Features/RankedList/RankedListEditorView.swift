//
//  RankedListEditorView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftData
import SwiftUI

#if canImport(ImagePlayground)
import ImagePlayground
#endif

struct RankedListEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    #if canImport(ImagePlayground)
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    #endif

    let list: RankedList?
    let sortIndex: Int?
    let onSave: ((RankedList) -> Void)?
    private let originalGeneratedIconFilename: String?

    @State private var title: String
    @State private var prompt: String
    @State private var symbolName: String
    @State private var tintName: String
    @State private var generatedIconFilename: String?
    @State private var isShowingImagePlaygroundLauncher = false
    @State private var isShowingImagePlayground = false
    @State private var isShowingIconPicker = false
    @State private var iconGenerationError: String?
    @State private var metrics: [MetricDraft]

    init(list: RankedList?, sortIndex: Int? = nil, onSave: ((RankedList) -> Void)? = nil) {
        self.list = list
        self.sortIndex = sortIndex
        self.onSave = onSave
        self.originalGeneratedIconFilename = list?.generatedIconFilename
        _title = State(initialValue: list?.title ?? "")
        _prompt = State(initialValue: list?.prompt ?? "")
        _symbolName = State(initialValue: list?.symbolName ?? "sparkles")
        _tintName = State(initialValue: list?.tintName ?? "mint")
        _generatedIconFilename = State(initialValue: list?.generatedIconFilename)
        _metrics = State(initialValue: list?.sortedMetrics.map {
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
            .navigationTitle(list == nil ? "List" : "Edit")
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
            .sheet(isPresented: $isShowingIconPicker) {
                RankedListIconPickerSheet(
                    symbolName: $symbolName,
                    tintName: tintName,
                    onSelect: { _ in clearGeneratedIcon() }
                )
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
                Text("Icon")
                    .font(.headline)

                Button {
                    isShowingIconPicker = true
                } label: {
                    HStack(spacing: 14) {
                        RankedListIconView(
                            symbolName: symbolName,
                            tintName: tintName,
                            generatedIconFilename: generatedIconFilename,
                            size: 48
                        )

                        Text(generatedIconFilename == nil ? iconTitle : "Generated icon")
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

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
                    ForEach(RankedListAppearanceOptions.tints) { option in
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

    private var iconTitle: String {
        RankedListAppearanceOptions.symbols.first { $0.systemName == symbolName }?.title ?? "Custom"
    }

    private func save() {
        let savedList: RankedList
        if let list {
            savedList = list
        } else {
            savedList = RankedList(title: "", sortIndex: sortIndex ?? 0)
            modelContext.insert(savedList)
        }

        savedList.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        savedList.prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        savedList.symbolName = symbolName
        savedList.tintName = tintName
        savedList.generatedIconFilename = generatedIconFilename
        savedList.updatedAt = .now

        if originalGeneratedIconFilename != generatedIconFilename {
            RankedListIconStorage.deleteIcon(named: originalGeneratedIconFilename)
        }

        let existingMetricsByID = Dictionary(uniqueKeysWithValues: savedList.availableMetrics.map { ($0.id, $0) })
        let keptMetricIDs = Set(metrics.map(\.id))

        for oldMetric in savedList.availableMetrics where !keptMetricIDs.contains(oldMetric.id) {
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
                    list: savedList
                )
                modelContext.insert(metric)
                savedList.appendMetric(metric)
            }
        }

        onSave?(savedList)
        dismiss()
    }

    private func cancel() {
        if originalGeneratedIconFilename != generatedIconFilename {
            RankedListIconStorage.deleteIcon(named: generatedIconFilename)
        }

        dismiss()
    }

    private func clearGeneratedIcon() {
        if originalGeneratedIconFilename != generatedIconFilename {
            RankedListIconStorage.deleteIcon(named: generatedIconFilename)
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
        let listDescription = titleText.isEmpty ? "a personal ranking list" : titleText
        let note = promptText.isEmpty ? "" : " inspired by \(promptText)"

        return "A clean icon for \(listDescription)\(note), with \(ConnoisseurTheme.tintTitle(named: tintName).lowercased()) color accents, no words or letters"
    }

    private func handleGeneratedIcon(_ sourceURL: URL) {
        isShowingImagePlaygroundLauncher = false

        do {
            let previousGeneratedIconFilename = generatedIconFilename == originalGeneratedIconFilename ? nil : generatedIconFilename
            let filename = try RankedListIconStorage.storeGeneratedIcon(from: sourceURL, replacing: previousGeneratedIconFilename)
            generatedIconFilename = filename
        } catch {
            iconGenerationError = error.localizedDescription
        }
    }
}
