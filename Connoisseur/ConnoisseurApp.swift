//
//  ConnoisseurApp.swift
//  Connoisseur
//
//  Created by Alex Radford on 2026-05-19.
//

import SwiftUI
import SwiftData

@main
struct ConnoisseurApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            RankingCategory.self,
            RankingMetric.self,
            RankedItem.self,
            MetricRating.self,
            RankedPhoto.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
