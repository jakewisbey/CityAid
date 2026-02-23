import SwiftUI
internal import CoreData
import Combine
import AVFoundation

final class UserData: ObservableObject {
    @AppStorage("Username") var username = "Anonymous Contributor"
    @AppStorage("Bio") var bio = "Aiming to make my city a better place, one contribution at a time."
    @AppStorage("Level") var level = 1
    @AppStorage("Experience") var xp = 0
    @AppStorage("Streak") var streak = 1
    @AppStorage("PlayedStreakAnimationToday") var playedStreakAnimation: Bool = false
    @AppStorage("IsStreakCompletedToday") var isStreakCompletedToday: Bool = false
    
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

    var quickLogs: [String: Int] = UserDefaults.standard.object(forKey: "quickLogKey") as? [String: Int] ?? [
        "Litter-Picking": 0,
        "Gave up my seat": 0,
        "Helped with directions": 0,
        "Took someone's trash": 0,
        "Helped an animal": 0,
        "Held a door open": 0
        ]

    
    
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
        while xp >= RequiredXpForLevelUp() {
            level += 1
            xp -= RequiredXpForLevelUp()
        }
        
        // deleting a contribution removes xp, so this is used to calculate the new xp and level
        while xp < 0 && level > 1 {
            level -= 1
            xp += RequiredXpForLevelUp()
        }
    }

    func RequiredXpForLevelUp() -> Int {
        let bracket = level / 10
        let xpNeeded = 15 + bracket * 5
        return min(xpNeeded, 75)
    }
    
    
    // put this in user because user is imported into every file, so i dont have to do this each file. but for larger stuff probably make an AudioManager of some kind
    var audioPlayer: AVAudioPlayer?
    
    func playSound(named name: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error playing sound \(error)")
            }
        }
    }
}
