//
//  RankedEntryEditorView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import PhotosUI
import SwiftData
import SwiftUI

#if os(iOS)
import UIKit
#endif

struct RankedEntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let list: RankedList
    let entry: RankedEntry?
    let initialDraft: RankedEntryDraft

    @State private var draft: RankedEntryDraft
    @State private var currentStep: RankedEntryEditorStep = .identity
    @State private var transitionDirection = 1
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isShowingPlacePicker = false
    @State private var isShowingCamera = false

    init(list: RankedList, entry: RankedEntry?) {
        self.list = list
        self.entry = entry
        let initialDraft = RankedEntryDraft(list: list, entry: entry)
        self.initialDraft = initialDraft
        _draft = State(initialValue: initialDraft)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ConnoisseurTheme.listBackground(tintName: list.tintName)
                    .ignoresSafeArea()

                stepContent
                    .id(currentStep.id)
                    .transition(stepTransition)
            }
            .safeAreaInset(edge: .bottom) {
                RankedEntryFlowPrimaryButton(
                    title: primaryButtonTitle,
                    tint: tint,
                    isDisabled: !canContinue,
                    action: goForward
                )
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: toolbarLeadingAction) {
                        Image(systemName: currentStepIndex > 0 ? "chevron.left" : "xmark")
                    }
                    .accessibilityLabel(currentStepIndex > 0 ? "Back" : "Cancel")
                }

                ToolbarItem(placement: .principal) {
                    Text(toolbarTitle)
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                ToolbarItem(placement: .primaryAction) {
                    Text(progressText)
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
        }
        .interactiveDismissDisabled(shouldDisableGestureDismiss)
        .animation(.spring(response: 0.46, dampingFraction: 0.88), value: currentStep)
        .onChange(of: selectedPhotoItems) {
            loadSelectedPhotos()
        }
        .sheet(isPresented: $isShowingPlacePicker) {
            PlacePickerSheetView(
                initialLocation: draft.selectedRankedLocation,
                tintName: list.tintName,
                applyLocation: applyLocation
            )
        }
#if os(iOS)
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker { data in
                draft.pendingPhotoData.append(data)
            }
            .ignoresSafeArea()
        }
#endif
    }

    private var tint: Color {
        ConnoisseurTheme.tint(named: list.tintName)
    }

    private var metrics: [RankingMetric] {
        list.sortedMetrics
    }

    private var steps: [RankedEntryEditorStep] {
        [.identity, .timePlace] + metrics.map { .rating($0.id) } + [.notes, .summary]
    }

    private var currentStepIndex: Int {
        steps.firstIndex(of: currentStep) ?? 0
    }

    private var progressText: String {
        "\(currentStepIndex + 1) of \(steps.count)"
    }

    private var toolbarTitle: String {
        "\(entry == nil ? "Add" : "Edit") \(list.title)"
    }

    private var primaryButtonTitle: String {
        switch currentStep {
        case .identity, .timePlace:
            "Continue"
        case .rating:
            "Continue"
        case .notes:
            "Preview"
        case .summary:
            entry == nil ? "Add Item" : "Save Changes"
        }
    }

    private var canContinue: Bool {
        !draft.trimmedTitle.isEmpty
    }

    private var shouldDisableGestureDismiss: Bool {
        currentStepIndex > 0 || draft != initialDraft
    }

    private var nextStep: RankedEntryEditorStep? {
        let nextIndex = currentStepIndex + 1
        guard steps.indices.contains(nextIndex) else { return nil }
        return steps[nextIndex]
    }

    private var previousStep: RankedEntryEditorStep? {
        let previousIndex = currentStepIndex - 1
        guard steps.indices.contains(previousIndex) else { return nil }
        return steps[previousIndex]
    }

    private var stepTransition: AnyTransition {
        let insertion: Edge = transitionDirection >= 0 ? .trailing : .leading
        let removal: Edge = transitionDirection >= 0 ? .leading : .trailing

        return .asymmetric(
            insertion: .move(edge: insertion).combined(with: .opacity),
            removal: .move(edge: removal).combined(with: .opacity)
        )
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .identity:
            RankedEntryIdentityStepView(
                list: list,
                draft: $draft,
                selectedPhotoItems: $selectedPhotoItems,
                showCameraButton: isCameraAvailable,
                onCamera: showCamera
            )

        case .timePlace:
            RankedEntryTimePlaceStepView(
                list: list,
                draft: $draft,
                onPickPlace: showPlacePicker,
                onClearPlace: { draft.applyLocation(nil) }
            )

        case .rating(let metricID):
            if let metric = metrics.first(where: { $0.id == metricID }) {
                RankedEntryRatingStepView(
                    metric: metric,
                    tint: tint,
                    value: ratingBinding(for: metric)
                )
            }

        case .notes:
            RankedEntryNotesStepView(notes: $draft.notes, tint: tint)

        case .summary:
            RankedEntrySummaryStepView(
                list: list,
                draft: draft,
                metrics: metrics,
                score: draft.projectedScore(using: metrics)
            )
        }
    }

    private var isCameraAvailable: Bool {
#if os(iOS)
        UIImagePickerController.isSourceTypeAvailable(.camera)
#else
        false
#endif
    }

    private func ratingBinding(for metric: RankingMetric) -> Binding<Double> {
        Binding(
            get: { draft.ratings[metric.id] ?? RankedEntryDraft.defaultRating(for: metric) },
            set: { draft.ratings[metric.id] = $0 }
        )
    }

    private func goForward() {
        dismissKeyboard()
        guard canContinue else { return }

        if currentStep == .summary {
            save()
            return
        }

        guard let nextStep else { return }
        setStep(nextStep, direction: 1)
    }

    private func goBack() {
        dismissKeyboard()
        guard let previousStep else {
            dismiss()
            return
        }

        setStep(previousStep, direction: -1)
    }

    private func toolbarLeadingAction() {
        if currentStepIndex > 0 {
            goBack()
        } else {
            dismissKeyboard()
            dismiss()
        }
    }

    private func setStep(_ step: RankedEntryEditorStep, direction: Int) {
        transitionDirection = direction
        withAnimation(.spring(response: 0.46, dampingFraction: 0.88)) {
            currentStep = step
        }
    }

    private func showPlacePicker() {
        dismissKeyboard()
        isShowingPlacePicker = true
    }

    private func showCamera() {
        dismissKeyboard()
        isShowingCamera = true
    }

    private func loadSelectedPhotos() {
        Task {
            var imageData: [Data] = []

            for item in selectedPhotoItems {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    imageData.append(data)
                }
            }

            draft.pendingPhotoData = imageData
        }
    }

    private func applyLocation(_ location: RankedLocation?) {
        draft.applyLocation(location)
    }

    private func dismissKeyboard() {
#if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }

    private func save() {
        let savedEntry: RankedEntry
        if let entry {
            savedEntry = entry
        } else {
            savedEntry = RankedEntry(title: draft.trimmedTitle, list: list)
            modelContext.insert(savedEntry)
            list.appendEntry(savedEntry)
        }

        savedEntry.title = draft.trimmedTitle
        savedEntry.notes = draft.trimmedNotes
        savedEntry.locationName = draft.trimmedLocationName
        savedEntry.locationAddress = draft.trimmedLocationAddress
        savedEntry.latitude = draft.latitude
        savedEntry.longitude = draft.longitude
        savedEntry.rankedAt = draft.rankedAt
        savedEntry.updatedAt = .now

        for metric in metrics {
            let value = draft.ratings[metric.id] ?? RankedEntryDraft.defaultRating(for: metric)

            if let existingRating = savedEntry.rating(for: metric) {
                existingRating.value = value
                existingRating.metricTitleSnapshot = metric.title
            } else {
                let rating = MetricRating(metricID: metric.id, metricTitleSnapshot: metric.title, value: value, entry: savedEntry)
                modelContext.insert(rating)
                savedEntry.appendRating(rating)
            }
        }

        for data in draft.pendingPhotoData {
            let photo = RankedPhoto(data: data, entry: savedEntry)
            modelContext.insert(photo)
            savedEntry.appendPhoto(photo)
        }

        list.updatedAt = .now
        dismiss()
    }
}
