import SwiftUI

// MVP: local-only prototype. Structured so Firebase/Supabase can be wired in later.
// Replace MockFriendsStore with a real backend service when ready.

enum TanningStatus: String, CaseIterable {
    case started = "Started tanning"
    case appliedSPF = "Applied SPF"
    case inShade = "In shade"
    case stopped = "Stopped tanning"

    var icon: String {
        switch self {
        case .started: return "sun.max.fill"
        case .appliedSPF: return "drop.fill"
        case .inShade: return "umbrella.fill"
        case .stopped: return "moon.fill"
        }
    }

    var color: Color {
        switch self {
        case .started: return RaydiantColors.yellow
        case .appliedSPF: return RaydiantColors.pink
        case .inShade: return .blue
        case .stopped: return .gray
        }
    }
}

struct FriendsView: View {
    @EnvironmentObject var appState: AppState
    @State private var myStatus: TanningStatus? = nil
    @State private var showStatusPicker = false
    @State private var showAddFriend = false

    private let friends = MockData.friends

    var body: some View {
        ZStack {
            GradientBackground(uvIndex: 5, animated: false)

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Friends")
                                .font(RaydiantFonts.rounded(28, weight: .bold))
                                .foregroundStyle(.white)
                            Text("See what your crew is doing")
                                .font(RaydiantFonts.rounded(14)).foregroundStyle(.white.opacity(0.65))
                        }
                        Spacer()
                        Button { showAddFriend = true } label: {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    // MVP notice
                    GlassCard(padding: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(RaydiantColors.yellow)
                            Text("Friends is in MVP preview — real accounts and sync coming soon.")
                                .font(RaydiantFonts.rounded(12))
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    }
                    .padding(.horizontal, 20)

                    // My Status Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Label("My Status", systemImage: "person.fill")
                                    .font(RaydiantFonts.rounded(14, weight: .semibold))
                                    .foregroundStyle(.white)
                                Spacer()
                                if let data = appState.todayData {
                                    SmallScoreRing(score: data.glowScore, size: 38, lineWidth: 4)
                                }
                            }

                            if let status = myStatus {
                                HStack(spacing: 8) {
                                    Image(systemName: status.icon)
                                        .foregroundStyle(status.color)
                                    Text(status.rawValue)
                                        .font(RaydiantFonts.rounded(15, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }

                            Button {
                                if appState.userProfile.hapticsEnabled { HapticService.light() }
                                showStatusPicker = true
                            } label: {
                                Text(myStatus == nil ? "Set your status" : "Update status")
                                    .font(RaydiantFonts.rounded(14, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 11)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(LinearGradient(colors: [RaydiantColors.pink, RaydiantColors.orange], startPoint: .leading, endPoint: .trailing))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // City comparison (mock)
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Glow Scores by City", systemImage: "map.fill")
                                .font(RaydiantFonts.rounded(14, weight: .semibold))
                                .foregroundStyle(.white)

                            VStack(spacing: 10) {
                                ForEach(cityComparisons, id: \.city) { item in
                                    HStack {
                                        Text(item.city)
                                            .font(RaydiantFonts.rounded(14, weight: .medium))
                                            .foregroundStyle(.white)
                                            .frame(width: 90, alignment: .leading)
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.white.opacity(0.15))
                                                    .frame(height: 8)
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(LinearGradient(colors: [RaydiantColors.yellow, RaydiantColors.orange], startPoint: .leading, endPoint: .trailing))
                                                    .frame(width: geo.size.width * Double(item.score) / 100.0, height: 8)
                                            }
                                        }
                                        .frame(height: 8)
                                        Text("\(item.score)")
                                            .font(RaydiantFonts.rounded(13, weight: .bold))
                                            .foregroundStyle(.white)
                                            .frame(width: 32, alignment: .trailing)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Friend feed
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Friend activity")
                            .font(RaydiantFonts.rounded(16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal, 20)

                        ForEach(friends) { friend in
                            friendCard(friend: friend)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showStatusPicker) {
            statusPickerSheet
        }
        .sheet(isPresented: $showAddFriend) {
            addFriendSheet
        }
    }

    func friendCard(friend: FriendStatus) -> some View {
        GlassCard(cornerRadius: 18, padding: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(friend.avatarColor.opacity(0.7))
                        .frame(width: 44, height: 44)
                    Text(String(friend.name.prefix(1)))
                        .font(RaydiantFonts.rounded(20, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(friend.name)
                            .font(RaydiantFonts.rounded(15, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("·")
                            .foregroundStyle(.white.opacity(0.4))
                        Text(friend.city)
                            .font(RaydiantFonts.rounded(13))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Text(friend.status)
                        .font(RaydiantFonts.rounded(13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                    Text(friend.timeAgo)
                        .font(RaydiantFonts.rounded(11))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Spacer()
                SmallScoreRing(score: friend.glowScore, size: 40, lineWidth: 4)
            }
        }
        .padding(.horizontal, 20)
    }

    var cityComparisons: [(city: String, score: Int)] {
        let myScore = appState.todayData?.glowScore ?? 70
        let city = appState.cityName.isEmpty ? "Your city" : appState.cityName
        return [
            (city: city, score: myScore),
            (city: "Sydney", score: 85),
            (city: "London", score: 32),
            (city: "LA", score: 91),
            (city: "Bangkok", score: 77),
        ].sorted { $0.score > $1.score }
    }

    var statusPickerSheet: some View {
        ZStack {
            GradientBackground(uvIndex: 5, animated: false)
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                Text("What are you up to?")
                    .font(RaydiantFonts.rounded(22, weight: .bold))
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    ForEach(TanningStatus.allCases, id: \.self) { status in
                        Button {
                            myStatus = status
                            if appState.userProfile.hapticsEnabled { HapticService.success() }
                            showStatusPicker = false
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: status.icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(status.color)
                                    .frame(width: 30)
                                Text(status.rawValue)
                                    .font(RaydiantFonts.rounded(16, weight: .semibold))
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding(.horizontal, 24)
                Spacer()
            }
        }
        .presentationDetents([.medium])
    }

    var addFriendSheet: some View {
        ZStack {
            GradientBackground(uvIndex: 4, animated: false)
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                Image(systemName: "person.badge.plus")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.7))

                VStack(spacing: 8) {
                    Text("Add Friends")
                        .font(RaydiantFonts.rounded(22, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Friend accounts and sharing are coming in the next update. Stay tuned.")
                        .font(RaydiantFonts.rounded(14))
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                Spacer()
            }
        }
        .presentationDetents([.medium])
    }
}
