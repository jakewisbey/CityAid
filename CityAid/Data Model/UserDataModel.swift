import SwiftUI
internal import CoreData
import Combine

final class UserData: ObservableObject {
    @AppStorage("Username") var username = "Anonymous Contributor"
    @AppStorage("Bio") var bio = "Aiming to make my city a better place, one contribution at a time."
    @AppStorage("Level") var level = 1
    @AppStorage("Experience") var xp = 0
    @AppStorage("Streak") var streak = 1
    @AppStorage("PlayedStreakAnimationToday") var playedStreakAnimation: Bool = false
    @AppStorage("IsStreakCompletedToday") var isStreakCompletedToday: Bool = false
    @AppStorage("Target") var target = 4
    
    @AppStorage("HasOpenedBefore") var hasOpenedBefore: Bool = false
    
    @AppStorage("SelectedChallengeContributionTypes") private var selectedChallengeContributionTypesData: Data = Data()
    @Published var selectedChallengeContributionTypes: [TypeOfContribution] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(selectedChallengeContributionTypes) {
                selectedChallengeContributionTypesData = encoded
            }
        }
    }
    
    @AppStorage("DailyChallengesCompleted") var dailyChallengesCompleted = 0
    
    @AppStorage("WeeklyChallengesCompleted") var weeklyChallengesCompleted = 0
    
    @AppStorage("CurrentDailyChallenge") var dailyData: Data = Data()
    @AppStorage("CurrentWeeklyChallenges") var weeklyData: Data = Data()
    
    @Published var dailyChallenge: Challenge = Challenge(id: UUID(), title: "", type: .daily, contributionType: nil, target: 1, xp: 0, xpRewarded: false, iconPath: "") {
        didSet {
            if let encoded = try? JSONEncoder().encode(dailyChallenge) {
                dailyData = encoded
            }
        }
    }
    
    @Published var weeklyChallenges: [Challenge] = []{
        didSet {
            if let encoded = try? JSONEncoder().encode(weeklyChallenges) {
                weeklyData = encoded
            }
        }
    }
    
    init() {
        if let saved = try? JSONDecoder().decode(Challenge.self, from: dailyData) {
            dailyChallenge = saved
        } else {
            dailyChallenge = Challenge.createChallenge(.daily, nil, selectedChallengeContributionTypes)
            if let encoded = try? JSONEncoder().encode(dailyChallenge) {
                dailyData = encoded
            }
        }

        if let saved = try? JSONDecoder().decode([Challenge].self, from: weeklyData) {
            weeklyChallenges = saved
        } else {
            let initial = [
                Challenge.createChallenge(.weekly, nil, selectedChallengeContributionTypes),
                Challenge.createChallenge(.weekly, nil, selectedChallengeContributionTypes),
                Challenge.createChallenge(.weekly, nil, selectedChallengeContributionTypes)
            ]
            weeklyChallenges = initial
            if let encoded = try? JSONEncoder().encode(initial) {
                weeklyData = encoded
            }
        }
        
        if let decoded = try? JSONDecoder().decode([TypeOfContribution].self, from: selectedChallengeContributionTypesData) {
            selectedChallengeContributionTypes = decoded
        } else {
            selectedChallengeContributionTypes = [.cleanliness, .plantcare, .kindness, .donation]
            if let encoded = try? JSONEncoder().encode(selectedChallengeContributionTypes) {
                selectedChallengeContributionTypesData = encoded
            }
        }
    }
    
    func CalculateUserLevel() {
        if xp >= RequiredXpForLevelUp() {
            level += 1
            xp -= RequiredXpForLevelUp()
        }
    }

    func RequiredXpForLevelUp() -> Int {
        let bracket = level / 10
        let xpNeeded = 15 + bracket * 5
        return min(xpNeeded, 75)
    }
}

