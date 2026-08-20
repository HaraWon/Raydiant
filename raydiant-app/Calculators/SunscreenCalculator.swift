import Foundation

enum SunscreenCalculator {

    static func reapplyMinutes(uvIndex: Double, isBeachMode: Bool, isSwimming: Bool) -> Int {
        if isSwimming || isBeachMode {
            return uvIndex >= 8 ? 60 : 80
        }
        if uvIndex >= 10 { return 60 }
        if uvIndex >= 7 { return 90 }
        return 120
    }

    static func reapplyMessage(minutesRemaining: Int, uvIndex: Double) -> String {
        if minutesRemaining <= 0 {
            return "Time to reapply SPF now."
        }
        let hours = minutesRemaining / 60
        let mins = minutesRemaining % 60
        if hours > 0 {
            return "Reapply SPF in \(hours)h \(mins)m"
        }
        return "Reapply SPF in \(mins)m"
    }

    static func urgencyMessage(uvIndex: Double) -> String {
        if uvIndex >= 10 { return "Extreme UV — reapply every hour." }
        if uvIndex >= 7 { return "High UV — every 90 minutes at minimum." }
        return "Reapply every 2 hours, or after swimming."
    }
}
