import Foundation
import CoreLocation

actor WeatherService {

    func fetchWeather(latitude: Double, longitude: Double) async throws -> OpenMeteoResponse {
        var components = URLComponents(string: AppConstants.openMeteoBase)!
        components.queryItems = [
            .init(name: "latitude", value: String(format: "%.4f", latitude)),
            .init(name: "longitude", value: String(format: "%.4f", longitude)),
            .init(name: "hourly", value: "uv_index,temperature_2m,relative_humidity_2m,cloud_cover"),
            .init(name: "daily", value: "uv_index_max,sunrise,sunset"),
            .init(name: "timezone", value: "auto"),
            .init(name: "forecast_days", value: "14"),
        ]

        guard let url = components.url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(OpenMeteoResponse.self, from: data)
    }

    func searchCity(_ query: String) async throws -> [GeocodingResult] {
        var components = URLComponents(string: AppConstants.geocodingBase)!
        components.queryItems = [
            .init(name: "name", value: query),
            .init(name: "count", value: "7"),
            .init(name: "language", value: "en"),
            .init(name: "format", value: "json"),
        ]

        guard let url = components.url else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return decoded.results ?? []
    }

    func reverseGeocode(latitude: Double, longitude: Double) async -> String? {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.locality ?? placemarks.first?.administrativeArea
        } catch {
            return nil
        }
    }
}
