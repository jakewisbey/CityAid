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
    
    @Namespace public var starNamespace
    @State private var stars: [NSManagedObjectID: Star] = [:]
    let starColours: [Color] = [.yellow, .white]
    @State private var selectedContribution: ContributionEntity?
    @State private var selectedStar: Star?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ContributionEntity.date, ascending: false)]
    ) private var contributions: FetchedResults<ContributionEntity>
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ScrollView (showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        Image("BgImage")
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFill()
                            .allowsHitTesting(false)
                        
                        ForEach(contributions, id: \.objectID) { contribution in
                            if let star = stars[contribution.objectID] {
                                StarView(star: star, namespaceID: starNamespace, onTap: {
                                    selectedStar = star
                                    selectedContribution = contribution
                                })
                                .matchedTransitionSource(id: star.id, in: starNamespace)
                                .zIndex(1)
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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("CityAid")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)
                    Text("building a brighter city for everyone")
                        .foregroundStyle(.white)
                        .opacity(0.6)
                    
                }
                .padding()
                .allowsHitTesting(false)
                
            }
            .backgroundStyle(.black)
        }
        .sheet(item: $selectedContribution) { contribution in
            StarTappedView(contribution: contribution)
                .navigationTransition(.zoom(sourceID: /*"selectedStar.id" -- never seemed to work*/"None", in: starNamespace))
                .frame(maxHeight: UIScreen.main.bounds.height * 0.3)
            .presentationDetents([.fraction(0.3)])
        }
    }
    
    
    func CountContributionsOfType(_ type: String) -> Int {
        contributions.filter { $0.type == type }.count
    }
    
    func randomPosition(in size: CGSize) -> CGPoint {
        CGPoint(
            x: size.width * CGFloat.random(in: 0.05...0.95),
            y: size.height * CGFloat.random(in: 0.25...0.75)
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
                    id: UUID(),
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

struct StarTappedView: View {
    let contribution: ContributionEntity
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text(contribution.type ?? "")
                    .font(.headline)
                Text(contribution.date ?? .now, style: .date)
                    .font(.subheadline)
                    .opacity(0.6)
            }
            .padding(20)
        }
    }
}













struct Star {
    let id: UUID
    var basePosition: CGPoint
    let width: CGFloat
    let height: CGFloat
    let color: Color
    let opacity: Float
    let floatAmplifier: CGFloat
}

#Preview {
    HomeView(backgroundMode: .constant(.none), showStreakAnimation: .constant(false))
}
