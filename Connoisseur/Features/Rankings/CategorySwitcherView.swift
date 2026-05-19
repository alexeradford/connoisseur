//
//  CategorySwitcherView.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import SwiftUI

struct CategorySwitcherView: View {
    enum Direction {
        case previous
        case next
    }

    let categories: [RankingCategory]
    let selectedCategoryID: UUID
    let selectedCategory: RankingCategory
    let selectCategory: (RankingCategory) -> Void
    let moveSelection: (Direction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            categoryHero

            if categories.count > 1 {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(categories) { category in
                            Button {
                                selectCategory(category)
                            } label: {
                                HStack(spacing: 8) {
                                    CategoryIconView(
                                        category: category,
                                        size: 18,
                                        cornerRadius: 5,
                                        style: .glyph,
                                        symbolFont: .caption.weight(.bold)
                                    )
                                    Text(category.title)
                                        .lineLimit(1)
                                }
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .foregroundStyle(category.id == selectedCategoryID ? .white : .primary)
                                .background(
                                    category.id == selectedCategoryID
                                    ? ConnoisseurTheme.tint(named: category.tintName)
                                    : Color.white.opacity(0.68),
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
        }
    }

    private var categoryHero: some View {
        HStack(spacing: 14) {
            CategoryIconView(
                category: selectedCategory,
                size: 64,
                symbolFont: .system(size: 28, weight: .semibold)
            )
            .symbolEffect(.bounce, value: selectedCategoryID)

            VStack(alignment: .leading, spacing: 5) {
                Text(selectedCategory.title)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                if !selectedCategory.prompt.isEmpty {
                    Text(selectedCategory.prompt)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 10) {
                    Label("\(selectedCategory.items.count)", systemImage: "star.fill")
                    Label("\(selectedCategory.metrics.count)", systemImage: "slider.horizontal.3")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
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
}
