import Foundation

enum GlowScoreCalculator {

    static func calculate(
        uvIndex: Double,
        cloudCover: Double,
        humidity: Double,
        temperature: Double,
        currentTime: Date,
        sunrise: Date?,
        sunset: Date?
    ) -> Int {
        // UV component: 0–45
        let uvComponent = min(45.0, uvIndex * 4.5)

        // Cloud attenuation: 0% cloud → 1.0, 100% → 0.45
        let cloudFactor = 1.0 - (cloudCover / 100.0) * 0.55
        let attenuatedUV = uvComponent * cloudFactor

        // Time bonus: golden hour = great for photos & comfortable tanning
        let timeBonus = timeOfDayBonus(for: currentTime, sunrise: sunrise, sunset: sunset)

        // Temperature comfort: 0–12
        let tempBonus: Double
        switch temperature {
        case 22..<30: tempBonus = 12.0
        case 18..<22: tempBonus = 7.0
        case 30..<35: tempBonus = 7.0
        case 15..<18: tempBonus = 3.0
        case 35...: tempBonus = 2.0
        default: tempBonus = 0.0
        }

        // Humidity penalty: –8 to 0
        let humidityPenalty: Double
        switch humidity {
        case 85...: humidityPenalty = -8.0
        case 70..<85: humidityPenalty = -4.0
        case 55..<70: humidityPenalty = -1.0
        default: humidityPenalty = 0.0
        }

        let base = 8.0
        let raw = base + attenuatedUV + timeBonus + tempBonus + humidityPenalty
        return max(0, min(100, Int(raw.rounded())))
    }

    static func calculateDaily(maxUV: Double) -> Int {
        let uvComponent = min(50.0, maxUV * 5.0)
        let base = 8.0
        let raw = base + uvComponent
        return max(0, min(100, Int(raw.rounded())))
    }

    private static func timeOfDayBonus(for date: Date, sunrise: Date?, sunset: Date?) -> Double {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: date)
        let minute = cal.component(.minute, from: date)
        let decimalHour = Double(hour) + Double(minute) / 60.0

        if let sunrise = sunrise, let sunset = sunset {
            let srHour = Double(cal.component(.hour, from: sunrise)) + Double(cal.component(.minute, from: sunrise)) / 60.0
            let ssHour = Double(cal.component(.hour, from: sunset)) + Double(cal.component(.minute, from: sunset)) / 60.0

            let goldenMorningEnd = srHour + 2.0
            let goldenEveningStart = ssHour - 2.0

            switch decimalHour {
            case srHour..<goldenMorningEnd: return 22.0
            case goldenMorningEnd..<11.0: return 10.0
            case 11.0..<14.0: return -3.0
            case 14.0..<goldenEveningStart: return 5.0
            case goldenEveningStart...ssHour: return 22.0
            default: return -15.0
            }
        }

        switch hour {
        case 6..<8: return 22.0
        case 8..<11: return 10.0
        case 11..<14: return -3.0
        case 14..<17: return 5.0
        case 17..<20: return 22.0
        default: return -15.0
        }
    }

    static func label(for score: Int, uvIndex: Double) -> GlowLabel {
        if uvIndex >= 11 { return .extreme }
        switch score {
        case 0..<30: return .low
        case 30..<55: return .soft
        case 55..<75: return .good
        case 75..<90: return .peak
        default: return .peak
        }
    }

    static func advice(for score: Int, uvIndex: Double) -> String {
        if uvIndex >= 11 {
            return "Extreme UV today — stay in shade, wear SPF 50+, and protect your skin."
        }
        switch score {
        case 0..<30:
            return "Low glow conditions. Great day for sensitive skin or going bare-faced."
        case 30..<55:
            return "Soft glow day — UV is mild but still present. SPF is always a yes."
        case 55..<75:
            return "Good glow window. A balanced day for tanning — apply SPF and enjoy."
        case 75..<90:
            return "Peak glow day — tan earlier or later, and reapply SPF before direct sun."
        default:
            return "Peak glow day — prime conditions. Stay protected and glow safely."
        }
    }

    static func uvRiskLabel(for uv: Double) -> String {
        switch uv {
        case 0..<1: return "None"
        case 1..<3: return "Low"
        case 3..<6: return "Moderate"
        case 6..<8: return "High"
        case 8..<11: return "Very High"
        default: return "Extreme"
        }
    }

    static func shortAdvice(for uv: Double) -> String {
        switch uv {
        case 0..<3: return "Low UV. Easy day for skin."
        case 3..<6: return "Moderate UV — SPF recommended."
        case 6..<8: return "High UV. Apply SPF 30+ before going out."
        case 8..<11: return "Very high UV — reapply SPF every 2 hours."
        default: return "Extreme UV. Shade and SPF 50+ essential."
        }
    }
}
