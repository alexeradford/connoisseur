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

    @State private var title: String
    @State private var notes: String
    @State private var ratings: [UUID: Double]
    @State private var locationName: String
    @State private var locationAddress: String
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var rankedAt: Date
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var pendingPhotoData: [Data] = []
    @State private var isShowingPlacePicker = false
    @State private var isShowingCamera = false

    init(list: RankedList, entry: RankedEntry?) {
        self.list = list
        self.entry = entry
        _title = State(initialValue: entry?.title ?? "")
        _notes = State(initialValue: entry?.notes ?? "")
        _ratings = State(initialValue: Dictionary(uniqueKeysWithValues: list.sortedMetrics.map { metric in
            (metric.id, entry?.rating(for: metric)?.value ?? 7)
        }))
        _locationName = State(initialValue: entry?.locationName ?? "")
        _locationAddress = State(initialValue: entry?.locationAddress ?? "")
        _latitude = State(initialValue: entry?.latitude)
        _longitude = State(initialValue: entry?.longitude)
        _rankedAt = State(initialValue: entry?.displayDate ?? .now)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    photoSection
                    detailsSection
                    dateSection
                    scoreSection
                    placeSection
                }
                .padding()
            }
            .background(ConnoisseurTheme.background.ignoresSafeArea())
            .navigationTitle(entry == nil ? "Add" : "Edit")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: save)
                        .fontWeight(.bold)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: selectedPhotoItems) {
                loadSelectedPhotos()
            }
            .sheet(isPresented: $isShowingPlacePicker) {
                PlacePickerSheetView(
                    initialLocation: selectedRankedLocation,
                    tintName: list.tintName,
                    applyLocation: applyLocation
                )
            }
#if os(iOS)
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraPicker { data in
                    pendingPhotoData.append(data)
                }
                .ignoresSafeArea()
            }
#endif
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                if let data = pendingPhotoData.first ?? entry?.sortedPhotos.first?.data {
                    PhotoThumbnail(data: data)
                } else {
                    Rectangle()
                        .fill(ConnoisseurTheme.tint(named: list.tintName).opacity(0.16))
                        .overlay {
                            VStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 42, weight: .bold))
                                Text("Make it visual")
                                    .font(.headline)
                            }
                            .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
                        }
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhotoItems, matching: .images) {
                    Label("Photos", systemImage: "photo.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .tint(ConnoisseurTheme.tint(named: list.tintName))

#if os(iOS)
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button {
                        isShowingCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(ConnoisseurTheme.tint(named: list.tintName))
                }
#endif
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Title", text: $title)
                .font(.title.bold())
                .textFieldStyle(.plain)
                .padding(16)
                .connoisseurField()

            TextField("Notes", text: $notes, axis: .vertical)
                .lineLimit(4...10)
                .textFieldStyle(.plain)
                .padding(16)
                .connoisseurField()
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date")
                .font(.title3.bold())

            DatePicker("Date and Time", selection: $rankedAt, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .padding(14)
                .connoisseurField()
        }
    }

    private var scoreSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Scorecard")
                    .font(.title3.bold())

                Spacer()

                Text(projectedScore.scoreString)
                    .font(.title3.monospacedDigit().weight(.bold))
            }

            ForEach(list.sortedMetrics) { metric in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(metric.title, systemImage: metric.polarity.symbolName)
                            .font(.headline)

                        Spacer()

                        Text((ratings[metric.id] ?? 7).scoreString)
                            .font(.headline.monospacedDigit())
                    }

                    Slider(
                        value: Binding(
                            get: { ratings[metric.id] ?? 7 },
                            set: { ratings[metric.id] = $0 }
                        ),
                        in: metric.minimumValue...metric.maximumValue,
                        step: 0.1
                    )
                    .tint(metric.polarity == .negative ? .red : ConnoisseurTheme.tint(named: list.tintName))
                }
                .padding(14)
                .connoisseurField()
            }
        }
    }

    private var placeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Place")
                    .font(.title3.bold())

                Spacer()

                if selectedRankedLocation != nil {
                    Button {
                        applyLocation(nil)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear place")
                }
            }

            Button {
                isShowingPlacePicker = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: selectedRankedLocation == nil ? "mappin.and.ellipse.circle" : "mappin.and.ellipse")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(locationName.isEmpty ? "Add Place" : locationName)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(locationAddress.isEmpty ? "Search nearby or pick from the map" : locationAddress)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .connoisseurField()
            }
            .buttonStyle(.plain)
        }
    }

    private var selectedRankedLocation: RankedLocation? {
        guard let latitude, let longitude, !locationName.isEmpty else { return nil }

        return RankedLocation(
            name: locationName,
            address: locationAddress,
            latitude: latitude,
            longitude: longitude
        )
    }

    private var projectedScore: Double {
        let scoringMetrics = list.sortedMetrics.filter { $0.polarity != .neutral && $0.effectiveWeight > 0 }
        let possibleScore = scoringMetrics.reduce(0) { $0 + $1.effectiveWeight }
        guard possibleScore > 0 else { return 0 }

        let earnedScore = scoringMetrics.reduce(0) { partialResult, metric in
            partialResult + metric.scoreContribution(for: ratings[metric.id] ?? metric.minimumValue)
        }

        return earnedScore / possibleScore * 10
    }

    private func loadSelectedPhotos() {
        Task {
            var imageData: [Data] = []

            for entry in selectedPhotoItems {
                if let data = try? await entry.loadTransferable(type: Data.self) {
                    imageData.append(data)
                }
            }

            pendingPhotoData = imageData
        }
    }

    private func applyLocation(_ location: RankedLocation?) {
        locationName = location?.name ?? ""
        locationAddress = location?.address ?? ""
        latitude = location?.latitude
        longitude = location?.longitude
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedEntry: RankedEntry
        if let entry {
            savedEntry = entry
        } else {
            savedEntry = RankedEntry(title: trimmedTitle, list: list)
            modelContext.insert(savedEntry)
            list.appendEntry(savedEntry)
        }

        savedEntry.title = trimmedTitle
        savedEntry.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        savedEntry.locationName = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        savedEntry.locationAddress = locationAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        savedEntry.latitude = latitude
        savedEntry.longitude = longitude
        savedEntry.rankedAt = rankedAt
        savedEntry.updatedAt = .now

        for metric in list.sortedMetrics {
            let value = ratings[metric.id] ?? metric.minimumValue

            if let existingRating = savedEntry.rating(for: metric) {
                existingRating.value = value
                existingRating.metricTitleSnapshot = metric.title
            } else {
                let rating = MetricRating(metricID: metric.id, metricTitleSnapshot: metric.title, value: value, entry: savedEntry)
                modelContext.insert(rating)
                savedEntry.appendRating(rating)
            }
        }

        for data in pendingPhotoData {
            let photo = RankedPhoto(data: data, entry: savedEntry)
            modelContext.insert(photo)
            savedEntry.appendPhoto(photo)
        }

        list.updatedAt = .now
        dismiss()
    }
}
