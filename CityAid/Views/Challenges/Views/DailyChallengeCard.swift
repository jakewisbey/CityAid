import SwiftUI

struct DailyChallengeCard: View {
    @State private var isTapped: Bool = false

    let user: UserData
    var challengeManager: ChallengeManager {
        ChallengeManager(user: user)
    }
    let contributions: FetchedResults<ContributionEntity>
    
    // Stop compiler from complaining my statements are too long
    var dailyProgress: (Int, Bool) {
        challengeManager.calculateChallengeProgress(
            .daily,
            user.dailyChallenge.target,
            user.dailyChallenge.contributionType, contributions
        )
    }

    var body: some View {
        HStack (alignment: .center, spacing: 15) {
                            Image(user.dailyChallenge.iconPath)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
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

                            
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Complete")
                                    .font(.system(size: 15, weight: .semibold).italic())
                                    .foregroundStyle(Color(.gray.opacity(0.8)))
                                    
                                Text(user.dailyChallenge.title)
                                    .font(.system(size: 20, weight: .bold))
                                    .minimumScaleFactor(0.9)
                                                            
                                Text("\(dailyProgress.0)/\(user.dailyChallenge.target) • \(user.dailyChallenge.xp) XP")
                                    .font(.system(size: 15, weight: .semibold).italic())
                                    .foregroundStyle(Color(.gray.opacity(0.8)))

                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(15)
                        .frame(width: 375, height: 100)
                        .background(Color.gray.opacity(0.1))
                        .background(
                            Group {
                                if dailyProgress.1 {
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
