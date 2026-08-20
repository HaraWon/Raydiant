import Foundation
import SwiftUI

enum MockData {
    static var todayGlowData: TodayGlowData {
        let calendar = Calendar.current
        let now = Date()
        let morning = calendar.date(bySettingHour: 8, minute: 30, second: 0, of: now)!
        let morningEnd = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now)!
        let lateAft = calendar.date(bySettingHour: 16, minute: 15, second: 0, of: now)!
        let lateAftEnd = calendar.date(bySettingHour: 17, minute: 45, second: 0, of: now)!
        let avoidStart = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: now)!
        let avoidEnd = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: now)!
        let photoStart = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: now)!
        let photoEnd = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: now)!

        return TodayGlowData(
            glowScore: 78,
            glowLabel: .peak,
            glowAdvice: "Peak glow day — tan earlier or later, and reapply SPF before direct sun.",
            currentUV: 8.2,
            uvRiskLabel: "Very High",
            hourlyUV: [
                (0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (5, 0.1),
                (6, 0.8), (7, 2.1), (8, 4.5), (9, 6.8), (10, 9.2),
                (11, 10.8), (12, 11.5), (13, 11.1), (14, 9.8), (15, 7.5),
                (16, 5.2), (17, 3.1), (18, 1.4), (19, 0.5), (20, 0), (21, 0), (22, 0), (23, 0)
            ],
            bestTanWindow: TimeWindow(start: morning, end: morningEnd),
            lowerRiskWindow: TimeWindow(start: lateAft, end: lateAftEnd),
            avoidWindow: TimeWindow(start: avoidStart, end: avoidEnd),
            burnRisk: BurnRisk(minMinutes: 20, maxMinutes: 30, label: "High", message: "You may start burning in around 20–30 minutes without protection."),
            hyperpigmentationRisk: .high,
            hyperpigmentationAdvice: "High UV can worsen dark spots. SPF and shade are your best friends today.",
            makeupSurvival: "Risky",
            makeupAdvice: "High humidity and heat — a setting spray and waterproof products are smart today.",
            hairFrizzRisk: "Frizz likely",
            hairFrizzAdvice: "Humidity is elevated. Anti-frizz serum or a protective style will help.",
            sweatinessLevel: "Sweaty",
            sweatinessAdvice: "It'll be warm and humid. Stay hydrated and expect to sweat.",
            beachDayScore: 82,
            beachDayAdvice: "Great beach vibes — but UV is very high. SPF 50+ is non-negotiable.",
            photoWindow: TimeWindow(start: photoStart, end: photoEnd),
            cityName: "Singapore",
            lastUpdated: Date(),
            currentTemp: 31.0,
            currentHumidity: 74,
            currentCloud: 15
        )
    }

    static var forecastData: [DayForecast] {
        let advices = [
            "Peak glow day — tan earlier or later.",
            "Moderate UV. Good day for a balanced glow.",
            "High cloud cover — UV still present.",
            "Lower UV today. Great for sensitive skin.",
            "Extreme UV midday — morning windows only.",
            "Partly cloudy. Softer UV all day.",
            "Good conditions for an early glow session.",
            "Very high UV. SPF is non-negotiable.",
            "Mild UV — a more relaxed tan day.",
            "High humidity — makeup survival is tricky.",
            "Excellent golden-hour photo conditions.",
            "Very high UV. Shade is your friend.",
            "Moderate conditions. Good all-rounder.",
            "Lower UV. Great for a lower-risk tan."
        ]

        return (0..<14).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
            let uv = Double.random(in: 3...12)
            let score = Int.random(in: 45...92)
            let label: GlowLabel = score > 80 ? .peak : score > 60 ? .good : score > 40 ? .soft : .low

            let morning = Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: date)!
            let morningEnd = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: date)!

            return DayForecast(
                date: date,
                maxUV: uv,
                glowScore: score,
                glowLabel: label,
                bestTanWindow: TimeWindow(start: morning, end: morningEnd),
                riskLabel: uv > 8 ? "Very High" : uv > 5 ? "High" : "Moderate",
                advice: advices[offset % advices.count],
                sunrise: Calendar.current.date(bySettingHour: 6, minute: 55, second: 0, of: date),
                sunset: Calendar.current.date(bySettingHour: 19, minute: 5, second: 0, of: date)
            )
        }
    }

    static var friends: [FriendStatus] {
        [
            FriendStatus(name: "Maya", city: "Sydney", status: "Peak Glow window", glowScore: 85, timeAgo: "now", avatarColor: RaydiantColors.pink),
            FriendStatus(name: "Ari", city: "Singapore", status: "Reapplied SPF", glowScore: 78, timeAgo: "20 min ago", avatarColor: RaydiantColors.orange),
            FriendStatus(name: "Jade", city: "London", status: "In shade", glowScore: 32, timeAgo: "1 hr ago", avatarColor: Color.purple),
            FriendStatus(name: "Zoey", city: "LA", status: "Started tanning", glowScore: 91, timeAgo: "45 min ago", avatarColor: Color.teal),
        ]
    }
}
