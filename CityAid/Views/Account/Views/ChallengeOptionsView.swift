import SwiftUI

struct ChallengeOptionsView: View {
    @EnvironmentObject var user: UserData
    
    private let contributionTypes: [TypeOfContribution] = [.cleanliness, .plantcare, .kindness, .donation, .animalcare]
    
    var body: some View {
        List {
            Section(
                header: Text("Allowed Types")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.5)),
                footer: Text("Select which contribution types you would like to include for possible contribution types in challenges. This ensures challenges are more relevant to you, but always try to push yourself to do more!\n\nChallenges will update at the next reset.")
            ) {
                ForEach(contributionTypes, id: \.self) { type in
                    Toggle(type.rawValue.capitalized, isOn: Binding<Bool>(
                        get: {
                            user.selectedChallengeContributionTypes.contains(type)
                        },
                        set: { isOn in
                            if isOn {
                                if !user.selectedChallengeContributionTypes.contains(type) {
                                    user.selectedChallengeContributionTypes.append(type)
                                }
                            } else {
                                user.selectedChallengeContributionTypes.removeAll { $0 == type }
                            }
                        }
                    ))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Challenge Options")
        .navigationBarTitleDisplayMode(.inline)
    }
}
