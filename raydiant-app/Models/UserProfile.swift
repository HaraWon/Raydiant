import Foundation

enum Goal: String, Codable, CaseIterable {
    case tan = "I want to tan"
    case protect = "I want to protect my skin"
    case both = "Both"

    var icon: String {
        switch self {
        case .tan: return "sun.max.fill"
        case .protect: return "shield.fill"
        case .both: return "sparkles"
        }
    }
}

enum SkinTone: String, Codable, CaseIterable {
    case veryFair = "Very fair"
    case fair = "Fair"
    case medium = "Medium"
    case olive = "Olive"
    case tan = "Tan"
    case deep = "Deep"

    var burnFactor: Double {
        switch self {
        case .veryFair: return 1.0
        case .fair: return 0.85
        case .medium: return 0.65
        case .olive: return 0.5
        case .tan: return 0.4
        case .deep: return 0.3
        }
    }

    var emoji: String {
        switch self {
        case .veryFair: return "🏻"
        case .fair: return "🏼"
        case .medium: return "🏽"
        case .olive: return "🏽"
        case .tan: return "🏾"
        case .deep: return "🏿"
        }
    }
}

enum BurnTendency: String, Codable, CaseIterable {
    case rarely = "I rarely burn"
    case sometimes = "I sometimes burn"
    case easily = "I burn easily"

    var multiplier: Double {
        switch self {
        case .rarely: return 1.3
        case .sometimes: return 1.0
        case .easily: return 0.65
        }
    }
}

enum TanningExperience: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case sometimes = "I tan sometimes"
    case often = "I tan often"

    var icon: String {
        switch self {
        case .beginner: return "1.circle.fill"
        case .sometimes: return "2.circle.fill"
        case .often: return "3.circle.fill"
        }
    }
}

enum BeautyConcern: String, Codable, CaseIterable, Hashable {
    case sunburn = "Sunburn"
    case hyperpigmentation = "Hyperpigmentation"
    case unevenTan = "Uneven tan"
    case makeupMelting = "Makeup melting"
    case hairFrizz = "Hair frizz"
    case sweatiness = "Sweatiness"

    var icon: String {
        switch self {
        case .sunburn: return "flame.fill"
        case .hyperpigmentation: return "circle.lefthalf.filled"
        case .unevenTan: return "square.grid.2x2"
        case .makeupMelting: return "drop.fill"
        case .hairFrizz: return "wind"
        case .sweatiness: return "thermometer.medium"
        }
    }
}

struct UserProfile: Codable {
    var goal: Goal = .both
    var skinTone: SkinTone = .medium
    var burnTendency: BurnTendency = .sometimes
    var tanningExperience: TanningExperience = .beginner
    var concerns: [BeautyConcern] = []
    var defaultCity: String = ""
    var defaultLatitude: Double? = nil
    var defaultLongitude: Double? = nil
    var notificationsEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var soundEnabled: Bool = false

    static let `default` = UserProfile()
}
