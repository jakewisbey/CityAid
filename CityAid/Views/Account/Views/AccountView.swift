import SwiftUI

// MARK: - AccountView
struct AccountView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var path = NavigationPath()
    @EnvironmentObject var user: UserData
    var challengeManager: ChallengeManager {
        ChallengeManager(user: user)
    }
    
    @FetchRequest(
        sortDescriptors: []
    ) private var contributions: FetchedResults<ContributionEntity>

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
                            .frame(width: 175, alignment: .trailing)
                            .background(Color(.gray).opacity(0.02))
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Bio:")
                        TextEditor(text: $user.bio)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .scrollContentBackground(.hidden)
                            .background(Color(.gray).opacity(0.02))
                            .cornerRadius(10)
                    }
                }

                Section(header: Text("General")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                ) {
                    NavigationLink("Change possible challenge types"){
                        ChallengeOptionsView()
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
                        if user.streak == 0 {
                            Text(String(user.streak) + " days")
                                .frame(alignment: .trailing)
                        } else {
                            Text(String(user.streak) + " days")
                                .frame(alignment: .trailing)
                            Text("🔥")
                        }
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

                Section(header: Text("Admin")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                ) {
                    HStack {
                        Text("Add user XP")
                        Spacer()
                        Image(systemName: "plus")
                            .frame(width: 40, height: 40)
                            .glassEffect(.clear.interactive())
                            .onTapGesture {
                                let randomXp = Int.random(in: 3...6)
                                user.xp += randomXp
                                user.level = CalculateUserLevel()
                            }
                    }

                    HStack {
                        Text("Delete User Data")
                        Spacer()
                        Image(systemName: "trash")
                            .frame(width: 40, height: 40)
                            .glassEffect(.clear.interactive().tint(.red))
                            .onTapGesture {
                                user.xp = 0
                                user.level = 1
                                user.dailyChallengesCompleted = 0
                                user.weeklyChallengesCompleted = 0
                                user.streak = 0
                                user.isStreakCompletedToday = false
                                user.playedStreakAnimation = false
                            }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
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

