import SwiftUI
internal import CoreData

struct QuickLogBubble: View {
    let title: String
    let type: TypeOfContribution
    let originXCoord: CGFloat
    let originYCoord: CGFloat
    let xCoord: CGFloat
    let yCoord: CGFloat
    let iconName: String
    let delay: Float
    let user: UserData
    
    @Environment(\.managedObjectContext) private var context
    @Binding var showStreakAnimation: Bool
    
    var contributionManager: ContributionManager {
        ContributionManager(user: user, context: context)
    }
    
    @Binding var quickLogIsExpanded: Bool
    @Binding var backgroundMode: BackgroundMode
    let buttons: Namespace.ID

    var body: some View {
        Label(title, systemImage: iconName)
        
        .contentTransition(.symbolEffect(.replace))
        .font(.system(size: 20, weight: .bold).italic())
        .scaleEffect(quickLogIsExpanded ? 1 : 0.45)
        .opacity(quickLogIsExpanded ? 1 : 0)
        .blur(radius: quickLogIsExpanded ? 0 : 12)
        
        .contentShape(Rectangle())
        .allowsHitTesting(quickLogIsExpanded)
    
        .matchedTransitionSource(id: title, in: buttons)

        .onTapGesture {
            backgroundMode = .none
            quickLogIsExpanded = false
            
            contributionManager.saveContribution(contributionTitle: createTitle(), contributionDate: Date(), contributionMedia: [], selectedType: type, contributionNotes: "Added via Quick Log", showStreakAnimation: $showStreakAnimation)
            
        }
        .position(x: quickLogIsExpanded ? xCoord : originXCoord,
                  y: quickLogIsExpanded ? yCoord : originYCoord)
        
        .animation(.spring(response: 0.6, dampingFraction: 0.72, blendDuration: 0)
            .delay(TimeInterval(delay)), value: quickLogIsExpanded)
    }
    
    func createTitle() -> String {
        var quickLogs: [String: Int] = UserDefaults.standard.object(forKey: "quickLogKey") as? [String:Int] ?? [:]
        
        let key = String(title)
        let count = quickLogs[key] ?? 0
        
        quickLogs[key] = count + 1
        
        UserDefaults.standard.set(quickLogs, forKey: "quickLogKey")

        return title + " #" + String(count + 1)
    }
}
