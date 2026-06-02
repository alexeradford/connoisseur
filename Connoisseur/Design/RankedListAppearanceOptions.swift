//
//  RankedListAppearanceOptions.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Foundation

struct RankedListSymbolOption: Identifiable {
    let systemName: String
    let title: String
    let category: String
    let keywords: [String]

    var id: String { systemName }

    init(systemName: String, title: String, category: String, keywords: [String] = []) {
        self.systemName = systemName
        self.title = title
        self.category = category
        self.keywords = keywords
    }

    func matches(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return true }

        if title.lowercased().contains(trimmed) { return true }
        if category.lowercased().contains(trimmed) { return true }
        if systemName.lowercased().contains(trimmed) { return true }
        return keywords.contains { $0.lowercased().contains(trimmed) }
    }
}

struct RankedListTintOption: Identifiable {
    let name: String
    let title: String

    var id: String { name }
}

enum RankedListAppearanceOptions {
    static let symbols: [RankedListSymbolOption] = [
        // General
        RankedListSymbolOption(systemName: "sparkles", title: "Sparkles", category: "General", keywords: ["magic", "shine", "new"]),
        RankedListSymbolOption(systemName: "trophy.fill", title: "Trophy", category: "General", keywords: ["win", "award", "best"]),
        RankedListSymbolOption(systemName: "rosette", title: "Rosette", category: "General", keywords: ["ribbon", "award", "prize"]),
        RankedListSymbolOption(systemName: "medal.fill", title: "Medal", category: "General", keywords: ["award", "win", "first"]),
        RankedListSymbolOption(systemName: "crown.fill", title: "Crown", category: "General", keywords: ["king", "queen", "royal", "top"]),
        RankedListSymbolOption(systemName: "star.fill", title: "Star", category: "General", keywords: ["favorite", "rating"]),
        RankedListSymbolOption(systemName: "heart.fill", title: "Heart", category: "General", keywords: ["love", "favorite", "like"]),
        RankedListSymbolOption(systemName: "hand.thumbsup.fill", title: "Thumbs Up", category: "General", keywords: ["like", "approve", "good"]),
        RankedListSymbolOption(systemName: "checkmark.seal.fill", title: "Verified", category: "General", keywords: ["seal", "approved", "check"]),
        RankedListSymbolOption(systemName: "bookmark.fill", title: "Bookmark", category: "General", keywords: ["save", "read later"]),
        RankedListSymbolOption(systemName: "pin.fill", title: "Pin", category: "General", keywords: ["save", "stick"]),
        RankedListSymbolOption(systemName: "tag.fill", title: "Tag", category: "General", keywords: ["label", "price"]),
        RankedListSymbolOption(systemName: "flag.fill", title: "Flag", category: "General", keywords: ["mark", "report"]),
        RankedListSymbolOption(systemName: "list.bullet", title: "List", category: "General", keywords: ["items", "ranking"]),
        RankedListSymbolOption(systemName: "number", title: "Number", category: "General", keywords: ["hash", "count", "rank"]),

        // Food & Drink
        RankedListSymbolOption(systemName: "fork.knife", title: "Dining", category: "Food & Drink", keywords: ["food", "restaurant", "eat", "meal"]),
        RankedListSymbolOption(systemName: "wineglass.fill", title: "Wine", category: "Food & Drink", keywords: ["drinks", "bar", "alcohol"]),
        RankedListSymbolOption(systemName: "mug.fill", title: "Beer", category: "Food & Drink", keywords: ["drinks", "pub", "ale"]),
        RankedListSymbolOption(systemName: "cup.and.saucer.fill", title: "Coffee", category: "Food & Drink", keywords: ["cafe", "tea", "drink"]),
        RankedListSymbolOption(systemName: "takeoutbag.and.cup.and.straw.fill", title: "Takeout", category: "Food & Drink", keywords: ["fast food", "delivery"]),
        RankedListSymbolOption(systemName: "birthday.cake.fill", title: "Cake", category: "Food & Drink", keywords: ["dessert", "bakery", "sweet"]),
        RankedListSymbolOption(systemName: "carrot.fill", title: "Veggies", category: "Food & Drink", keywords: ["vegetable", "produce", "healthy"]),
        RankedListSymbolOption(systemName: "fish.fill", title: "Seafood", category: "Food & Drink", keywords: ["fish", "sushi"]),

        // Entertainment
        RankedListSymbolOption(systemName: "popcorn.fill", title: "Movies", category: "Entertainment", keywords: ["cinema", "film", "theater"]),
        RankedListSymbolOption(systemName: "film.fill", title: "Film", category: "Entertainment", keywords: ["movie", "video", "cinema"]),
        RankedListSymbolOption(systemName: "tv.fill", title: "TV", category: "Entertainment", keywords: ["shows", "series", "television"]),
        RankedListSymbolOption(systemName: "music.note", title: "Music", category: "Entertainment", keywords: ["song", "audio", "playlist"]),
        RankedListSymbolOption(systemName: "headphones", title: "Headphones", category: "Entertainment", keywords: ["music", "podcast", "audio"]),
        RankedListSymbolOption(systemName: "guitars.fill", title: "Guitars", category: "Entertainment", keywords: ["music", "band", "concert"]),
        RankedListSymbolOption(systemName: "book.closed.fill", title: "Books", category: "Entertainment", keywords: ["reading", "library", "novel"]),
        RankedListSymbolOption(systemName: "gamecontroller.fill", title: "Games", category: "Entertainment", keywords: ["gaming", "video games", "play"]),
        RankedListSymbolOption(systemName: "theatermasks.fill", title: "Shows", category: "Entertainment", keywords: ["theater", "drama", "play"]),
        RankedListSymbolOption(systemName: "ticket.fill", title: "Tickets", category: "Entertainment", keywords: ["events", "concert", "admission"]),
        RankedListSymbolOption(systemName: "paintpalette.fill", title: "Art", category: "Entertainment", keywords: ["painting", "gallery", "creative"]),
        RankedListSymbolOption(systemName: "camera.fill", title: "Photos", category: "Entertainment", keywords: ["photography", "picture"]),

        // Travel & Places
        RankedListSymbolOption(systemName: "map.fill", title: "Places", category: "Travel & Places", keywords: ["map", "location", "explore"]),
        RankedListSymbolOption(systemName: "mappin.and.ellipse", title: "Map Pin", category: "Travel & Places", keywords: ["location", "spot", "marker"]),
        RankedListSymbolOption(systemName: "globe.americas.fill", title: "World", category: "Travel & Places", keywords: ["earth", "global", "travel"]),
        RankedListSymbolOption(systemName: "airplane", title: "Travel", category: "Travel & Places", keywords: ["flight", "plane", "trip", "vacation"]),
        RankedListSymbolOption(systemName: "car.fill", title: "Drives", category: "Travel & Places", keywords: ["car", "road trip", "auto"]),
        RankedListSymbolOption(systemName: "bicycle", title: "Cycling", category: "Travel & Places", keywords: ["bike", "ride"]),
        RankedListSymbolOption(systemName: "tram.fill", title: "Transit", category: "Travel & Places", keywords: ["train", "subway", "metro"]),
        RankedListSymbolOption(systemName: "ferry.fill", title: "Ferry", category: "Travel & Places", keywords: ["boat", "ship", "cruise"]),
        RankedListSymbolOption(systemName: "building.2.fill", title: "Cities", category: "Travel & Places", keywords: ["city", "urban", "buildings"]),
        RankedListSymbolOption(systemName: "building.columns.fill", title: "Landmarks", category: "Travel & Places", keywords: ["museum", "bank", "monument"]),
        RankedListSymbolOption(systemName: "house.fill", title: "Home", category: "Travel & Places", keywords: ["house", "stay", "lodging"]),
        RankedListSymbolOption(systemName: "tent.fill", title: "Camping", category: "Travel & Places", keywords: ["camp", "outdoors", "tent"]),
        RankedListSymbolOption(systemName: "beach.umbrella.fill", title: "Beach", category: "Travel & Places", keywords: ["seaside", "vacation", "summer"]),

        // Activities & Fitness
        RankedListSymbolOption(systemName: "figure.walk", title: "Walks", category: "Activities", keywords: ["walking", "stroll"]),
        RankedListSymbolOption(systemName: "figure.run", title: "Running", category: "Activities", keywords: ["run", "jog", "cardio"]),
        RankedListSymbolOption(systemName: "figure.hiking", title: "Hiking", category: "Activities", keywords: ["hike", "trail", "trek"]),
        RankedListSymbolOption(systemName: "dumbbell.fill", title: "Fitness", category: "Activities", keywords: ["gym", "workout", "weights"]),
        RankedListSymbolOption(systemName: "sportscourt.fill", title: "Sports", category: "Activities", keywords: ["court", "game", "athletics"]),
        RankedListSymbolOption(systemName: "soccerball", title: "Soccer", category: "Activities", keywords: ["football", "ball"]),
        RankedListSymbolOption(systemName: "basketball.fill", title: "Basketball", category: "Activities", keywords: ["hoops", "ball"]),
        RankedListSymbolOption(systemName: "tennis.racket", title: "Tennis", category: "Activities", keywords: ["racket", "sport"]),
        RankedListSymbolOption(systemName: "flag.checkered", title: "Races", category: "Activities", keywords: ["racing", "finish", "motorsport"]),

        // Nature
        RankedListSymbolOption(systemName: "leaf.fill", title: "Nature", category: "Nature", keywords: ["plant", "green", "eco"]),
        RankedListSymbolOption(systemName: "tree.fill", title: "Trees", category: "Nature", keywords: ["forest", "park", "wood"]),
        RankedListSymbolOption(systemName: "mountain.2.fill", title: "Outdoors", category: "Nature", keywords: ["mountain", "hike", "peak"]),
        RankedListSymbolOption(systemName: "pawprint.fill", title: "Animals", category: "Nature", keywords: ["pet", "paw", "wildlife"]),
        RankedListSymbolOption(systemName: "flame.fill", title: "Hot", category: "Nature", keywords: ["fire", "spicy", "trending"]),
        RankedListSymbolOption(systemName: "bolt.fill", title: "Energy", category: "Nature", keywords: ["lightning", "power", "fast"]),
        RankedListSymbolOption(systemName: "drop.fill", title: "Water", category: "Nature", keywords: ["drink", "rain", "liquid"]),
        RankedListSymbolOption(systemName: "snowflake", title: "Snow", category: "Nature", keywords: ["winter", "cold", "ski"]),
        RankedListSymbolOption(systemName: "cloud.fill", title: "Weather", category: "Nature", keywords: ["cloud", "sky"]),
        RankedListSymbolOption(systemName: "moon.stars.fill", title: "Night", category: "Nature", keywords: ["moon", "evening", "dark"]),
        RankedListSymbolOption(systemName: "sun.max.fill", title: "Sunny", category: "Nature", keywords: ["sun", "day", "bright"]),

        // Objects
        RankedListSymbolOption(systemName: "gift.fill", title: "Gifts", category: "Objects", keywords: ["present", "birthday", "wishlist"]),
        RankedListSymbolOption(systemName: "bag.fill", title: "Shopping", category: "Objects", keywords: ["shop", "store", "buy"]),
        RankedListSymbolOption(systemName: "cart.fill", title: "Cart", category: "Objects", keywords: ["shopping", "groceries", "buy"]),
        RankedListSymbolOption(systemName: "creditcard.fill", title: "Spending", category: "Objects", keywords: ["money", "payment", "card"]),
        RankedListSymbolOption(systemName: "briefcase.fill", title: "Work", category: "Objects", keywords: ["job", "business", "office"]),
        RankedListSymbolOption(systemName: "graduationcap.fill", title: "School", category: "Objects", keywords: ["education", "study", "learn"]),
        RankedListSymbolOption(systemName: "lightbulb.fill", title: "Ideas", category: "Objects", keywords: ["idea", "inspiration", "tip"]),
        RankedListSymbolOption(systemName: "key.fill", title: "Key", category: "Objects", keywords: ["unlock", "access"]),
        RankedListSymbolOption(systemName: "bell.fill", title: "Bell", category: "Objects", keywords: ["alert", "notify", "reminder"]),
        RankedListSymbolOption(systemName: "clock.fill", title: "Time", category: "Objects", keywords: ["clock", "hours", "schedule"]),
        RankedListSymbolOption(systemName: "calendar", title: "Calendar", category: "Objects", keywords: ["date", "events", "schedule"]),
        RankedListSymbolOption(systemName: "gearshape.fill", title: "Settings", category: "Objects", keywords: ["gear", "config", "tools"]),
    ]

    static let tints: [RankedListTintOption] = [
        RankedListTintOption(name: "mint", title: "Mint"),
        RankedListTintOption(name: "emerald", title: "Emerald"),
        RankedListTintOption(name: "forest", title: "Forest"),
        RankedListTintOption(name: "teal", title: "Teal"),
        RankedListTintOption(name: "aqua", title: "Aqua"),
        RankedListTintOption(name: "sky", title: "Sky"),
        RankedListTintOption(name: "blue", title: "Blue"),
        RankedListTintOption(name: "indigo", title: "Indigo"),
        RankedListTintOption(name: "violet", title: "Violet"),
        RankedListTintOption(name: "plum", title: "Plum"),
        RankedListTintOption(name: "magenta", title: "Magenta"),
        RankedListTintOption(name: "rose", title: "Rose"),
        RankedListTintOption(name: "berry", title: "Berry"),
        RankedListTintOption(name: "crimson", title: "Crimson"),
        RankedListTintOption(name: "coral", title: "Coral"),
        RankedListTintOption(name: "tangerine", title: "Tangerine"),
        RankedListTintOption(name: "citrus", title: "Citrus"),
        RankedListTintOption(name: "gold", title: "Gold"),
        RankedListTintOption(name: "amber", title: "Amber"),
        RankedListTintOption(name: "olive", title: "Olive"),
        RankedListTintOption(name: "slate", title: "Slate"),
        RankedListTintOption(name: "graphite", title: "Graphite"),
    ]
}
