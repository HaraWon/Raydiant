import Foundation

enum BeautyIndexCalculator {

    // MARK: – Hyperpigmentation

    static func hyperpigmentationRisk(uvIndex: Double, profile: UserProfile) -> RiskLevel {
        // Higher risk for olive/medium tones with UV exposure
        let skinSensitivity: Double
        switch profile.skinTone {
        case .veryFair, .fair: skinSensitivity = 0.6
        case .medium, .olive: skinSensitivity = 1.0
        case .tan, .deep: skinSensitivity = 0.8
        }

        let concernBonus: Double = profile.concerns.contains(.hyperpigmentation) ? 1.5 : 1.0
        let riskScore = uvIndex * skinSensitivity * concernBonus

        switch riskScore {
        case 0..<4: return .low
        case 4..<8: return .medium
        case 8..<12: return .high
        default: return .veryHigh
        }
    }

    static func hyperpigmentationAdvice(risk: RiskLevel) -> String {
        switch risk {
        case .low: return "UV is manageable today. SPF still helps prevent long-term dark spots."
        case .medium: return "Moderate hyperpigmentation risk. SPF 30+ and avoiding peak UV hours is wise."
        case .high: return "High UV can worsen dark spots. SPF and shade are your best friends today."
        case .veryHigh: return "Very high risk for hyperpigmentation today. SPF 50+, hat, and shade — especially during peak UV."
        }
    }

    // MARK: – Makeup Survival

    static func makeupSurvival(humidity: Double, temperature: Double) -> String {
        let stressScore = (humidity / 10.0) + (temperature / 5.0)
        switch stressScore {
        case 0..<10: return "Fresh"
        case 10..<16: return "Fine"
        case 16..<21: return "Risky"
        default: return "Meltdown alert"
        }
    }

    static func makeupAdvice(survival: String) -> String {
        switch survival {
        case "Fresh": return "Great conditions for makeup. Light coverage is all you need today."
        case "Fine": return "Makeup should hold up fine. A setting spray is a nice touch."
        case "Risky": return "High humidity and heat — a setting spray and waterproof products are smart today."
        default: return "Meltdown conditions. Go minimal, waterproof, or embrace the bare-skin glow."
        }
    }

    // MARK: – Hair Frizz

    static func hairFrizz(humidity: Double) -> String {
        switch humidity {
        case 0..<50: return "Smooth"
        case 50..<65: return "Slight frizz"
        case 65..<80: return "Frizz likely"
        default: return "High frizz day"
        }
    }

    static func hairFrizzAdvice(risk: String) -> String {
        switch risk {
        case "Smooth": return "Low humidity — great hair day. No extra products needed."
        case "Slight frizz": return "Mild frizz risk. A light serum or leave-in will keep things smooth."
        case "Frizz likely": return "Humidity is elevated. Anti-frizz serum or a protective style will help."
        default: return "High frizz day. Braids, a bun, or heavy anti-frizz cream are your best bets."
        }
    }

    // MARK: – Sweatiness

    static func sweatiness(temperature: Double, humidity: Double) -> String {
        let heatIndex = temperature + (humidity - 40) * 0.15
        switch heatIndex {
        case 0..<24: return "Comfortable"
        case 24..<30: return "Warm"
        case 30..<37: return "Sweaty"
        default: return "Sticky"
        }
    }

    static func sweatinessAdvice(level: String) -> String {
        switch level {
        case "Comfortable": return "Comfortable conditions — enjoy the outdoors."
        case "Warm": return "Warm but manageable. Light layers and water will keep you going."
        case "Sweaty": return "It'll be warm and humid. Stay hydrated and expect to sweat."
        default: return "Very sticky conditions. Minimal layers, cold water, and regular shade breaks."
        }
    }

    // MARK: – Beach Day Score

    static func beachDayScore(uvIndex: Double, cloudCover: Double, temperature: Double, humidity: Double) -> Int {
        // Good beach day = warm, some UV, not too cloudy, not dangerously humid
        let tempScore = temperature >= 26 && temperature <= 34 ? 30.0 : temperature >= 22 ? 15.0 : 5.0
        let uvScore = uvIndex >= 4 && uvIndex <= 9 ? 30.0 : uvIndex > 1 ? 15.0 : 5.0
        let cloudScore = (1.0 - cloudCover / 100.0) * 25.0
        let humidityPenalty = humidity > 80 ? -10.0 : humidity > 70 ? -5.0 : 0.0

        let raw = tempScore + uvScore + cloudScore + humidityPenalty + 5.0
        return max(0, min(100, Int(raw)))
    }

    static func beachAdvice(score: Int, uvIndex: Double) -> String {
        if uvIndex >= 10 {
            return "Beach conditions are there, but UV is very high. SPF 50+ is non-negotiable."
        }
        switch score {
        case 0..<40: return "Not ideal beach conditions today — consider a different activity."
        case 40..<60: return "Decent beach day. Bring SPF and some shade."
        case 60..<80: return "Good beach conditions. Apply SPF 30+ and stay hydrated."
        default: return "Great beach vibes — UV is there too. SPF 50+ and regular shade breaks."
        }
    }
}
