import SwiftUI
internal import CoreData

struct ContributionRow: View, Identifiable {
    let id = UUID()
    let contributionManager: ContributionManager
    let user: UserData
    var item: ContributionEntity
    @Binding public var backgroundMode: BackgroundMode
    @Binding public var showStreakAnimation: Bool
    @State private var contributionToEdit: ContributionEntity? = nil
    @Environment(\.managedObjectContext) private var context
    @Namespace var animationNamespace
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.title ?? "Untitled")
                    Text(item.type ?? "")
                        .font(Font.caption.bold())
                        .foregroundStyle(Color(.secondaryLabel))
                    if let date = item.date {
                        Text(date, style: .date)
                            .font(.system(size: 10).italic())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
                .matchedTransitionSource(id: id, in: animationNamespace)
                Spacer()
            }
            .sheet(item: $contributionToEdit, onDismiss: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    backgroundMode = .none
                }
            }) { contribution in
                EditContributionSheet(contribution: contribution, user: user, backgroundMode: $backgroundMode)
                    .navigationTransition(.zoom(sourceID: id, in: animationNamespace))
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    contributionManager.deleteContribution(contribution: item)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)

                Button {
                    contributionToEdit = item
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.blue)
                
                Menu {
                    ControlGroup {
                        Button {
                            contributionManager.duplicateContribution(contribution: item, duplicateDate: false, user: user)
                        } label: {
                            Label("Today's date", systemImage: "calendar")
                        }
                        .tint(.white)
                        
                        Button {
                            contributionManager.duplicateContribution(contribution: item, duplicateDate: true, user: user)
                        } label: {
                            Label("Keep original", systemImage: "calendar.badge.clock")
                        }
                        .tint(.white)
                    }
                } label: {
                    Label("Duplicate", systemImage: "document.on.document")
                }
                .tint(.green)
            }
        }
    }
}
