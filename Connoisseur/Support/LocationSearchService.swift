//
//  LocationSearchService.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation
import Combine
import MapKit

@MainActor
final class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var query = "" {
        didSet {
            completer.queryFragment = query
        }
    }

    @Published private(set) var results: [MKLocalSearchCompletion] = []

    private let completer: MKLocalSearchCompleter
    private let nearbyBusinessQueries = ["restaurants", "cafes", "bars", "bakeries", "shops"]

    override init() {
        let completer = MKLocalSearchCompleter()
        completer.resultTypes = [.pointOfInterest, .address]
        self.completer = completer
        super.init()
        completer.delegate = self
    }

    func updateSearchRegion(around coordinate: RankingCoordinate?) {
        guard let coordinate else { return }

        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        )
    }

    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            results = completer.results
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            results = []
        }
    }

    func resolve(_ completion: MKLocalSearchCompletion) async -> RankedLocation? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        guard let mapItem = try? await search.start().mapItems.first else { return nil }

        let address = mapItem.address?.fullAddress
            ?? mapItem.addressRepresentations?.fullAddress(includingRegion: false, singleLine: true)
            ?? completion.subtitle

        return RankedLocation(
            name: mapItem.name ?? completion.title,
            address: address,
            latitude: mapItem.location.coordinate.latitude,
            longitude: mapItem.location.coordinate.longitude
        )
    }

    func nearbySuggestions(around coordinate: RankingCoordinate?) async -> [RankedLocation] {
        guard coordinate != nil else { return [] }

        var locations: [RankedLocation] = []
        var seenLocationIDs = Set<String>()

        for query in nearbyBusinessQueries {
            let results = await search(query, around: coordinate, includesAddresses: false, limit: 6)

            for location in results where seenLocationIDs.insert(location.id).inserted {
                locations.append(location)

                if locations.count == 12 {
                    return locations
                }
            }
        }

        return locations
    }

    func search(_ query: String, around coordinate: RankingCoordinate?) async -> [RankedLocation] {
        await search(query, around: coordinate, includesAddresses: true, limit: 12)
    }

    private func search(
        _ query: String,
        around coordinate: RankingCoordinate?,
        includesAddresses: Bool,
        limit: Int
    ) async -> [RankedLocation] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmedQuery
        request.resultTypes = includesAddresses ? [.pointOfInterest, .address] : [.pointOfInterest]

        if let coordinate {
            request.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            )
        }

        guard let response = try? await MKLocalSearch(request: request).start() else { return [] }
        return response.mapItems.prefix(limit).compactMap(location(from:))
    }

    private func location(from mapItem: MKMapItem) -> RankedLocation? {
        let coordinate = mapItem.location.coordinate
        guard CLLocationCoordinate2DIsValid(coordinate) else { return nil }

        let address = mapItem.address?.fullAddress
            ?? mapItem.addressRepresentations?.fullAddress(includingRegion: false, singleLine: true)
            ?? ""

        return RankedLocation(
            name: mapItem.name ?? address,
            address: address,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }
}

struct RankedLocation: Hashable {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double

    var coordinate: RankingCoordinate {
        RankingCoordinate(latitude: latitude, longitude: longitude)
    }
}

extension RankedLocation: Identifiable {
    var id: String {
        "\(name)-\(latitude)-\(longitude)"
    }
}
