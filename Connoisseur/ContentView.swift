//
//  ContentView.swift
//  Connoisseur
//
//  Created by Alex Radford on 2026-05-19.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \RankingCategory.createdAt) private var categories: [RankingCategory]

    var body: some View {
        Group {
            if categories.isEmpty {
                OnboardingFlowView()
            } else {
                RankingsHomeView()
            }
        }
    }
}

#Preview("Onboarding") {
    ContentView()
        .modelContainer(for: [
            RankingCategory.self,
            RankingMetric.self,
            RankedItem.self,
            MetricRating.self,
            RankedPhoto.self,
        ], inMemory: true)
}
