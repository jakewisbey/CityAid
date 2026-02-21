import SwiftUI

struct AllContributionsSheet: View {
    let user: UserData
    let contributions: FetchedResults<ContributionEntity>
    @Binding var backgroundMode: BackgroundMode
    @Binding var showStreakAnimation: Bool
    @State private var contributionToEdit: ContributionEntity? = nil
    
    @Namespace var editNamespace
    
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
                        .matchedTransitionSource(id: item.id, in: editNamespace)

                        .contextMenu {
                            Button() {
                                contributionToEdit = item
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Menu {
                                Button {
                                    contributionManager.duplicateContribution(contribution: item, duplicateDate: false, user: user)
                                } label: {
                                    Label("Today's date", systemImage: "calendar")
                                }
                                
                                Button {
                                    contributionManager.duplicateContribution(contribution: item, duplicateDate: true, user: user)
                                } label: {
                                    Label("Keep original", systemImage: "calendar.badge.clock")
                                }
                            } label: {
                                Label("Duplicate", systemImage: "document.on.document")
                            }

                            Button(role: .destructive) {
                                contributionManager.deleteContribution(contribution: item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .listRowBackground(Color.black)
            .navigationTitle("All Contributions")
        }

        .sheet(item: $contributionToEdit, onDismiss: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                backgroundMode = .none
            }
        }) { contribution in
            EditContributionSheet(contribution: contribution, user: user, backgroundMode: $backgroundMode)
                .navigationTransition(.zoom(sourceID: contribution.id, in: editNamespace))
        }

    }
}
