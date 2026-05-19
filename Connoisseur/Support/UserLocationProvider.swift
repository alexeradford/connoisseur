//
//  UserLocationProvider.swift
//  Connoisseur
//
//  Created by Codex on 2026-05-19.
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class UserLocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var coordinate: RankingCoordinate?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    private let manager: CLLocationManager

    override init() {
        let manager = CLLocationManager()
        self.manager = manager
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        if isAuthorized(manager.authorizationStatus) {
            manager.requestLocation()
            return
        }

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted, .authorizedAlways:
            break
        @unknown default:
            break
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus

            if isAuthorized(authorizationStatus) {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            coordinate = RankingCoordinate(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }

    private func isAuthorized(_ status: CLAuthorizationStatus) -> Bool {
#if os(macOS)
        status == .authorizedAlways
#else
        status == .authorizedAlways || status == .authorizedWhenInUse
#endif
    }
}
