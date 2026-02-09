import SwiftUI

struct ContributionBubble: View {
    let iconName: String
    let id: String
    let xCoord: CGFloat
    let yCoord: CGFloat
    let delay: Float
    let typeOfContribution: TypeOfContribution
    @Binding var isExpanded: Bool
    @Binding var selectedType: TypeOfContribution?
    @Binding var backgroundMode: BackgroundMode
    @Binding var selectedBubbleID: String
    let buttons: Namespace.ID
    
    
    var body: some View {
        Image(systemName: iconName)
            .font(.headline)
            .opacity(isExpanded ? 1 : 0)

            .frame(width: 50, height: 50)
            .contentShape(Rectangle())
            .allowsHitTesting(isExpanded)
        
            .matchedTransitionSource(id: id, in: buttons)
            .glassEffect(.clear.interactive())
            .glassEffectID(id, in: buttons)

            .onTapGesture {
                selectedType = typeOfContribution
                selectedBubbleID = id
                backgroundMode = .sheet
                isExpanded = false
            }
            .offset(x: isExpanded ? xCoord : 0,
                    y: isExpanded ? yCoord : 0)
            
            .animation(.interpolatingSpring(stiffness: 190, damping: 22) .delay(TimeInterval(delay)), value: isExpanded
            )
    }
}
