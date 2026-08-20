import Foundation

struct OpenMeteoResponse: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let hourly: HourlyData
    let daily: DailyData
}

struct HourlyData: Codable {
    let time: [String]
    let uvIndex: [Double?]
    let temperature2m: [Double?]
    let relativeHumidity2m: [Int?]
    let cloudCover: [Int?]

    enum CodingKeys: String, CodingKey {
        case time
        case uvIndex = "uv_index"
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case cloudCover = "cloud_cover"
    }
}

struct DailyData: Codable {
    let time: [String]
    let uvIndexMax: [Double?]
    let sunrise: [String]
    let sunset: [String]

    enum CodingKeys: String, CodingKey {
        case time
        case uvIndexMax = "uv_index_max"
        case sunrise
        case sunset
    }
}

struct GeocodingResponse: Codable {
    let results: [GeocodingResult]?
}

struct GeocodingResult: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?

    var displayName: String {
        var parts = [name]
        if let admin = admin1 { parts.append(admin) }
        if let country = country { parts.append(country) }
        return parts.joined(separator: ", ")
    }
}
