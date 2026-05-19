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
        VStack(alignment: .leading, spacing: 14) {
            categoryHero

            if categories.count > 1 {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(categories) { category in
                            Button {
                                selectCategory(category)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: category.symbolName)
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
        HStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(ConnoisseurTheme.tint(named: selectedCategory.tintName).gradient)
                    .frame(width: 82, height: 82)

                Image(systemName: selectedCategory.symbolName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: selectedCategoryID)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(selectedCategory.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                if !selectedCategory.prompt.isEmpty {
                    Text(selectedCategory.prompt)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 10) {
                    Label("\(selectedCategory.items.count)", systemImage: "star.fill")
                    Label("\(selectedCategory.metrics.count)", systemImage: "slider.horizontal.3")
                }
                .font(.caption.weight(.bold))
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
