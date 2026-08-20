import Foundation

enum BurnRiskCalculator {

    // MED (Minimal Erythemal Dose) in kJ/m² by skin tone approximation
    private static func baseMED(for profile: UserProfile) -> Double {
        let skinBase: Double
        switch profile.skinTone {
        case .veryFair: skinBase = 15.0
        case .fair: skinBase = 20.0
        case .medium: skinBase = 30.0
        case .olive: skinBase = 40.0
        case .tan: skinBase = 55.0
        case .deep: skinBase = 70.0
        }
        return skinBase * profile.burnTendency.multiplier
    }

    // Simplified: assume UV index ≈ 0.025 W/m² per unit, 1 MED ≈ 200 J/m²
    static func calculate(uvIndex: Double, profile: UserProfile) -> BurnRisk {
        guard uvIndex > 0 else {
            return BurnRisk(
                minMinutes: 999,
                maxMinutes: 999,
                label: "None",
                message: "No UV right now — no burn risk."
            )
        }

        let med = baseMED(for: profile)
        // Approximate: burn time in minutes = MED / (UV * 0.0025)
        let rawMinutes = med / (uvIndex * 0.0025)

        // Experience gives small extra protection factor
        let experienceFactor: Double
        switch profile.tanningExperience {
        case .beginner: experienceFactor = 0.9
        case .sometimes: experienceFactor = 1.0
        case .often: experienceFactor = 1.15
        }

        let bestCase = Int(rawMinutes * experienceFactor)
        let worstCase = Int(rawMinutes * experienceFactor * 0.75)

        let minVal = min(bestCase, worstCase)
        let maxVal = max(bestCase, worstCase)
        let clampedMin = max(5, minVal)
        let clampedMax = max(clampedMin + 5, maxVal)

        let label: String
        switch clampedMin {
        case 0..<15: label = "High"
        case 15..<30: label = "Moderate"
        case 30..<60: label = "Low"
        default: label = "Very Low"
        }

        let message = message(forMin: clampedMin, uvIndex: uvIndex)
        return BurnRisk(minMinutes: clampedMin, maxMinutes: clampedMax, label: label, message: message)
    }

    private static func message(forMin minutes: Int, uvIndex: Double) -> String {
        if minutes < 15 {
            return "UV is strong today — you may start burning in under 15 minutes without protection. SPF 50+ and shade are essential."
        } else if minutes < 30 {
            return "You may start burning in around \(minutes)–\(minutes + 10) minutes without protection. Raydiant gives estimates, not medical advice."
        } else if minutes < 60 {
            return "Lower burn risk today, but UV can still damage skin. Apply SPF and seek shade when UV peaks."
        } else {
            return "Burn risk is low, but UV can damage skin even on cloudy days. SPF is always a good call."
        }
    }
}
