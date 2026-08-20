import SwiftUI
import Foundation

extension Date {
    var hourInt: Int { Calendar.current.component(.hour, from: self) }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    var dayLabel: String {
        if Calendar.current.isDateInToday(self) { return "Today" }
        if Calendar.current.isDateInTomorrow(self) { return "Tomorrow" }
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE, MMM d"
        return fmt.string(from: self)
    }

    var shortDayLabel: String {
        if Calendar.current.isDateInToday(self) { return "Today" }
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE d"
        return fmt.string(from: self)
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }

    var uvRiskColor: Color {
        switch self {
        case 0..<3: return Color(red: 0.3, green: 0.8, blue: 0.4)
        case 3..<6: return Color(red: 1.0, green: 0.82, blue: 0.2)
        case 6..<8: return Color(red: 1.0, green: 0.55, blue: 0.1)
        case 8..<11: return Color(red: 1.0, green: 0.2, blue: 0.2)
        default: return Color(red: 0.7, green: 0.0, blue: 0.5)
        }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
    }

    func raydiantCardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
    }
}

extension LinearGradient {
    static var raydiant: LinearGradient {
        LinearGradient(
            colors: [RaydiantColors.pink, RaydiantColors.orange, RaydiantColors.yellow],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
