//
//  ContentView.swift
//  Connoisseur
//
//  Created by Alex Radford on 2026-05-19.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \RankedList.createdAt) private var lists: [RankedList]

    var body: some View {
        Group {
            if lists.isEmpty {
                OnboardingFlowView()
            } else {
                ConnoisseurTabView()
            }
        }
    }
}

#Preview("Onboarding") {
    ContentView()
        .modelContainer(for: [
            RankedList.self,
            RankingMetric.self,
            RankedEntry.self,
            MetricRating.self,
            RankedPhoto.self,
        ], inMemory: true)
}
