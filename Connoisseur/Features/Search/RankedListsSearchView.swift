//
//  RankedListsSearchView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-26.
//

import MapKit
import SwiftData
import SwiftUI

struct RankedListsSearchView: View {
    @Query(sort: \RankedList.createdAt) private var lists: [RankedList]
    @State private var query = ""
    @State private var entryEditorList: RankedList?

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingLists: [RankedList] {
        guard !trimmedQuery.isEmpty else { return lists }

        return lists.filter { list in
            list.title.localizedStandardContains(trimmedQuery)
                || list.prompt.localizedStandardContains(trimmedQuery)
        }
    }

    private var matchingEntries: [(list: RankedList, entry: RankedEntry)] {
        let entries = lists.flatMap { list in
            list.rankedEntries.map { entry in
                (list: list, entry: entry)
            }
        }

        guard !trimmedQuery.isEmpty else { return entries }

        return entries.filter { item in
            item.entry.title.localizedStandardContains(trimmedQuery)
                || item.entry.notes.localizedStandardContains(trimmedQuery)
                || item.entry.locationName.localizedStandardContains(trimmedQuery)
                || item.entry.locationAddress.localizedStandardContains(trimmedQuery)
                || item.list.title.localizedStandardContains(trimmedQuery)
        }
    }

    private var matchingLocations: [SearchLocationResult] {
        let locations = groupedLocations
        guard !trimmedQuery.isEmpty else { return locations }

        return locations.filter { location in
            location.name.localizedStandardContains(trimmedQuery)
                || location.address.localizedStandardContains(trimmedQuery)
        }
    }

    private var groupedLocations: [SearchLocationResult] {
        var results: [SearchLocationResult] = []

        for list in lists {
            for entry in list.rankedEntries {
                guard !entry.locationName.isEmpty || !entry.locationAddress.isEmpty || entry.coordinate != nil else { continue }

                let key = SearchLocationResult.key(for: entry)
                let item = SearchLocationEntry(list: list, entry: entry)

                if let index = results.firstIndex(where: { $0.id == key }) {
                    results[index].entries.append(item)
                } else {
                    results.append(SearchLocationResult(
                        id: key,
                        name: SearchLocationResult.displayName(for: entry),
                        address: entry.locationAddress,
                        coordinate: entry.coordinate,
                        entries: [item]
                    ))
                }
            }
        }

        return results.sorted {
            if $0.name.localizedStandardCompare($1.name) == .orderedSame {
                return $0.address.localizedStandardCompare($1.address) == .orderedAscending
            }

            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if matchingLists.isEmpty && matchingLocations.isEmpty && matchingEntries.isEmpty {
                    ContentUnavailableView.search(text: trimmedQuery)
                        .listRowBackground(Color.clear)
                }

                if !matchingLists.isEmpty {
                    Section("Lists") {
                        ForEach(matchingLists) { list in
                            NavigationLink {
                                RankedListDetailView(list: list, entries: list.rankedEntries) {
                                    entryEditorList = list
                                }
                            } label: {
                                listRow(list)
                            }
                        }
                    }
                }

                if !matchingLocations.isEmpty {
                    Section("Locations") {
                        ForEach(matchingLocations) { location in
                            NavigationLink {
                                LocationSearchResultView(location: location)
                            } label: {
                                locationRow(location)
                            }
                        }
                    }
                }

                if !matchingEntries.isEmpty {
                    Section("Entries") {
                        ForEach(matchingEntries, id: \.entry.id) { item in
                            NavigationLink {
                                RankedEntryDetailView(list: item.list, entry: item.entry)
                            } label: {
                                entryRow(list: item.list, entry: item.entry)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(ConnoisseurTheme.background.ignoresSafeArea())
            .navigationTitle("Search")
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Lists, entries, and locations")
            .sheet(item: $entryEditorList) { list in
                RankedEntryEditorView(list: list, entry: nil)
            }
        }
    }

    private func listRow(_ list: RankedList) -> some View {
        HStack(spacing: 12) {
            RankedListIconView(
                list: list,
                size: 38,
                symbolFont: .system(size: 17, weight: .bold)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(list.title)
                    .font(.headline)
                    .lineLimit(1)

                Text("\(list.entryCount) entries")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func locationRow(_ location: SearchLocationResult) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(.green, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                    .lineLimit(1)

                if !location.address.isEmpty {
                    Text(location.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text("\(location.entries.count) \(location.entries.count == 1 ? "entry" : "entries")")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func entryRow(list: RankedList, entry: RankedEntry) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(entry.title)
                    .font(.headline)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text(entry.score(using: list.sortedMetrics).scoreString)
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
            }

            HStack(spacing: 6) {
                Text(list.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))

                if !entry.locationName.isEmpty {
                    Text(entry.locationName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct SearchLocationResult: Identifiable {
    let id: String
    let name: String
    let address: String
    let coordinate: RankingCoordinate?
    var entries: [SearchLocationEntry]

    static func key(for entry: RankedEntry) -> String {
        if let coordinate = entry.coordinate {
            return "\(coordinate.latitude.roundedSearchCoordinate),\(coordinate.longitude.roundedSearchCoordinate)"
        }

        let normalizedName = entry.locationName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedAddress = entry.locationAddress.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return "\(normalizedName)|\(normalizedAddress)"
    }

    static func displayName(for entry: RankedEntry) -> String {
        let locationName = entry.locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !locationName.isEmpty {
            return locationName
        }

        let address = entry.locationAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        if !address.isEmpty {
            return address
        }

        return entry.title
    }
}

private struct SearchLocationEntry: Identifiable {
    let list: RankedList
    let entry: RankedEntry

    var id: UUID {
        entry.id
    }
}

private struct LocationSearchResultView: View {
    let location: SearchLocationResult

    var body: some View {
        List {
            if let coordinate = location.coordinate {
                Section {
                    Map {
                        Marker(location.name, coordinate: CLLocationCoordinate2D(
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude
                        ))
                    }
                    .mapStyle(.standard(elevation: .realistic))
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                }
            }

            Section("Entries") {
                ForEach(location.entries) { item in
                    NavigationLink {
                        RankedEntryDetailView(list: item.list, entry: item.entry)
                    } label: {
                        LocationSearchEntryRow(list: item.list, entry: item.entry)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(ConnoisseurTheme.background.ignoresSafeArea())
        .navigationTitle(location.name)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

private struct LocationSearchEntryRow: View {
    let list: RankedList
    let entry: RankedEntry

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(list.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
            }

            Spacer(minLength: 0)

            Text(entry.score(using: list.sortedMetrics).scoreString)
                .font(.caption.monospacedDigit().weight(.bold))
                .foregroundStyle(ConnoisseurTheme.tint(named: list.tintName))
        }
        .padding(.vertical, 4)
    }
}

private extension Double {
    var roundedSearchCoordinate: String {
        String(format: "%.5f", self)
    }
}
