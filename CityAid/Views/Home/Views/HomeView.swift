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
                        .allowsHitTesting(false)
                    
                    ForEach(contributions, id: \.objectID) { contribution in
                        if let star = stars[contribution.objectID] {
                            StarView(star: star)
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
            .allowsHitTesting(false)
            
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

struct StarTappedView: View {
    var body: some View {
        Text("Star tapped!")
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

#Preview {
    HomeView(backgroundMode: .constant(.none), showStreakAnimation: .constant(false))
}
