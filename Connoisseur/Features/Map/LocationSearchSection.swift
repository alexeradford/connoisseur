//
//  LocationSearchSection.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import MapKit
import SwiftUI

struct LocationSearchSection: View {
    @Binding var locationName: String
    @Binding var locationAddress: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    let tint: Color

    @StateObject private var search = LocationSearchService()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Place")
                    .font(.title3.bold())

                Spacer()

                if latitude != nil {
                    Button {
                        clearLocation()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear place")
                }
            }

            TextField("Search restaurants, venues, courses", text: $search.query)
                .textFieldStyle(.plain)
                .padding(14)
                .connoisseurField()

            if !locationName.isEmpty {
                Label(locationName, systemImage: "mappin.and.ellipse")
                    .font(.headline)
                    .foregroundStyle(tint)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .connoisseurField()
            }

            if !search.results.isEmpty {
                VStack(spacing: 0) {
                    ForEach(search.results.prefix(5), id: \.self) { result in
                        Button {
                            Task {
                                await choose(result)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(tint)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.title)
                                        .font(.headline)
                                    Text(result.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }

                                Spacer()
                            }
                            .padding(12)
                        }
                        .buttonStyle(.plain)

                        if result != search.results.prefix(5).last {
                            Divider()
                                .padding(.leading, 46)
                        }
                    }
                }
                .connoisseurField()
            }
        }
    }

    private func choose(_ completion: MKLocalSearchCompletion) async {
        guard let resolvedLocation = await search.resolve(completion) else { return }

        locationName = resolvedLocation.name
        locationAddress = resolvedLocation.address
        latitude = resolvedLocation.latitude
        longitude = resolvedLocation.longitude
        search.query = ""
    }

    private func clearLocation() {
        locationName = ""
        locationAddress = ""
        latitude = nil
        longitude = nil
        search.query = ""
    }
}
