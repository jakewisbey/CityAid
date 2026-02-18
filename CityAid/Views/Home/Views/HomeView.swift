import SwiftUI
import CoreMotion
internal import CoreData

// MARK: - HomeView
struct HomeView: View{
    @EnvironmentObject var user: UserData
    @Binding var backgroundMode : BackgroundMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var context
    @Binding var showStreakAnimation: Bool
    
    let motionManager = CMMotionManager()
    @State private var stars: [NSManagedObjectID: Star] = [:]
    let starColours: [Color] = [.yellow, .white]
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ContributionEntity.date, ascending: false)]
    ) private var contributions: FetchedResults<ContributionEntity>
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView (showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    Image("BgImage")
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                    
                    ForEach(contributions, id: \.objectID) { contribution in
                        if let star = stars[contribution.objectID] {
                            StarView(star: star)
                                .transaction { t in
                                    t.disablesAnimations = true
                                }
                            
                        }
                    }
                }
                
                VStack(spacing: 10) {
                    ForEach(contributions) { item in
                        ContributionRow(user: user, item: item, backgroundMode: $backgroundMode, showStreakAnimation: $showStreakAnimation)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(16)
            }
            .animation(.spring(), value: contributions.map { $0.objectID })
            .ignoresSafeArea()
            .ignoresSafeArea(.keyboard)
            .onAppear {
                generatePositions(in: proxy.size)
            }
            .onChange(of: contributions.count) { _, _ in
                generatePositions(in: proxy.size)
            }
            .onDisappear {
                motionManager.stopDeviceMotionUpdates()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("CityAid")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
                Text("building a brighter city for everyone")
                    .foregroundStyle(.white)
                    .opacity(0.6)
                
            }
            .padding()
            
        }
        .backgroundStyle(.black)
    }
    
    
    func CountContributionsOfType(_ type: String) -> Int {
        contributions.filter { $0.type == type }.count
    }
    
    func randomPosition(in size: CGSize) -> CGPoint {
        CGPoint(
            x: size.width * CGFloat.random(in: 0...1),
            y: size.height * CGFloat.random(in: 0.2...0.75)
        )
    }
    
    func generatePositions(in size: CGSize) {
        for contribution in contributions {
            if stars[contribution.objectID] == nil {
                let position = randomPosition(in: size)
                let randomSize = CGFloat(Float.random(in: 10...30))
                let floatAmplifier = Bool.random()
                    ? CGFloat.random(in: -5...2)
                    : CGFloat.random(in: 2...5)
                
                stars[contribution.objectID] = Star(
                    basePosition: position,
                    width: randomSize*0.7,
                    height: randomSize,
                    color: starColours.randomElement()!,
                    opacity: Float.random(in: 0.6...1),
                    floatAmplifier: floatAmplifier
                )
            }
        }
    }
}

struct Star {
    var basePosition: CGPoint
    let width: CGFloat
    let height: CGFloat
    let color: Color
    let opacity: Float
    let floatAmplifier: CGFloat
}

struct StarView: View {
    let star: Star
            
    @State var isInitialised: Bool = false
    
    @State var isTapped: Bool = false
    @State var glowScale: CGFloat = 1
    @State var rotation: Double = 135
    @State var scale: CGFloat = 0.5
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let offset = sin(time * 0.5 + Double(star.basePosition.x)) * star.floatAmplifier
            
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [star.color.opacity(0.2), .black.opacity(0)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: star.width
                )
                .scaleEffect(glowScale)
                .onAppear {
                    let delay = Double.random(in: 0...5)
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        
                        withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                            glowScale = 1.2
                        }
                    }
                }
                
                Image("Star")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: star.width, height: star.height)
                    .foregroundStyle(star.color.opacity(Double(star.opacity)))
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
            }
            .position(
                x: star.basePosition.x,
                y: star.basePosition.y + offset
            )
            .onAppear {
                
                if !isInitialised {
                    isInitialised = true
                    
                    
                    // spin in
                    DispatchQueue.main.asyncAfter(deadline: .now() + star.basePosition.y / 2000) {
                        withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
                            rotation = 0
                            scale = 1
                        }
                    }
                }
            }
        }
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
