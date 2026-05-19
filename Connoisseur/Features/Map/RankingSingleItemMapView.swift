//
//  RankingSingleItemMapView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import MapKit
import SwiftUI

struct RankingSingleItemMapView: View {
    let item: RankedItem

    var body: some View {
        if let coordinate = item.coordinate {
            Map(initialPosition: .region(region(for: coordinate))) {
                Marker(item.locationName.isEmpty ? item.title : item.locationName, coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
            }
            .mapStyle(.standard(elevation: .realistic))
        }
    }

    private func region(for coordinate: RankingCoordinate) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        )
    }
}
