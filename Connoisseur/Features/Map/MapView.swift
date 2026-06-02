//
//  MapView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-26.
//

import MapKit
import SwiftData
import SwiftUI

struct MapView: View {
    @Query(sort: \RankedList.createdAt) private var lists: [RankedList]
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedEntryID: UUID?
    @State private var accessoryDetent: TabSheetDetent = .height(180)

    private let accessoryDetents: [TabSheetDetent] = [.height(180), .medium, .large]

    private var entryItems: [MapEntryItem] {
        lists.flatMap { list in
            list.rankedEntries.enumerated().map { index, entry in
                MapEntryItem(list: list, entry: entry, rank: index + 1)
            }
        }
    }

    private var locatedEntryItems: [MapEntryItem] {
        entryItems.filter { $0.entry.coordinate != nil }
    }

    private var selectedItem: MapEntryItem? {
        guard let selectedEntryID else { return nil }
        return entryItems.first { $0.entry.id == selectedEntryID }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if lists.isEmpty {
                    ContentUnavailableView("No lists", systemImage: "map", description: Text("Create a list to see ranked places on the map."))
                        .background(ConnoisseurTheme.background.ignoresSafeArea())
                } else {
                    mapContent
                }
            }
            .onAppear {
                position = mapPosition
            }
            .onChange(of: locatedEntryItems.map(\.entry.id)) {
                position = mapPosition
            }
            .tabSheet(
                isPresented: !lists.isEmpty,
                selection: $accessoryDetent,
                detents: accessoryDetents
            ) { context in
                MapEntriesAccessoryView(
                    entryItems: entryItems,
                    locatedEntryCount: locatedEntryItems.count,
                    selectedItem: selectedItem,
                    context: context,
                    toggleExpansion: toggleAccessoryExpansion,
                    focus: focus,
                    dismissOverview: dismissOverview
                )
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(.green, in: Circle())

                        VStack(alignment: .leading, spacing: 5) {
                            Text("All entries")
                                .font(.body.bold())
                                .lineLimit(2)
                                .minimumScaleFactor(0.78)
                        }
                    }
                }
                .sharedBackgroundVisibility(.visible)
            }
        }
    }
    
    private var mapContent: some View {
        ZStack(alignment: .topLeading) {
            Map(position: $position) {
                ForEach(locatedEntryItems, id: \.id) { item in
                    if let coordinate = item.entry.coordinate {
                        Annotation(item.entry.title, coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)) {
                            VStack(spacing: 4) {
                                Text("\(item.rank)")
                                    .font(.caption.monospacedDigit().bold())
                                    .foregroundStyle(.white)
                                    .frame(width: selectedEntryID == item.entry.id ? 36 : 30, height: selectedEntryID == item.entry.id ? 36 : 30)
                                    .background(ConnoisseurTheme.tint(named: item.list.tintName), in: Circle())
                                
                                Text(item.entry.score(using: item.list.sortedMetrics).scoreString)
                                    .font(.caption2.monospacedDigit().bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(.regularMaterial, in: Capsule())
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
        }
    }
    
    private var mapPosition: MapCameraPosition {
        let coordinates = locatedEntryItems.compactMap(\.entry.coordinate)
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
    
    private func focus(_ item: MapEntryItem) {
        withAnimation(.snappy(duration: 0.32)) {
            selectedEntryID = item.entry.id
            accessoryDetent = .medium

            if let region = focusRegion(for: item.entry) {
                position = .region(region)
            }
        }
    }

    private func focusRegion(for entry: RankedEntry) -> MKCoordinateRegion? {
        guard let coordinate = entry.coordinate else { return nil }

        let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        // After a tap the sheet rests at the medium detent, covering roughly the
        // bottom half of the map. Shift the region's center south by a quarter of
        // its span (half of the covered fraction) so the pin settles in the middle
        // of the area still visible above the sheet rather than behind it.
        let sheetCoverage = 0.5
        let center = CLLocationCoordinate2D(
            latitude: coordinate.latitude - span.latitudeDelta * sheetCoverage / 2,
            longitude: coordinate.longitude
        )

        return MKCoordinateRegion(center: center, span: span)
    }

    private func dismissOverview() {
        withAnimation(.snappy(duration: 0.32)) {
            selectedEntryID = nil
            position = mapPosition
        }
    }

    private func toggleAccessoryExpansion() {
        withAnimation(.snappy(duration: 0.32)) {
            accessoryDetent = accessoryDetent == accessoryDetents[0] ? accessoryDetents[1] : accessoryDetents[0]
        }
    }
}
