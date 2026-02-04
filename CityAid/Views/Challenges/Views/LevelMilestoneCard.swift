import SwiftUI

struct LevelMilestoneCard: View {
    let id: UUID
    let milestone: LevelMilestone
    let title: String
    let caption: String
    let badge: String
    let selectedLevelCard: UUID
    var isSelected: Bool { selectedLevelCard == id }
    let user: UserData
    
    @State private var isTapped: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                    Image(badge)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 100, maxHeight: 100)
                        .scaleEffect(isTapped ? 1.2 : 1)
                        .animation(.interpolatingSpring(stiffness: 150, damping: 10), value: isTapped)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        if !isTapped { isTapped = true }
                                    }
                                    .onEnded { _ in
                                        isTapped = false
                                    }
                            )

                

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 5)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Text(caption)
                        .font(.system(size: 12))
                        .italic()
                        .foregroundStyle(Color(.secondaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 5)

                    
                    let completionStatus = user.level >= milestone.level ? "Completed" : "Not completed"

                    HStack (spacing: 2){
                        Text("Status: ")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(.secondaryLabel))
                            .padding(.leading, 5)
                        
                        Text(completionStatus)
                            .font(.system(size: 12))
                            .foregroundStyle(Color(completionStatus == "Completed" ? .green : .red))
                    }

                }

            }
            .frame(width: 300, height: 120)
            .fixedSize()
        }
        .scaleEffect(isSelected ? 1.0 : 0.8, anchor: .bottom)
        .saturation(isSelected ? 1.0 : 0.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.2), value: isSelected)
        .reportLevelCardFrame(id, in: .named("levelCardScroll"))
    }
}
