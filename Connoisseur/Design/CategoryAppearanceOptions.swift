//
//  CategoryAppearanceOptions.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation

struct CategorySymbolOption: Identifiable {
    let systemName: String
    let title: String

    var id: String { systemName }
}

struct CategoryTintOption: Identifiable {
    let name: String
    let title: String

    var id: String { name }
}

enum CategoryAppearanceOptions {
    static let symbols: [CategorySymbolOption] = [
        CategorySymbolOption(systemName: "sparkles", title: "Sparkles"),
        CategorySymbolOption(systemName: "trophy.fill", title: "Trophy"),
        CategorySymbolOption(systemName: "star.fill", title: "Star"),
        CategorySymbolOption(systemName: "heart.fill", title: "Heart"),
        CategorySymbolOption(systemName: "bookmark.fill", title: "Bookmark"),
        CategorySymbolOption(systemName: "pin.fill", title: "Pin"),
        CategorySymbolOption(systemName: "fork.knife", title: "Dining"),
        CategorySymbolOption(systemName: "wineglass.fill", title: "Drinks"),
        CategorySymbolOption(systemName: "cup.and.saucer.fill", title: "Coffee"),
        CategorySymbolOption(systemName: "takeoutbag.and.cup.and.straw.fill", title: "Takeout"),
        CategorySymbolOption(systemName: "popcorn.fill", title: "Movies"),
        CategorySymbolOption(systemName: "music.note", title: "Music"),
        CategorySymbolOption(systemName: "book.closed.fill", title: "Books"),
        CategorySymbolOption(systemName: "gamecontroller.fill", title: "Games"),
        CategorySymbolOption(systemName: "paintpalette.fill", title: "Art"),
        CategorySymbolOption(systemName: "camera.fill", title: "Photos"),
        CategorySymbolOption(systemName: "map.fill", title: "Places"),
        CategorySymbolOption(systemName: "mappin.and.ellipse", title: "Map Pin"),
        CategorySymbolOption(systemName: "figure.walk", title: "Walks"),
        CategorySymbolOption(systemName: "bicycle", title: "Cycling"),
        CategorySymbolOption(systemName: "car.fill", title: "Drives"),
        CategorySymbolOption(systemName: "airplane", title: "Travel"),
        CategorySymbolOption(systemName: "beach.umbrella.fill", title: "Beach"),
        CategorySymbolOption(systemName: "mountain.2.fill", title: "Outdoors"),
        CategorySymbolOption(systemName: "flag.checkered", title: "Races"),
        CategorySymbolOption(systemName: "sportscourt.fill", title: "Sports"),
        CategorySymbolOption(systemName: "dumbbell.fill", title: "Fitness"),
        CategorySymbolOption(systemName: "theatermasks.fill", title: "Shows"),
        CategorySymbolOption(systemName: "building.2.fill", title: "Cities"),
        CategorySymbolOption(systemName: "house.fill", title: "Home"),
        CategorySymbolOption(systemName: "gift.fill", title: "Gifts"),
        CategorySymbolOption(systemName: "leaf.fill", title: "Nature"),
        CategorySymbolOption(systemName: "flame.fill", title: "Hot"),
        CategorySymbolOption(systemName: "bolt.fill", title: "Energy"),
        CategorySymbolOption(systemName: "moon.stars.fill", title: "Night"),
        CategorySymbolOption(systemName: "sun.max.fill", title: "Sunny"),
    ]

    static let tints: [CategoryTintOption] = [
        CategoryTintOption(name: "mint", title: "Mint"),
        CategoryTintOption(name: "berry", title: "Berry"),
        CategoryTintOption(name: "citrus", title: "Citrus"),
        CategoryTintOption(name: "violet", title: "Violet"),
        CategoryTintOption(name: "blue", title: "Blue"),
        CategoryTintOption(name: "teal", title: "Teal"),
        CategoryTintOption(name: "forest", title: "Forest"),
        CategoryTintOption(name: "gold", title: "Gold"),
        CategoryTintOption(name: "coral", title: "Coral"),
        CategoryTintOption(name: "rose", title: "Rose"),
        CategoryTintOption(name: "indigo", title: "Indigo"),
        CategoryTintOption(name: "slate", title: "Slate"),
    ]
}
