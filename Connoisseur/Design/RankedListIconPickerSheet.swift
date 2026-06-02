//
//  RankedListIconPickerSheet.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-31.
//

import SwiftUI

struct RankedListIconPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var symbolName: String
    let tintName: String
    var onSelect: ((String) -> Void)?

    @State private var query = ""

    private let columns = [GridItem(.adaptive(minimum: 60), spacing: 12)]

    private var groupedSymbols: [(category: String, symbols: [RankedListSymbolOption])] {
        var order: [String] = []
        var buckets: [String: [RankedListSymbolOption]] = [:]

        for option in RankedListAppearanceOptions.symbols where option.matches(query) {
            if buckets[option.category] == nil {
                order.append(option.category)
            }
            buckets[option.category, default: []].append(option)
        }

        return order.map { ($0, buckets[$0] ?? []) }
    }

    private var tint: Color { ConnoisseurTheme.tint(named: tintName) }

    var body: some View {
        NavigationStack {
            ScrollView {
                let groups = groupedSymbols

                if groups.isEmpty {
                    ContentUnavailableView.search(text: query)
                        .padding(.top, 60)
                } else {
                    LazyVStack(alignment: .leading, spacing: 24, pinnedViews: [.sectionHeaders]) {
                        ForEach(groups, id: \.category) { group in
                            Section {
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(group.symbols) { option in
                                        iconButton(for: option)
                                    }
                                }
                            } header: {
                                Text(group.category)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 6)
                                    .background(.bar)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search icons")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func iconButton(for option: RankedListSymbolOption) -> some View {
        let isSelected = symbolName == option.systemName

        return Button {
            symbolName = option.systemName
            onSelect?(option.systemName)
            dismiss()
        } label: {
            Image(systemName: option.systemName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(isSelected ? .white : tint)
                .frame(width: 56, height: 56)
                .background(
                    isSelected ? AnyShapeStyle(tint.gradient) : AnyShapeStyle(Color.secondary.opacity(0.12)),
                    in: RoundedRectangle(cornerRadius: 14)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
