import SwiftUI
internal import CoreData

// MARK: - HomeView
struct HomeView: View{
    @EnvironmentObject var user: UserData
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var context
    

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ContributionEntity.date, ascending: false)]
    ) private var contributions: FetchedResults<ContributionEntity>
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                ZStack(alignment: .topLeading) {
                    GeometryReader { bgGeo in
                        Image("ContributionIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width,
                                   height: geo.size.height)
                            .offset(y: -bgGeo.frame(in: .global).minY * 0.9)
                    }
                    .frame(height: geo.size.height)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("CityAid")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(.white)
                        Text("building a brighter city for everyone")
                            .foregroundStyle(.white)
                            .opacity(0.6)

                        ForEach(contributions) { item in
                            ContributionRow(user: user, item: item)
                        }
                    }
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
    @Environment(\.managedObjectContext) private var context

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
            Spacer()
            
            Menu {
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
    }
    
    func DuplicateContribution(contribution: ContributionEntity, duplicateDate: Bool, user: UserData) {
        let duplicateContribution = ContributionEntity(context: context)
        duplicateContribution.title = contribution.title
        duplicateContribution.type = contribution.type

        if duplicateDate {
            duplicateContribution.date = contribution.date
        } else {
            duplicateContribution.date = Date()
        }
        
        let randomXP = Int.random(in: 3...6)
        user.xp += randomXP
        
        try? context.save()
    }
        
    func DeleteContribution (contribution: ContributionEntity) {
        context.delete(contribution)
        try? context.save()
    }
}

#Preview {
    HomeView()
}
