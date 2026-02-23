import SwiftUI

struct AdminView: View {
    @EnvironmentObject var user: UserData
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ContributionEntity.date, ascending: false)]
    ) private var contributions: FetchedResults<ContributionEntity>

    var contributionManager: ContributionManager {
        ContributionManager(user: user, context: context)
    }

    @Binding public var quickLogs: [String: Int]
    
    @State private var showDeleteUserDataAlert: Bool = false
    @State private var showDeleteAllContributionsAlert: Bool = false

    var body: some View {
        List {
            Section(
                header: Text("Admin")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.5)),
                footer: Text("This section is intended for testing and debugging. Ensure you read and understand the options well before using them, as they cannot be undone.")
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
                    Text("Delete user data")
                        .foregroundStyle(.red)
                    Spacer()
                    Image(systemName: "trash")
                        .frame(width: 40, height: 40)
                        .glassEffect(.clear.interactive().tint(.red))
                        .onTapGesture {
                            showDeleteUserDataAlert = true
                        }
                        .alert("Delete user data?", isPresented: $showDeleteUserDataAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Delete", role: .destructive) {
                                user.xp = 0
                                user.level = 1
                                user.dailyChallengesCompleted = 0
                                user.weeklyChallengesCompleted = 0
                                user.streak = 0
                                user.isStreakCompletedToday = false
                                user.playedStreakAnimation = false
                                user.hasOpenedBefore = false
                                
                                // Reset userdefaults dictionary
                                UserDefaults.standard.removeObject(forKey: "quickLogKey")
                                
                                let defaults: [String: Int] = [
                                    "Litter-Picking": 0,
                                    "Gave up my seat": 0,
                                    "Cleared plant area": 0,
                                    "Helped with directions": 0,
                                    "Took someone's trash": 0,
                                    "Helped an animal": 0,
                                    "Held a door open": 0
                                ]
                                
                                UserDefaults.standard.set(defaults, forKey: "quickLogKey")
                                quickLogs = defaults
                            }
                        } message: {
                            Text("This action cannot be undone.")
                        }
                }
                
                HStack {
                    Text("Delete all contributions")
                        .foregroundStyle(.red)
                    Spacer()
                    Image(systemName: "document.on.trash")
                        .frame(width: 40, height: 40)
                        .glassEffect(.clear.interactive().tint(.red))
                        .onTapGesture {
                            showDeleteAllContributionsAlert = true
                        }
                        .alert("Delete all contributions?", isPresented: $showDeleteAllContributionsAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Delete", role: .destructive) {
                                contributionManager.deleteAllContributions(contributions: contributions)
                            }
                        } message: {
                            Text("This action cannot be undone.")
                        }
                }
            }
        }
        .navigationTitle("Admin Options")
        .navigationBarTitleDisplayMode(.inline)
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
