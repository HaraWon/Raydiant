import Foundation

enum TanWindowCalculator {

    struct Result {
        let best: TimeWindow?
        let lowerRisk: TimeWindow?
        let avoid: TimeWindow?
    }

    static func calculate(
        hourlyUV: [(hour: Int, uv: Double)],
        sunrise: Date?,
        sunset: Date?,
        profile: UserProfile
    ) -> Result {
        let calendar = Calendar.current
        let now = Date()

        // Find avoid window: UV >= 8, consecutive hours
        let peakHours = hourlyUV.filter { $0.uv >= 8 }
        let avoidWindow = consecutiveWindow(from: peakHours, referenceDate: now, calendar: calendar)

        // Best tan window: UV 4–8, prefer morning, not peak
        let bestHours = hourlyUV.filter { $0.uv >= 3.5 && $0.uv < 8 }
        let morningBest = bestHours.filter { $0.hour < 12 }
        let afternoonBest = bestHours.filter { $0.hour >= 15 }

        let bestWindow: TimeWindow?
        if !morningBest.isEmpty {
            bestWindow = makeWindow(from: morningBest, maxDuration: 90, referenceDate: now, calendar: calendar)
        } else if !afternoonBest.isEmpty {
            bestWindow = makeWindow(from: afternoonBest, maxDuration: 90, referenceDate: now, calendar: calendar)
        } else {
            bestWindow = makeWindow(from: bestHours, maxDuration: 90, referenceDate: now, calendar: calendar)
        }

        // Lower-risk window: UV 2–5, early morning or late afternoon
        let lowerRiskHours = hourlyUV.filter { $0.uv >= 1.5 && $0.uv < 5 }
        let earlyMorning = lowerRiskHours.filter { $0.hour < 10 }
        let lateAfternoon = lowerRiskHours.filter { $0.hour >= 16 }

        let lowerRiskWindow: TimeWindow?
        if !lateAfternoon.isEmpty {
            lowerRiskWindow = makeWindow(from: lateAfternoon, maxDuration: 90, referenceDate: now, calendar: calendar)
        } else if !earlyMorning.isEmpty {
            lowerRiskWindow = makeWindow(from: earlyMorning, maxDuration: 90, referenceDate: now, calendar: calendar)
        } else {
            lowerRiskWindow = nil
        }

        return Result(best: bestWindow, lowerRisk: lowerRiskWindow, avoid: avoidWindow)
    }

    static func photoWindow(sunrise: Date?, sunset: Date?) -> TimeWindow? {
        guard let sunset = sunset else { return nil }
        let calendar = Calendar.current
        guard let goldenStart = calendar.date(byAdding: .minute, value: -90, to: sunset),
              let goldenEnd = calendar.date(byAdding: .minute, value: 20, to: sunset)
        else { return nil }
        return TimeWindow(start: goldenStart, end: goldenEnd)
    }

    private static func makeWindow(
        from hours: [(hour: Int, uv: Double)],
        maxDuration: Int,
        referenceDate: Date,
        calendar: Calendar
    ) -> TimeWindow? {
        guard !hours.isEmpty else { return nil }
        let sorted = hours.sorted { $0.hour < $1.hour }

        // Find best consecutive block
        var bestStart = sorted.first!.hour
        var bestEnd = bestStart + 1
        var curStart = bestStart
        var curEnd = bestEnd

        for i in 1..<sorted.count {
            if sorted[i].hour == sorted[i-1].hour + 1 {
                curEnd = sorted[i].hour + 1
            } else {
                if curEnd - curStart > bestEnd - bestStart {
                    bestStart = curStart
                    bestEnd = curEnd
                }
                curStart = sorted[i].hour
                curEnd = curStart + 1
            }
        }
        if curEnd - curStart > bestEnd - bestStart {
            bestStart = curStart
            bestEnd = curEnd
        }

        // Cap duration
        let durationHours = min(maxDuration / 60, bestEnd - bestStart)
        let finalEnd = bestStart + durationHours

        guard let start = calendar.date(bySettingHour: bestStart, minute: 30, second: 0, of: referenceDate),
              let end = calendar.date(bySettingHour: finalEnd, minute: 0, second: 0, of: referenceDate)
        else { return nil }

        return TimeWindow(start: start, end: end)
    }

    private static func consecutiveWindow(
        from hours: [(hour: Int, uv: Double)],
        referenceDate: Date,
        calendar: Calendar
    ) -> TimeWindow? {
        guard !hours.isEmpty else { return nil }
        let sorted = hours.sorted { $0.hour < $1.hour }

        guard let start = calendar.date(bySettingHour: sorted.first!.hour, minute: 0, second: 0, of: referenceDate),
              let end = calendar.date(bySettingHour: sorted.last!.hour + 1, minute: 0, second: 0, of: referenceDate)
        else { return nil }

        return TimeWindow(start: start, end: end)
    }
}
