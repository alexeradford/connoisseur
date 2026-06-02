//
//  OnboardingFlowView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftData
import SwiftUI

#if canImport(ImagePlayground)
import ImagePlayground
#endif

struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext

    #if canImport(ImagePlayground)
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    #endif

    @State private var step = 0
    @State private var listTitle = ""
    @State private var listPrompt = ""
    @State private var symbolName = "sparkles"
    @State private var tintName = "blue"
    @State private var generatedIconFilename: String?
    @State private var isShowingImagePlaygroundLauncher = false
    @State private var isShowingImagePlayground = false
    @State private var isShowingIconPicker = false
    @State private var iconGenerationError: String?
    @State private var metrics: [MetricDraft] = [
        MetricDraft(title: "Taste", weight: 1.5, polarity: .positive),
        MetricDraft(title: "Vibe", weight: 1, polarity: .positive),
        MetricDraft(title: "Price sting", weight: 0.8, polarity: .negative),
    ]

    private let listStepIndex = 3
    private let metricsStepIndex = 4
    private let finishStepIndex = 5
    private let totalSteps = 6

    var body: some View {
        ZStack {
            ConnoisseurTheme.onboardingBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                if isCreationStep {
                    onboardingHeader
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                currentStep
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isCreationStep ? .top : .center)

                footer
            }
            .padding()
            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: step)
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

    private var onboardingHeader: some View {
        VStack(spacing: 14) {
            RankedListIconView(
                symbolName: symbolName,
                tintName: tintName,
                generatedIconFilename: generatedIconFilename,
                size: 76,
                cornerRadius: 22,
                symbolFont: .system(size: 32, weight: .bold)
            )
            .shadow(color: ConnoisseurTheme.tint(named: tintName).opacity(0.25), radius: 18, y: 10)
            .symbolEffect(.bounce, value: step)

            VStack(spacing: 6) {
                Text(stepTitle)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(stepSubtitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 480)
            }
        }
    }

    @ViewBuilder
    private var currentStep: some View {
        switch step {
        case 0:
            OnboardingIntroPageView(
                title: "Rank anything",
                subtitle: "Movies, martinis, golf courses, albums, beaches, diners. One list can become your little canon.",
                symbolName: "trophy.fill",
                tintName: tintName,
                detailSymbols: ["popcorn.fill", "wineglass.fill", "flag.checkered"],
                animationValue: step
            )
        case 1:
            OnboardingIntroPageView(
                title: "Score what matters",
                subtitle: "Build a scorecard with weighted details. Some things help, some things hurt, and some are just worth remembering.",
                symbolName: "slider.horizontal.3",
                tintName: tintName,
                detailSymbols: ["arrow.up.right.circle.fill", "equal.circle.fill", "arrow.down.right.circle.fill"],
                animationValue: step
            )
        case 2:
            OnboardingIntroPageView(
                title: "Pin the places",
                subtitle: "Tag where each entry happened, then flip to the map when the list becomes a trail.",
                symbolName: "map.fill",
                tintName: tintName,
                detailSymbols: ["mappin.and.ellipse", "camera.fill", "list.number"],
                animationValue: step
            )
        case listStepIndex:
            listStep
        case metricsStepIndex:
            metricsStep
        default:
            finishStep
        }
    }

    private var listStep: some View {
        ScrollView {
            VStack(spacing: 18) {
                TextField("What are you ranking?", text: $listTitle)
                    .textFieldStyle(.plain)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))

                TextField("Tiny note, like 'city martinis' or 'rewatchables'", text: $listPrompt, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))

                iconPicker
                tintPicker
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }

    private var iconPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            #if canImport(ImagePlayground)
            Button {
                openImagePlayground()
            } label: {
                Label("Generate Icon", systemImage: "sparkles")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
            .tint(ConnoisseurTheme.tint(named: tintName))
            .disabled(!supportsImagePlayground)
            #endif

            if generatedIconFilename != nil {
                Button {
                    clearGeneratedIcon()
                } label: {
                    Label("Use Symbol", systemImage: "square.grid.2x2")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var tintPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 28), spacing: 12)], spacing: 12) {
                ForEach(RankedListAppearanceOptions.tints) { option in
                    Button {
                        tintName = option.name
                    } label: {
                        Circle()
                            .fill(ConnoisseurTheme.tint(named: option.name))
                            .frame(width: 28, height: 28)
                            .overlay {
                                if tintName == option.name {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(option.title)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var metricsStep: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach($metrics) { $metric in
                    MetricDraftRow(metric: $metric, tintName: tintName)
                }

                Button {
                    metrics.append(MetricDraft(title: "", weight: 1, polarity: .positive))
                } label: {
                    Label("Metric", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(ConnoisseurTheme.tint(named: tintName))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
        .frame(maxHeight: .infinity)
    }

    private var finishStep: some View {
        VStack(spacing: 18) {
            VStack(spacing: 12) {
                Text(listTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Your first list" : listTitle)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                HStack {
                    ForEach(metrics.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) { metric in
                        Label(metric.title, systemImage: metric.polarity.symbolName)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(.regularMaterial, in: Capsule())
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }

            RankedListIconView(
                symbolName: symbolName,
                tintName: tintName,
                generatedIconFilename: generatedIconFilename,
                size: 88,
                cornerRadius: 24,
                symbolFont: .system(size: 40, weight: .bold)
            )
                .symbolEffect(.bounce, value: step)
        }
    }

    private var footer: some View {
        HStack {
            Button {
                step = max(0, step - 1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.bordered)
            .opacity(step == 0 ? 0 : 1)
            .disabled(step == 0)

            Spacer()

            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Capsule()
                        .fill(index == step ? ConnoisseurTheme.tint(named: tintName) : .secondary.opacity(0.25))
                        .frame(width: index == step ? 24 : 8, height: 8)
                }
            }

            Spacer()

            Button {
                if step == finishStepIndex {
                    createRankedList()
                } else {
                    step += 1
                }
            } label: {
                Image(systemName: step == finishStepIndex ? "checkmark" : "chevron.right")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(ConnoisseurTheme.tint(named: tintName))
            .disabled(!canContinue)
        }
    }

    private var isCreationStep: Bool {
        step >= listStepIndex
    }

    private var stepTitle: String {
        switch step {
        case listStepIndex:
            "Start a list"
        case metricsStepIndex:
            "Pick the scorecard"
        default:
            "Ready"
        }
    }

    private var stepSubtitle: String {
        switch step {
        case listStepIndex:
            "One obsession is plenty. Add more later only if you want."
        case metricsStepIndex:
            "Weight what matters. Mark anything that should help, hurt, or simply describe."
        default:
            "Add your first contender, give it a score, and let the order sort itself."
        }
    }

    private var canContinue: Bool {
        switch step {
        case listStepIndex:
            !listTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case metricsStepIndex:
            metrics.contains { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        default:
            true
        }
    }

    private func createRankedList() {
        let list = RankedList(
            title: listTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            prompt: listPrompt.trimmingCharacters(in: .whitespacesAndNewlines),
            symbolName: symbolName,
            tintName: tintName,
            generatedIconFilename: generatedIconFilename
        )

        for (index, draft) in metrics.enumerated() {
            let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { continue }

            let metric = RankingMetric(
                title: title,
                weight: draft.weight,
                polarity: draft.polarity,
                sortIndex: index,
                list: list
            )
            list.appendMetric(metric)
        }

        modelContext.insert(list)
    }

    private var iconTitle: String {
        RankedListAppearanceOptions.symbols.first { $0.systemName == symbolName }?.title ?? "Custom"
    }

    private var iconGenerationConcept: String {
        let titleText = listTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let promptText = listPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let listDescription = titleText.isEmpty ? "a personal ranking list" : titleText
        let note = promptText.isEmpty ? "" : " inspired by \(promptText)"

        return "A clean icon for \(listDescription)\(note), with \(ConnoisseurTheme.tintTitle(named: tintName).lowercased()) color accents, no words or letters"
    }

    private func handleGeneratedIcon(_ sourceURL: URL) {
        isShowingImagePlaygroundLauncher = false

        do {
            let filename = try RankedListIconStorage.storeGeneratedIcon(from: sourceURL, replacing: generatedIconFilename)
            generatedIconFilename = filename
        } catch {
            iconGenerationError = error.localizedDescription
        }
    }

    private func clearGeneratedIcon() {
        RankedListIconStorage.deleteIcon(named: generatedIconFilename)
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
}
