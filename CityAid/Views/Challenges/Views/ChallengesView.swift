import SwiftUI
internal import CoreData
import Combine

// MARK: - ChallengesView
struct ChallengesView: View {
    // User, contributions and managers
    @EnvironmentObject var user: UserData
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ContributionEntity.date, ascending: false)]
    ) private var contributions: FetchedResults<ContributionEntity>

    var challengeManager: ChallengeManager {
        ChallengeManager(user: user)
    }
    
    // Popovers
    @State private var isShowingDailyPopover: Bool = false
    @State private var isShowingWeeklyPopover: Bool = false
    @State private var isShowingMilestonesPopover: Bool = false
    
    // Animation handling
    @State private var viewport: CGRect = .zero
    @State private var pulse1: Bool = false
    @State private var pulse2: Bool = true
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    @Binding public var selectedLevelCard: UUID
    @State private var levelCardFrames: [UUID: CGRect] = [:]
    
    @Binding public var selectedTotalContributionCard: UUID
    @State private var totalContributionCardFrames: [UUID: CGRect] = [:]

    @State private var selectedMilestoneType: Int = 0
    
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Challenges")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text("Daily")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .frame(width: 25, height: 25)
                        .glassEffect(.clear.interactive())
                        .onTapGesture {
                            self.isShowingDailyPopover = true
                        }
                        .popover(
                            isPresented: $isShowingDailyPopover, arrowEdge: .top
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Daily Challenges")
                                    .font(.system(size: 26, weight: .bold))
                                Text("Daily challenges encourage you to contribution to your community at least one time a day.\n\nComplete a challenge each day to keep your daily streak!")
                            }
                            .presentationCompactAdaptation(horizontal: .popover, vertical: .sheet)
                            .padding()
                            .frame(width: 340, height: 210)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                        Text("⏳")
                            .font(.system(size: 14, weight: .regular))
                            .scaleEffect(pulse1 ? 1.1 : 1)
                            .animation(.interpolatingSpring(stiffness: 150, damping: 10), value: pulse1)
                            .padding(.trailing, -5)
                            .onReceive(timer) { _ in
                                withAnimation {
                                    pulse1 = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation {
                                        pulse1 = false
                                    }
                                }
                            }
                    
                    
                    Text((challengeManager.calculateTimeInterval(nextReset: challengeManager.nextDailyReset())))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.gray.opacity(0.9))
                        .contentTransition(.numericText())
                    
                    Image(systemName: "dice")
                        .frame(width: 40, height: 40)
                        .glassEffect(.clear.interactive().tint(.blue))
                        .onTapGesture {
                            challengeManager.rerollChallenges()
                        }
                        
                     
                }
                .frame(maxWidth: .infinity)
                
                DailyChallengeCard(user: user, contributions: contributions)
                Spacer()
                
                HStack {
                    Text("Weekly")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)

                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .frame(width: 25, height: 25)
                        .glassEffect(.clear.interactive())
                        .onTapGesture {
                            self.isShowingWeeklyPopover = true
                        }
                        .popover(
                            isPresented: $isShowingWeeklyPopover, arrowEdge: .top
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Weekly Challenges")
                                    .font(.system(size: 26, weight: .bold))
                                Text("Weekly challenges are harder, but more rewarding than daily challenges, designed to encourage you to contribute even more to your community.\n\nTry to complete all 3 each week to earn extra xp!")
                            }
                            .presentationCompactAdaptation(horizontal: .popover, vertical: .sheet)
                            .padding()
                            .frame(width: 340, height: 250)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text("⏳")
                        .font(.system(size: 14, weight: .regular))
                        .scaleEffect(pulse2 ? 1.1 : 1)
                        .animation(.interpolatingSpring(stiffness: 150, damping: 10), value: pulse2)
                        .padding(.trailing, -5)
                        .onReceive(timer) { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation {
                                    pulse2 = true
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    pulse2 = false
                                }
                            }
                        }

                    Text(challengeManager.calculateTimeInterval(nextReset: challengeManager.nextWeeklyReset()))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.gray.opacity(0.9))
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    ForEach(user.weeklyChallenges, id: \.id) { challenge in
                        WeeklyChallengeCard(challenge: challenge, progress: challengeManager.calculateChallengeProgress(.weekly, challenge.target, challenge.contributionType, contributions))
                    }
                }
                Spacer()
                
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            Text("Milestones")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(alignment: .leading)

                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                                .frame(width: 25, height: 25)
                                .glassEffect(.clear.interactive())
                                .onTapGesture {
                                    self.isShowingMilestonesPopover = true
                                }
                                .popover(
                                    isPresented: $isShowingMilestonesPopover, arrowEdge: .bottom
                                ) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Milestones")
                                            .font(.system(size: 26, weight: .bold))
                                        Text("Milestones are a great way to celebrate your achievements, split up into user level and total contributions.\n\nEach milestone awards you with a unique badge!")
                                    }
                                    .presentationCompactAdaptation(horizontal: .popover, vertical: .sheet)
                                    .padding()
                                    .frame(width: 340, height: 210)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                        }
                        let options = ["User Level", "Contributions"]
                        
                        Picker("", selection: $selectedMilestoneType) {
                            ForEach(0..<options.count, id: \.self) { index in
                                Text(options[index]).tag(index)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 300)
                        .padding(.leading, 35)
                                            
                        Spacer()
                        
                        ZStack {
                            GeometryReader { proxy in
                                let horizontalPadding = max((proxy.size.width - 200) / 2, 0)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(levelMilestones) { milestone in
                                            LevelMilestoneCard(id: milestone.id, milestone: milestone, title: milestone.title, caption: milestone.description, badge: milestone.badgePath, selectedLevelCard: selectedLevelCard, user: user)
                                            }
                                    }
                                    .scrollTargetLayout()
                                    .padding(.trailing, horizontalPadding)
                                }
                                .scrollTargetBehavior(.viewAligned)
                                .coordinateSpace(name: "levelCardScroll")
                                .overlay(
                                    GeometryReader { scrollProxy in
                                        Color.clear
                                            .onAppear {
                                                let rect = scrollProxy.frame(in: .named("levelCardScroll"))
                                                viewport = rect
                                            }
                                            .onChange(of: scrollProxy.size) { _, _ in
                                                let rect = scrollProxy.frame(in: .named("levelCardScroll"))
                                                viewport = rect
                                            }
                                    }
                                    .allowsHitTesting(false)
                                )
                            }
                            .zIndex(selectedMilestoneType == 0 ? 1 : -1)
                            .scaleEffect(selectedMilestoneType == 0 ? 1 : 0.7)
                            .opacity(selectedMilestoneType == 0 ? 1 : 0)
                            .animation(.spring(duration: 0.3), value: selectedMilestoneType)
                            .padding(.top, 12)
                            .onPreferenceChange(LevelCardFramesKey.self) { frames in
                                levelCardFrames = frames
                                updateSelectedLevelCardByCenter()
                            }

                            
                            GeometryReader { proxy in
                                let horizontalPadding = max((proxy.size.width - 200) / 2, 0)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(totalContributionMilestones) { milestone in
                                            TotalContributionMilestoneCard(id: milestone.id, milestone: milestone, title: milestone.title, caption: milestone.description, selectedTotalContributionCard: selectedTotalContributionCard, contributions: contributions)
                                            }
                                    }
                                    .scrollTargetLayout()
                                    .padding(.trailing, horizontalPadding)
                                }
                                .scrollTargetBehavior(.viewAligned)
                                .coordinateSpace(name: "totalContributionCardScroll")
                                .overlay(
                                    GeometryReader { scrollProxy in
                                        Color.clear
                                            .onAppear {
                                                let rect = scrollProxy.frame(in: .named("totalContributionCardScroll"))
                                                viewport = rect
                                            }
                                            .onChange(of: scrollProxy.size) { _, _ in
                                                let rect = scrollProxy.frame(in: .named("totalContributionCardScroll"))
                                                viewport = rect
                                            }
                                    }
                                    .allowsHitTesting(false)
                                )
                            }
                            .zIndex(selectedMilestoneType == 0 ? -1 : 1)
                            .scaleEffect(selectedMilestoneType == 0 ? 0.7 : 1)
                            .opacity(selectedMilestoneType == 0 ? 0 : 1)
                            .animation(.spring(duration: 0.3), value: selectedMilestoneType)
                            .padding(.top, 12)
                            .onPreferenceChange(TotalContributionCardFramesKey.self) { frames in
                                totalContributionCardFrames = frames
                                updateSelectedTotalContributionCardByCenter()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            .padding(.bottom, 150)
        }
    }
    
    private func updateSelectedLevelCardByCenter() {
        guard !viewport.isEmpty else { return }
        
        let centerX = viewport.midX
        var best: (UUID, CGFloat)? = nil
        
        for (id, frame) in levelCardFrames {
            let distance = abs(frame.midX - centerX)
            if let current = best {
                if distance < current.1 {
                    best = (id, distance)
                }
            } else {
                best = (id, distance)
            }
        }
        
        if let best = best {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedLevelCard = best.0
            }
        }
    }
    
    private func updateSelectedTotalContributionCardByCenter() {
        guard !viewport.isEmpty else { return }
        
        let centerX = viewport.midX
        var best: (UUID, CGFloat)? = nil
        
        for (id, frame) in totalContributionCardFrames {
            let distance = abs(frame.midX - centerX)
            if let current = best {
                if distance < current.1 {
                    best = (id, distance)
                }
            } else {
                best = (id, distance)
            }
        }
        
        if let best = best {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTotalContributionCard = best.0
            }
        }
    }
}

enum ResetKey {
    static let daily = "lastDailyReset"
    static let weekly = "lastWeeklyReset"
}


// MARK: - Models
struct Challenge: Identifiable, Codable {
    var id = UUID()
    let title: String
    let type: TypeOfChallenge
    let contributionType: TypeOfContribution?
    let target: Int
    let xp: Int
    var xpRewarded: Bool = false
    let iconPath: String
    
    func saveChallenges(_ challenges: [Challenge]) {
        if let data = try? JSONEncoder().encode(challenges) {
            UserDefaults.standard.set(data, forKey: "DynamicChallenges")
        }
    }

    func loadChallenges() -> [Challenge] {
        if let data = UserDefaults.standard.data(forKey: "DynamicChallenges"),
           let decoded = try? JSONDecoder().decode([Challenge].self, from: data) {
            return decoded
        }
        return []
    }
    
    static func createChallenge(_ typeOfChallenge: TypeOfChallenge, _ disallowedTypes: [TypeOfContribution]? = nil, _ userSelectedTypes: [TypeOfContribution] = TypeOfContribution.allCases) -> Challenge {
        let id = UUID()
        var title = "Empty title"
        let type = typeOfChallenge
        var target = 1
        var xp = 1
        var iconPath = ""
        
        if (typeOfChallenge.rawValue == "Daily") {
            target = 1
            xp = Int.random(in: 3...6)
        } else {
            target = Int.random(in: 2...3)
            xp = Int.random(in: 1...3) + target * 3
        }
                
        // Decide whether the challenge has a type or not
        let randomNumber = Int.random(in: 1...5)
        if (randomNumber != 1) {
            let baseTypes = userSelectedTypes.isEmpty ? TypeOfContribution.allCases : userSelectedTypes
            let allowedContributionTypes = baseTypes.filter { $0 != .other && !(disallowedTypes ?? []).contains($0) }
            let contributionType = allowedContributionTypes.randomElement()
            
            var firstCapital: String = ""
            if let text = contributionType?.rawValue {
                firstCapital = text.prefix(1).uppercased() + text.dropFirst()
            }
            
            if target == 1 {
                if (typeOfChallenge.rawValue == "Weekly") {
                    target = Int.random(in: 7...10)
                }
                title = "\(target) \(firstCapital) Contribution"
            } else {
                title = "\(target) \(firstCapital) Contributions"
            }
            
            // Select challenge icon
            switch contributionType {
            case .cleanliness:
                iconPath = "CleanlinessIcon"
            case .plantcare:
                iconPath = "PlantcareIcon"
            case .kindness:
                iconPath = "KindnessIcon"
            case .donation:
                iconPath = "DonationIcon"
            case .animalcare:
                iconPath = "AnimalcareIcon"
            default:
                iconPath = "ErrorIcon"
            }
            
            return Challenge(id: id, title: title, type: type, contributionType: contributionType, target: target, xp: xp, iconPath: iconPath)
        }
        else {
            iconPath = "ContributionIcon"
            if target == 1 {
                title = "\(target) Contribution"
            } else {
                title = "\(target) Contributions"
            }
            
            return Challenge(id: id, title: title, type: type, contributionType: nil, target: target, xp: xp, iconPath: iconPath)
        }
    }
}

enum TypeOfChallenge: String, Identifiable, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case milestone = "Milestone"
    
    var id: String { rawValue }
}

// MARK: - Challenges and Levels

struct LevelMilestone: Identifiable {
    let id = UUID()
    let level: Int
    let title: String
    let description: String
    let badgePath: String
}

struct TotalContributionMilestone: Identifiable {
    let id = UUID()
    let amount: Int
    let title: String
    let description: String
    let xp: Int
}

let levelMilestones: [LevelMilestone] = [
    LevelMilestone(level: 2, title: "Baby Contributor", description: "Reach level 2", badgePath: "Bronze1Badge"),
    LevelMilestone(level: 5, title: "Rookie Contributor", description: "Reach level 5", badgePath: "Bronze2Badge"),
    LevelMilestone(level: 10, title: "Rising Contributor", description: "Reach level 10", badgePath: "Silver1Badge"),
    LevelMilestone(level: 15, title: "Solid Contributor", description: "Reach level 15", badgePath: "Silver2Badge"),
    LevelMilestone(level: 20, title: "Dedicated Contributor", description: "Reach level 20", badgePath: "Gold1Badge"),
    LevelMilestone(level: 30, title: "Contributor Connoisseur", description: "Reach level 30", badgePath: "Gold2Badge"),
    LevelMilestone(level: 50, title: "Legendary Contributor", description: "Reach level 50", badgePath: "Champion1Badge"),
    LevelMilestone(level: 75, title: "Elite Contributor", description: "Reach level 75", badgePath: "Champion2Badge"),
    LevelMilestone(level: 100, title: "Ultimate Contributor", description: "Reach level 100", badgePath: "SuperiorBadge")
]



let totalContributionMilestones: [TotalContributionMilestone] = [
    TotalContributionMilestone(amount: 1, title: "A New Beginning", description: "Log your first contribution", xp: 2),
    TotalContributionMilestone(amount: 5, title: "Handy Helper", description: "Log 5 contributions", xp: 5),
    TotalContributionMilestone(amount: 10, title: "Community Cleaner", description: "Log 10 contributions", xp: 5),
    TotalContributionMilestone(amount: 25, title: "Litter-picking Lion", description: "Log 25 contributions", xp: 5),
    TotalContributionMilestone(amount: 50, title: "Garden Guardian", description: "Log 50 contributions", xp: 10),
    TotalContributionMilestone(amount: 75, title: "Citywide Custodian", description: "Log 75 contributions", xp: 10),
    TotalContributionMilestone(amount: 100, title: "Local Legend", description: "Log 100 contributions", xp: 10),
    TotalContributionMilestone(amount: 150, title: "Urban Uplifter", description: "Log 150 contributions", xp: 15),
    TotalContributionMilestone(amount: 200, title: "City Saviour ", description: "Log 200 contributions", xp: 15),
]

struct ChallengesView_Previews: PreviewProvider {
    @State static var selectedLevelCard = UUID()
    @State static var selectedTotalContributionCard = UUID()

    static var previews: some View {
        ChallengesView(selectedLevelCard: $selectedLevelCard, selectedTotalContributionCard: $selectedTotalContributionCard)
            .environmentObject(UserData())
    }
}

