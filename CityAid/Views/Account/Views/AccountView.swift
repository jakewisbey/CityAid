import SwiftUI

// MARK: - AccountView
struct AccountView: View {
    // User, contributions and managers
    @EnvironmentObject var user: UserData
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ContributionEntity.date, ascending: false)]
    ) private var contributions: FetchedResults<ContributionEntity>

    var contributionManager: ContributionManager {
        ContributionManager(user: user, context: context)
    }
    var challengeManager: ChallengeManager {
        ChallengeManager(user: user, contributions: contributions)
    }
    
    // Other
    @Environment(\.colorScheme) var colorScheme
    @State private var path = NavigationPath()
    @State private var showingStreakInfo = false;
    @State private var streakText = ""
    @State private var quickLogs: [String: Int] = [:]

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section(header: Text("Profile")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                ) {
                    HStack {
                        Text("Username:")
                        Spacer()
                        TextField("", text: $user.username)
                            .padding(.horizontal, 4)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 220, alignment: .trailing)
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Bio:")
                        TextEditor(text: $user.bio)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .scrollContentBackground(.hidden)
                            .cornerRadius(10)
                    }
                }

                Section(header: Text("Stats")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                ) {
                    HStack {
                        Text("Total Contributions:")
                        Spacer()
                        Text(String(contributions.count))
                            .frame(alignment: .trailing)
                            .padding(.trailing, 10)
                    }

                    HStack {
                        Text("Level:")
                        Spacer()
                        Text(String(user.level))
                            .frame(alignment: .trailing)
                            .padding(.trailing, 10)
                    }

                    HStack {
                        Text("XP:")
                        Spacer()
                        let xpForNextLevel = RequiredXpForLevelUp()
                        Text("\(user.xp)/\(xpForNextLevel)")
                            .frame(alignment: .trailing)
                            .padding(.trailing, 10)
                    }

                    HStack {
                        Text("Streak:")
                        Spacer()
                        
                        Text(
                            user.streak == 0 ? "Inactive" :
                            user.streak == 1 ? "1 day 🔥" :
                            "\(user.streak) days 🔥"
                        )
                        .foregroundStyle(Color(user.isStreakCompletedToday ? .green : .red))
                        .frame(alignment: .trailing)
                    }

                    HStack {
                        Text("Daily Challenges Completed:")
                        Spacer()
                        Text("\(user.dailyChallengesCompleted)")
                            .frame(alignment: .trailing)
                            .padding(.trailing, 10)
                    }

                    HStack {
                        Text("Weekly Challenges Completed:")
                        Spacer()
                        Text("\(user.weeklyChallengesCompleted)")
                            .frame(alignment: .trailing)
                            .padding(.trailing, 10)
                    }
                }
                
                Section(header: Text("Options")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                ) {
                    NavigationLink("Select possible challenge types"){
                        ChallengeOptionsView()
                    }
                    NavigationLink("Change QuickLog count"){
                        QuickLogCountView(quickLogs: $quickLogs)
                    }
                }
                
                Section(header: Text("Admin")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                ) {
                    NavigationLink("View admin options") {
                        AdminView(quickLogs: $quickLogs, challengeManager: challengeManager)
                    }
                    NavigationLink("Credits") {
                        CreditsView()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
        }
        .onAppear {
            quickLogs = UserDefaults.standard.object(forKey: "quickLogKey") as? [String: Int] ?? [:]
        }

    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
    }
    
    func RequiredXpForLevelUp() -> Int {
        let bracket = ((user.level) / 10)
        let xp = 15 + bracket * 5
        return min(xp, 75)
    }
    
    func CalculateUserLevel() -> Int {
        var level = user.level
        
        if user.xp >= RequiredXpForLevelUp() {
            level += 1
            user.xp = user.xp - RequiredXpForLevelUp()
        }
        
        return level
    }
    
}

#Preview {
    AccountView()
        .environmentObject(UserData())
}

