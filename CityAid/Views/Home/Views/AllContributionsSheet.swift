import SwiftUI

struct AllContributionsSheet: View {
    let user: UserData
    let contributions: FetchedResults<ContributionEntity>
    @Binding var backgroundMode: BackgroundMode
    @Binding var showStreakAnimation: Bool
    
    @Environment(\.managedObjectContext) private var context
    var contributionManager: ContributionManager {
        ContributionManager(user: user, context: context)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(contributions) { item in
                        ContributionRow(
                            contributionManager: contributionManager,
                            user: user,
                            item: item,
                            backgroundMode: $backgroundMode,
                            showStreakAnimation: $showStreakAnimation
                        )
                    }
                }
            }
            .listStyle(.plain)
            .listRowBackground(Color.black)
            .navigationTitle("All Contributions")
        }
    }
}
