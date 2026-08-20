import Foundation
import CoreLocation

struct LocationCoordinate {
    let latitude: Double
    let longitude: Double
}

@MainActor
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<LocationCoordinate?, Never>?

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationDenied: Bool = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = manager.authorizationStatus
        isLocationDenied = manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted
    }

    func requestLocation() async -> LocationCoordinate? {
        let status = manager.authorizationStatus

        if status == .denied || status == .restricted {
            isLocationDenied = true
            return nil
        }

        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
            // Give the system a moment to respond
            try? await Task.sleep(for: .milliseconds(500))
        }

        if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            isLocationDenied = true
            return nil
        }

        return await withCheckedContinuation { cont in
            self.continuation = cont
            manager.requestLocation()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let coord = LocationCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        Task { @MainActor in
            self.continuation?.resume(returning: coord)
            self.continuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.continuation?.resume(returning: nil)
            self.continuation = nil
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            self.isLocationDenied = manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted
        }
    }
}
