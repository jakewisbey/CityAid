import SwiftUI
import CoreMotion
internal import CoreData

// MARK: - HomeView
struct HomeView: View{
    @EnvironmentObject var user: UserData
    @Environment(\.managedObjectContext) private var context
    var contributionManager: ContributionManager {
        ContributionManager(user: user, context: context)
    }
        
    @State var fgCityOffset: CGFloat = -5
    @State var fgCityOpacity: Double = 0.5
    @State var fgCityScale: CGFloat = 1.05
    
    @State var titleTextOffset: CGFloat = -10
    @State var titleTextOpacity: Double = 0

    @Environment(\.colorScheme) var colorScheme
    @Binding var showStreakAnimation: Bool

    @Namespace public var starNamespace
    @State private var stars: [NSManagedObjectID: Star] = [:]
    let starColours: [Color] = [.yellow, .white]

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ContributionEntity.date, ascending: false)]
    ) private var contributions: FetchedResults<ContributionEntity>
    
    var body: some View {
        
        ZStack {
            Image("BgImage")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
            
            ForEach(Array(stars.values), id: \.id) { star in
                StarView(star: star, namespaceID: starNamespace) {
                }
            }

            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 8) {
                    Text("CityAid")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)
                        .offset(y: titleTextOffset)
                        .opacity(titleTextOpacity)
                        .animation(.interpolatingSpring(stiffness: 50, damping: 15), value: titleTextOffset)
                    
                    Text("building a brighter city for everyone")
                        .foregroundStyle(.white)
                        .opacity(0.6)
                        .offset(y: titleTextOffset)
                        .opacity(titleTextOpacity)
                        .animation(.interpolatingSpring(stiffness: 50, damping: 15).delay(TimeInterval(0.2)), value: titleTextOffset)
                    
                    
                    Image("FgCity")
                        .resizable()
                        .scaledToFit()
                        .blur(radius: 2)
                        .opacity(fgCityOpacity)
                        .scaleEffect(x: geo.size.width / 1000 * 7 * fgCityScale, y: geo.size.height / 1000 * 3.5)
                        .position(x: geo.size.width * 0.46, y: geo.size.height * 0.80 + fgCityOffset)
                        .ignoresSafeArea()
                        .animation(.interpolatingSpring(stiffness: 50, damping: 15), value: fgCityOffset)
                        
                }
                .padding()
                .allowsHitTesting(false)
                .animation(.spring(), value: contributions.map { $0.objectID })
                .onAppear {
                    generatePositions(in: geo.size)
                }
                .onChange(of: contributions.count) { _, _ in
                    generatePositions(in: geo.size)
                    let currentIDs = Set(contributions.map { $0.objectID })
                    stars = stars.filter { currentIDs.contains($0.key) }
                }
                
                TimelineView(.animation) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let offset = sin(time * 0.5) * 5

                    ZStack {
                        RadialGradient(colors: [.white.opacity(0.1), .clear], center: .center, startRadius: 0, endRadius: 150)
                            .scaleEffect(x: 1.5, y: 0.7)
                        
                        VStack (spacing: 10) {
                            Text("No contributions yet.")
                                .font(.system(size: 24, weight: .bold))
                            
                            Text("Tap the \(Image(systemName: "plus.circle")) button to get started.")
                                .font(.system(size: 12).italic())
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                    .position(x: geo.size.width * 0.5, y: geo.size.width * 0.6 + offset)
                    .opacity(contributions.count == 0 ? 1 : 0)
                    .blur(radius: contributions.count == 0 ? 0 : 10)
                    .animation(.easeOut, value: contributions.count)
                }
            }
            
                
        }
        .onAppear {
            fgCityOffset = 0
            fgCityOpacity = 1
            fgCityScale = 1
            
            titleTextOffset = 0
            titleTextOpacity = 1
        }
    }
    
    
    func CountContributionsOfType(_ type: String) -> Int {
        contributions.filter { $0.type == type }.count
    }
    
    func randomPosition(in size: CGSize) -> CGPoint {
        CGPoint(
            x: size.width * CGFloat.random(in: 0.05...0.95),
            y: size.height * CGFloat.random(in: 0.16...0.6)
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
    ContentView()
        .environment(
            \.managedObjectContext,
            PreviewPersistenceController.shared.viewContext
        )
}
