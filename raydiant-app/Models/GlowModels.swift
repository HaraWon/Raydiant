import Foundation
import SwiftUI

struct TimeWindow {
    let start: Date
    let end: Date

    var formatted: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        fmt.amSymbol = "AM"
        fmt.pmSymbol = "PM"
        return "\(fmt.string(from: start))–\(fmt.string(from: end))"
    }
}

enum GlowLabel: String {
    case low = "Low glow"
    case soft = "Soft glow"
    case good = "Good glow"
    case peak = "Peak glow"
    case extreme = "Extreme UV"

    var color: Color {
        switch self {
        case .low: return .blue
        case .soft: return Color(red: 0.4, green: 0.8, blue: 0.4)
        case .good: return Color(red: 1.0, green: 0.82, blue: 0.2)
        case .peak: return Color(red: 1.0, green: 0.48, blue: 0.18)
        case .extreme: return Color(red: 1.0, green: 0.2, blue: 0.2)
        }
    }
}

enum RiskLevel: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case veryHigh = "Very High"

    var color: Color {
        switch self {
        case .low: return Color(red: 0.3, green: 0.8, blue: 0.4)
        case .medium: return Color(red: 1.0, green: 0.82, blue: 0.2)
        case .high: return Color(red: 1.0, green: 0.5, blue: 0.1)
        case .veryHigh: return Color(red: 1.0, green: 0.2, blue: 0.2)
        }
    }
}

struct BurnRisk {
    let minMinutes: Int
    let maxMinutes: Int
    let label: String
    let message: String

    var rangeText: String { "\(minMinutes)–\(maxMinutes) min" }
}

struct TanWindows {
    let best: TimeWindow?
    let lowerRisk: TimeWindow?
    let avoid: TimeWindow?
}

struct DayForecast: Identifiable {
    let id = UUID()
    let date: Date
    let maxUV: Double
    let glowScore: Int
    let glowLabel: GlowLabel
    let bestTanWindow: TimeWindow?
    let riskLabel: String
    let advice: String
    let sunrise: Date?
    let sunset: Date?
}

struct TodayGlowData {
    let glowScore: Int
    let glowLabel: GlowLabel
    let glowAdvice: String
    let currentUV: Double
    let uvRiskLabel: String
    let hourlyUV: [(hour: Int, uv: Double)]
    let bestTanWindow: TimeWindow?
    let lowerRiskWindow: TimeWindow?
    let avoidWindow: TimeWindow?
    let burnRisk: BurnRisk
    let hyperpigmentationRisk: RiskLevel
    let hyperpigmentationAdvice: String
    let makeupSurvival: String
    let makeupAdvice: String
    let hairFrizzRisk: String
    let hairFrizzAdvice: String
    let sweatinessLevel: String
    let sweatinessAdvice: String
    let beachDayScore: Int
    let beachDayAdvice: String
    let photoWindow: TimeWindow?
    let cityName: String
    let lastUpdated: Date
    let currentTemp: Double
    let currentHumidity: Int
    let currentCloud: Int
}

struct FriendStatus: Identifiable {
    let id = UUID()
    let name: String
    let city: String
    let status: String
    let glowScore: Int
    let timeAgo: String
    let avatarColor: Color
}

struct TanPlanResult {
    let goalLabel: String
    let bestTime: String
    let bestDay: String
    let whatToBring: [String]
    let riskWarning: String
    let spfAdvice: String
    let bodyCopy: String
}
