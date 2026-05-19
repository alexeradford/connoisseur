//
//  ItemEditorView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import PhotosUI
import SwiftData
import SwiftUI

struct ItemEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let category: RankingCategory
    let item: RankedItem?

    @State private var title: String
    @State private var notes: String
    @State private var ratings: [UUID: Double]
    @State private var locationName: String
    @State private var locationAddress: String
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var pendingPhotoData: [Data] = []
    @State private var isShowingPlacePicker = false

    init(category: RankingCategory, item: RankedItem?) {
        self.category = category
        self.item = item
        _title = State(initialValue: item?.title ?? "")
        _notes = State(initialValue: item?.notes ?? "")
        _ratings = State(initialValue: Dictionary(uniqueKeysWithValues: category.sortedMetrics.map { metric in
            (metric.id, item?.rating(for: metric)?.value ?? 7)
        }))
        _locationName = State(initialValue: item?.locationName ?? "")
        _locationAddress = State(initialValue: item?.locationAddress ?? "")
        _latitude = State(initialValue: item?.latitude)
        _longitude = State(initialValue: item?.longitude)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    photoSection
                    detailsSection
                    scoreSection
                    placeSection
                }
                .padding()
            }
            .background(ConnoisseurTheme.background.ignoresSafeArea())
            .navigationTitle(item == nil ? "Add" : "Edit")
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
                    tintName: category.tintName,
                    applyLocation: applyLocation
                )
            }
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                if let data = pendingPhotoData.first ?? item?.sortedPhotos.first?.data {
                    PhotoThumbnail(data: data)
                } else {
                    Rectangle()
                        .fill(ConnoisseurTheme.tint(named: category.tintName).opacity(0.16))
                        .overlay {
                            VStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 42, weight: .bold))
                                Text("Make it visual")
                                    .font(.headline)
                            }
                            .foregroundStyle(ConnoisseurTheme.tint(named: category.tintName))
                        }
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            PhotosPicker(selection: $selectedPhotoItems, matching: .images) {
                Label("Photos", systemImage: "photo.badge.plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .tint(ConnoisseurTheme.tint(named: category.tintName))
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Title", text: $title)
                .font(.title.bold())
                .textFieldStyle(.plain)
                .padding(16)
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))

            TextField("Notes", text: $notes, axis: .vertical)
                .lineLimit(4...10)
                .textFieldStyle(.plain)
                .padding(16)
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private var scoreSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Scorecard")
                    .font(.title3.bold())

                Spacer()

                Text(projectedScore.scoreString)
                    .font(.title3.monospacedDigit().weight(.black))
            }

            ForEach(category.sortedMetrics) { metric in
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
                    .tint(metric.polarity == .negative ? .red : ConnoisseurTheme.tint(named: category.tintName))
                }
                .padding(14)
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
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
                        .foregroundStyle(ConnoisseurTheme.tint(named: category.tintName))

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
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
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
        let scoringMetrics = category.sortedMetrics.filter { $0.polarity != .neutral && $0.effectiveWeight > 0 }
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

            for item in selectedPhotoItems {
                if let data = try? await item.loadTransferable(type: Data.self) {
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
        let savedItem: RankedItem
        if let item {
            savedItem = item
        } else {
            savedItem = RankedItem(title: trimmedTitle, category: category)
            modelContext.insert(savedItem)
            category.items.append(savedItem)
        }

        savedItem.title = trimmedTitle
        savedItem.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        savedItem.locationName = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        savedItem.locationAddress = locationAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        savedItem.latitude = latitude
        savedItem.longitude = longitude
        savedItem.updatedAt = .now

        for metric in category.sortedMetrics {
            let value = ratings[metric.id] ?? metric.minimumValue

            if let existingRating = savedItem.rating(for: metric) {
                existingRating.value = value
                existingRating.metricTitleSnapshot = metric.title
            } else {
                let rating = MetricRating(metricID: metric.id, metricTitleSnapshot: metric.title, value: value, item: savedItem)
                modelContext.insert(rating)
                savedItem.ratings.append(rating)
            }
        }

        for data in pendingPhotoData {
            let photo = RankedPhoto(data: data, item: savedItem)
            modelContext.insert(photo)
            savedItem.photos.append(photo)
        }

        category.updatedAt = .now
        dismiss()
    }
}
