import SwiftUI
internal import CoreData

class ChallengeManager {
    var user: UserData
    
    init(user: UserData) {
        self.user = user
    }
    
    func rerollDailyChallenge() {
        let newChallenge = Challenge.createChallenge(.daily, nil, user.selectedChallengeContributionTypes)
        user.dailyChallenge = newChallenge
        if let encoded = try? JSONEncoder().encode(newChallenge) {
            user.dailyData = encoded
        }
    }
    
    func rerollWeeklyChallenges() {
        var disallowed1: [TypeOfContribution] = []
        var disallowed2: [TypeOfContribution] = []
        
        let c1 = Challenge.createChallenge(.weekly, nil, user.selectedChallengeContributionTypes)
        if (user.selectedChallengeContributionTypes.count >= 3) {
            disallowed1 = c1.contributionType.map { [$0] } ?? []
        }
        
        let c2 = Challenge.createChallenge(.weekly, disallowed1, user.selectedChallengeContributionTypes)
        if (user.selectedChallengeContributionTypes.count >= 3) {
            disallowed2 = [c1, c2].compactMap { $0.contributionType }
        }
        
        let c3 = Challenge.createChallenge(.weekly, disallowed2, user.selectedChallengeContributionTypes)

        
        
        let newWeekly = [c1, c2, c3]
        user.weeklyChallenges = newWeekly
        if let encoded = try? JSONEncoder().encode(newWeekly) {
            user.weeklyData = encoded
        }
    }
    
    func rerollChallenges() {
        rerollDailyChallenge()
        rerollWeeklyChallenges()
    }
    
    func nextDailyReset() -> Date {
        Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        )!
    }
    
    func nextWeeklyReset() -> Date {
        Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0, weekday: 2),
            matchingPolicy: .nextTime
        )!
    }
    
    func calculateTimeInterval(nextReset: Date) -> String {
        let timeInterval = nextReset.timeIntervalSinceNow
        
        let days = Int(timeInterval) / 86_400
        let hours = (Int(timeInterval) % 86_400) / 3_600
        let minutes = (Int(timeInterval) % 3_600) / 60
        
        if days == 0 { return "\(hours)h \(minutes)min"} else {
            return "\(days)d \(hours)h \(minutes)min"
        }
    }

    func calculateChallengeProgress(_ typeOfChallenge: TypeOfChallenge, _ target: Int, _ typeOfContribution: TypeOfContribution?, date: Date = Date(), _ contributions: FetchedResults<ContributionEntity>) -> (Int, Bool) {
        let cal = Calendar.current
        
        switch typeOfChallenge {
        case .daily:
            // lets me change what date to use so i can reuse for the adding total daily contributions stuff
            let startDate = cal.startOfDay(for: date)
            let endDate = cal.date(byAdding: .day, value: 1, to: startDate)!
            var acceptedContributions = contributions.filter { ($0.date ?? .distantPast) >= startDate && ($0.date ?? .distantPast) < endDate }
            if let type = typeOfContribution?.rawValue {
                acceptedContributions = acceptedContributions.filter { $0.type == type }
            }
            
            let count = acceptedContributions.count
            let isCompleted = count >= target
            
            return (count, isCompleted)
            
        case .weekly:
            // same here as above but for weekly
            let monday = cal.nextDate(
                after: date,
                matching: DateComponents(hour: 0, minute: 0, weekday: 2),
                matchingPolicy: .nextTime,
                direction: .backward
            )!
            let startDate = cal.startOfDay(for: monday)
            let endDate = cal.date(byAdding: .day, value: 7, to: startDate)!
            var acceptedContributions = contributions.filter { ($0.date ?? .distantPast) >= startDate && ($0.date ?? .distantPast) < endDate }
            if let type = typeOfContribution?.rawValue {
                acceptedContributions = acceptedContributions.filter { $0.type == type }
            }
            
            let count = acceptedContributions.count
            let isCompleted = count >= target

            return (count, isCompleted)
            
        case .milestone:
            return (0, false)
        }
    }
        
    func handleDailyReset() {
        let now = Date()
        let cal = Calendar.current
        
        let lastReset = UserDefaults.standard.object(
            forKey: ResetKey.daily
        ) as? Date ?? .distantPast
        
        if !cal.isDate(lastReset, inSameDayAs: now) {
            rerollDailyChallenge()
            UserDefaults.standard.set(now, forKey: ResetKey.daily)
            
            if (!user.isStreakCompletedToday) { user.streak = 0 }
            
            user.isStreakCompletedToday = false
            user.playedStreakAnimation = false
        }
    }
    
    func handleWeeklyReset() {
        let now = Date()
        let cal = Calendar.current

        let lastReset = UserDefaults.standard.object(
            forKey: ResetKey.weekly
        ) as? Date ?? .distantPast
        
        let lastWeek = cal.component(.weekOfYear, from: lastReset)
        let thisWeek = cal.component(.weekOfYear, from: now)
        
        if lastWeek != thisWeek {
            for _ in user.weeklyChallenges {
                // Evaluate the previous week by passing a date from last week
                let thisMonday = cal.nextDate(
                    after: now,
                    matching: DateComponents(hour: 0, minute: 0, weekday: 2),
                    matchingPolicy: .nextTime,
                    direction: .backward
                )!
            }
            
            rerollWeeklyChallenges()
            UserDefaults.standard.set(now, forKey: ResetKey.weekly)
        }
    }
}
