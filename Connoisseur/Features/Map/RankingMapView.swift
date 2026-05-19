//
//  RankingMapView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import MapKit
import SwiftUI

struct RankingMapView: View {
    let category: RankingCategory
    let categories: [RankingCategory]
    let selectedCategoryID: UUID
    let selectCategory: (RankingCategory) -> Void
    let moveSelection: (CategorySwitcherView.Direction) -> Void

    @State private var position: MapCameraPosition = .automatic

    private var locatedItems: [RankedItem] {
        category.rankedItems.filter { $0.coordinate != nil }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(position: $position) {
                ForEach(Array(locatedItems.enumerated()), id: \.element.id) { index, item in
                    if let coordinate = item.coordinate {
                        Annotation(item.title, coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)) {
                            VStack(spacing: 4) {
                                Text("\(index + 1)")
                                    .font(.caption.monospacedDigit().weight(.black))
                                    .foregroundStyle(.white)
                                    .frame(width: 30, height: 30)
                                    .background(ConnoisseurTheme.tint(named: category.tintName), in: Circle())

                                Text(item.score(using: category.sortedMetrics).scoreString)
                                    .font(.caption2.monospacedDigit().weight(.bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(.regularMaterial, in: Capsule())
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))

            categoryOverlay
                .padding()
        }
        .onAppear {
            position = mapPosition
        }
        .onChange(of: locatedItems.map(\.id)) {
            position = mapPosition
        }
    }

    private var categoryOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: category.symbolName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(ConnoisseurTheme.tint(named: category.tintName).gradient, in: RoundedRectangle(cornerRadius: 8))
                    .symbolEffect(.bounce, value: selectedCategoryID)

                VStack(alignment: .leading, spacing: 5) {
                    Text(category.title)
                        .font(.title3.weight(.black))
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)

                    if !category.prompt.isEmpty {
                        Text(category.prompt)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    HStack(spacing: 10) {
                        Label("\(category.items.count)", systemImage: "star.fill")
                        Label("\(category.metrics.count)", systemImage: "slider.horizontal.3")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                if categories.count > 1 {
                    categoryStepper
                }
            }

            if categories.count > 1 {
                categoryPills
            }
        }
        .padding(14)
        .frame(maxWidth: 420, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.white.opacity(0.34), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.12), radius: 18, y: 10)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 28)
                .onEnded { value in
                    if value.translation.width < -36 {
                        moveSelection(.next)
                    } else if value.translation.width > 36 {
                        moveSelection(.previous)
                    }
                }
        )
    }

    private var categoryStepper: some View {
        HStack(spacing: 4) {
            Button {
                moveSelection(.previous)
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 30, height: 30)
            }
            .disabled(selectedCategoryID == categories.first?.id)

            Button {
                moveSelection(.next)
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 30, height: 30)
            }
            .disabled(selectedCategoryID == categories.last?.id)
        }
        .font(.subheadline.weight(.bold))
        .buttonStyle(.borderless)
    }

    private var categoryPills: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    Button {
                        selectCategory(category)
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: category.symbolName)
                            Text(category.title)
                                .lineLimit(1)
                        }
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .foregroundStyle(category.id == selectedCategoryID ? .white : .primary)
                        .background(
                            category.id == selectedCategoryID
                            ? ConnoisseurTheme.tint(named: category.tintName)
                            : Color.white.opacity(0.46),
                            in: Capsule()
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 1)
        }
        .scrollIndicators(.hidden)
    }

    private var mapPosition: MapCameraPosition {
        let coordinates = locatedItems.compactMap(\.coordinate)
        guard !coordinates.isEmpty else { return .automatic }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        let center = CLLocationCoordinate2D(
            latitude: ((latitudes.min() ?? 0) + (latitudes.max() ?? 0)) / 2,
            longitude: ((longitudes.min() ?? 0) + (longitudes.max() ?? 0)) / 2
        )
        let latitudeDelta = max((latitudes.max() ?? center.latitude) - (latitudes.min() ?? center.latitude), 0.02)
        let longitudeDelta = max((longitudes.max() ?? center.longitude) - (longitudes.min() ?? center.longitude), 0.02)

        return .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta * 1.8, longitudeDelta: longitudeDelta * 1.8)
        ))
    }
}
