//
//  PlacePickerSheetView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import CoreLocation
import MapKit
import SwiftUI

struct PlacePickerSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationProvider = UserLocationProvider()
    @StateObject private var searchService = LocationSearchService()

    let initialLocation: RankedLocation?
    let tintName: String
    let applyLocation: (RankedLocation?) -> Void

    @State private var selectedLocation: RankedLocation?
    @State private var query = ""
    @State private var nearbyLocations: [RankedLocation] = []
    @State private var searchResults: [RankedLocation] = []
    @State private var mapPosition: MapCameraPosition = .automatic

    private var tint: Color {
        ConnoisseurTheme.tint(named: tintName)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                mapView
                    .frame(height: 320)

                VStack(alignment: .leading, spacing: 14) {
                    TextField("Search restaurants, venues, courses", text: $query)
                        .textFieldStyle(.plain)
                        .padding(14)
                        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 8))

                    if let selectedLocation {
                        selectedPlaceRow(selectedLocation)
                    }

                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            if !searchResults.isEmpty {
                                locationSection(title: "Search", locations: searchResults)
                            }

                            if !nearbyLocations.isEmpty {
                                locationSection(title: "Nearby", locations: nearbyLocations)
                            }

                            if searchResults.isEmpty && nearbyLocations.isEmpty {
                                emptyState
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    .scrollIndicators(.hidden)
                }
                .padding()
                .background(ConnoisseurTheme.background)
            }
            .navigationTitle("Place")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .destructiveAction) {
                    if selectedLocation != nil {
                        Button("Clear") {
                            selectedLocation = nil
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        applyLocation(selectedLocation)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .task {
                selectedLocation = initialLocation
                mapPosition = initialMapPosition
                locationProvider.requestLocation()
            }
            .task(id: locationProvider.coordinate) {
                await refreshNearbySuggestions()
            }
            .task(id: query) {
                await refreshSearchResults()
            }
            .onChange(of: selectedLocation) {
                guard let selectedLocation else { return }
                mapPosition = mapPosition(around: selectedLocation.coordinate)
            }
        }
    }

    private var mapView: some View {
        Map(position: $mapPosition) {
            if let coordinate = locationProvider.coordinate {
                Annotation("You", coordinate: clCoordinate(from: coordinate)) {
                    Image(systemName: "location.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(.blue, in: Circle())
                }
            }

            ForEach(mapLocations) { location in
                Annotation(location.name, coordinate: clCoordinate(from: location.coordinate)) {
                    Button {
                        selectedLocation = location
                    } label: {
                        Image(systemName: selectedLocation == location ? "mappin.circle.fill" : "mappin.circle")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(selectedLocation == location ? tint : .primary)
                            .padding(5)
                            .background(.regularMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(location.name)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
    }

    private var mapLocations: [RankedLocation] {
        var uniqueLocations: [RankedLocation] = []

        for location in [selectedLocation].compactMap({ $0 }) + searchResults + nearbyLocations {
            if !uniqueLocations.contains(where: { $0.id == location.id }) {
                uniqueLocations.append(location)
            }
        }

        return uniqueLocations
    }

    private var initialMapPosition: MapCameraPosition {
        if let initialLocation {
            return mapPosition(around: initialLocation.coordinate)
        }

        if let coordinate = locationProvider.coordinate {
            return mapPosition(around: coordinate)
        }

        return .automatic
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "location.magnifyingglass")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(tint)

            Text("Finding nearby places")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }

    private func selectedPlaceRow(_ location: RankedLocation) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.and.ellipse")
                .font(.title3.weight(.bold))
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .font(.headline)

                if !location.address.isEmpty {
                    Text(location.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 8))
    }

    private func locationSection(title: String, locations: [RankedLocation]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            VStack(spacing: 0) {
                ForEach(locations) { location in
                    Button {
                        selectedLocation = location
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: selectedLocation == location ? "checkmark.circle.fill" : "mappin.circle.fill")
                                .font(.title3)
                                .foregroundStyle(selectedLocation == location ? tint : .secondary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(location.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                if !location.address.isEmpty {
                                    Text(location.address)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()
                        }
                        .padding(12)
                    }
                    .buttonStyle(.plain)

                    if location.id != locations.last?.id {
                        Divider()
                            .padding(.leading, 46)
                    }
                }
            }
            .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private func refreshNearbySuggestions() async {
        searchService.updateSearchRegion(around: locationProvider.coordinate)

        guard let coordinate = locationProvider.coordinate else { return }
        mapPosition = selectedLocation.map { mapPosition(around: $0.coordinate) } ?? mapPosition(around: coordinate)
        nearbyLocations = await searchService.nearbySuggestions(around: coordinate)
    }

    private func refreshSearchResults() async {
        try? await Task.sleep(for: .milliseconds(250))
        guard !Task.isCancelled else { return }

        searchResults = await searchService.search(query, around: locationProvider.coordinate)
    }

    private func mapPosition(around coordinate: RankingCoordinate) -> MapCameraPosition {
        .region(MKCoordinateRegion(
            center: clCoordinate(from: coordinate),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
    }

    private func clCoordinate(from coordinate: RankingCoordinate) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
