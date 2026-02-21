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
    
    @State private var imgPath: String = ""
    @State private var imgBgColour: Color = .black
    var iconName: String {
        switch (item.type ?? "") {
        case "Cleanliness":
            return "CleanlinessIcon"
        case "Plant Care", "plantcare":
            return "PlantcareIcon"
        case "Donation":
            return "DonationIcon"
        case "Kindness":
            return "KindnessIcon"
        case "Animal Care":
            return "AnimalcareIcon"
        default:
            return "OtherIcon"
        }
    }
    var gradientColour: Color {
        switch (item.type ?? "") {
        case "Cleanliness":
            return .cyan
        case "Plant Care", "plantcare":
            return .green
        case "Donation":
            return .orange
        case "Kindness":
            return .red
        case "Animal Care", "animalcare":
            return .brown
        default:
            return .white
        }
    }


    var body: some View {
        ZStack {
            HStack {
                ZStack {
                    RadialGradient(colors: [imgBgColour.opacity(0.2), .clear], center: .center, startRadius: 0, endRadius: 25)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    Image(!imgPath.isEmpty ? imgPath : "OtherIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }
                VStack(alignment: .leading) {
                    Text(item.title ?? "Untitled")
                        .bold()
                    Text(item.notes ?? "No Notes")
                        .font(Font.caption).italic()
                        .foregroundStyle(Color(.secondaryLabel))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxHeight: .infinity)
                .matchedTransitionSource(id: id, in: animationNamespace)
                Spacer()
                
                VStack {
                    if let date = item.date {
                        Text(date, format: .dateTime.day(.twoDigits).month(.twoDigits).year())
                            .font(.system(size: 10).italic())
                            .foregroundStyle(Color(.secondaryLabel))
                            .frame(alignment: .top)
                    }
                    Spacer()
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
        .frame(height: 40)
        .onAppear {
            imgPath = iconName
            imgBgColour = gradientColour
        }
    }
}

// apple intelligence preview :)
#Preview("ContributionRow List") {
    // Build an in-memory Core Data stack for previews
    let container = NSPersistentContainer(name: "CityAidModel")
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { _, _ in }
    let context = container.viewContext

    // Seed sample contributions
    let sampleTypes = ["Cleanliness", "Kindness", "Donation", "Animal Care", "Plant Care", "Other"]
    for i in 0..<3 {
        let c = ContributionEntity(context: context)
        c.id = UUID()
        c.title = "Preview Contribution \(i + 1)"
        c.type = sampleTypes[i % sampleTypes.count]
        c.date = Date().addingTimeInterval(TimeInterval(-i * 86400))
        c.notes = "Sample notes for contribution \(i + 1)"
    }
    try? context.save()

    let user = UserData()
    let manager = ContributionManager(user: user, context: context)

    // Fetch items to show in the preview
    let request: NSFetchRequest<ContributionEntity> = ContributionEntity.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    let items = (try? context.fetch(request)) ?? []

    return List {
        ForEach(items) { item in
            ContributionRow(
                contributionManager: manager,
                user: user,
                item: item,
                backgroundMode: .constant(.none),
                showStreakAnimation: .constant(false)
            )
        }
    }
    .environment(\.managedObjectContext, context)
    .preferredColorScheme(.dark)
}

