import SwiftUI
internal import CoreData

// MARK: - HomeView
struct HomeView: View{
    @EnvironmentObject var user: UserData
    @Binding var backgroundMode : BackgroundMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var context
    @Binding var showStreakAnimation: Bool

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ContributionEntity.date, ascending: false)]
    ) private var contributions: FetchedResults<ContributionEntity>
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                ZStack(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CityAid")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(.white)
                        Text("building a brighter city for everyone")
                            .foregroundStyle(.white)
                            .opacity(0.6)

                        ForEach(contributions) { item in
                            ContributionRow(user: user, item: item, backgroundMode: $backgroundMode, showStreakAnimation: $showStreakAnimation)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .animation(.spring(), value: contributions.map { $0.objectID })
                    .padding(16)
                    .padding(.top, 30)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .background(LinearGradient (colors: [Color(red: 0/255, green: 0/255, blue: 100/255), .black], startPoint:. top, endPoint: .bottom))
    }

    
    func CountContributionsOfType(_ type: String) -> Int {
        contributions.filter { $0.type == type }.count
    }
}

struct ContributionRow: View, Identifiable {
    let id = UUID()
    let user: UserData
    var item: ContributionEntity
    @Binding public var backgroundMode: BackgroundMode
    @Binding public var showStreakAnimation: Bool
    @State private var contributionToEdit: ContributionEntity? = nil
    @Environment(\.managedObjectContext) private var context
    @Namespace var animationNamespace
    
    var body: some View {
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
            
            Menu {
                Button () {
                    contributionToEdit = item
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Menu() {
                    
                    Button {
                        // Use today's date
                        DuplicateContribution(contribution: item, duplicateDate: false, user: user)
                    } label: {
                        Label("Use today's date", systemImage: "calendar")
                    }
                    
                    Button {
                        // Keep the original contribution date
                        DuplicateContribution(contribution: item, duplicateDate: true, user: user)
                    } label: {
                        Label("Keep original date", systemImage: "calendar.badge.clock")
                    }
                } label: {
                    Label("Duplicate", systemImage: "document.on.document")
                }
                
                Button(role: .destructive) {
                    DeleteContribution(contribution: item)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 40, height: 40)
            }
        }
        
        .sheet(item: $contributionToEdit, onDismiss: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                backgroundMode = .none
            }
        }) { contribution in
            EditContributionSheet(contribution: contribution, user: user, backgroundMode: $backgroundMode)
                .navigationTransition(.zoom(sourceID: id, in: animationNamespace))
        }
    }
    
    func DuplicateContribution(contribution: ContributionEntity, duplicateDate: Bool, user: UserData) {
        let duplicateContribution = ContributionEntity(context: context)
        
        duplicateContribution.id = UUID()
        duplicateContribution.title = contribution.title
        duplicateContribution.type = contribution.type
        
        if duplicateDate {
            duplicateContribution.date = contribution.date
        } else {
            duplicateContribution.date = Date()
        }
        
        duplicateContribution.xp = contribution.xp
        user.xp += Int(duplicateContribution.xp)
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Core Data save error:", error)
            print("userInfo:", error.userInfo)
            context.rollback() // important to discard the bad insert/update
        }
    }
        
    func DeleteContribution (contribution: ContributionEntity) {
        // remove 2/3 of previously awarded xp from user.xp, and recalculate level in case it goes negative
        user.xp -= ( 2 * Int(contribution.xp) / 3 )
        user.CalculateUserLevel()
        context.delete(contribution)
        do {
            try context.save()
        } catch let error as NSError {
            print("Core Data save error:", error)
            print("userInfo:", error.userInfo)
            context.rollback() // important to discard the bad insert/update
        }
    }
}


#Preview {
    HomeView(backgroundMode: .constant(.none), showStreakAnimation: .constant(false))
}

