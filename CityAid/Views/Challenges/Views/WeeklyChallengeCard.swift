import SwiftUI

struct WeeklyChallengeCard: View {
    let challenge: Challenge
    let progress: (Int, Bool)
    
    @State private var isTapped: Bool = false
    
    var body: some View {
        VStack {
            Image(challenge.iconPath)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
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
            
            Text("\(progress.0)/\(challenge.target) • \(challenge.xp) XP")
                .font(.system(size: 15, weight: .semibold).italic())
                .foregroundStyle(Color(.gray.opacity(0.8)))
        }
        .padding(15)
        .frame(width: 120, height: 120)
        .background(Color.gray.opacity(0.1))
        .background(
            Group {
                if progress.1 {
                    LinearGradient(
                        colors: [.green.opacity(0.3), .black],
                        startPoint: UnitPoint(x: 0, y: 1),
                        endPoint: UnitPoint(x: 1, y: 0)
                    )
                } else {
                    Color.gray.opacity(0.1)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
    }
}
