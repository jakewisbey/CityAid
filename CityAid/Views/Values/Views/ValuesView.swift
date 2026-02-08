import SwiftUI

// MARK: - ValuesView
struct ValuesView: View {
    @Binding public var cardSelected: TypeOfContribution?
    @Binding public var infoSelectedType: TypeOfContribution?
    @Binding public var backgroundMode: BackgroundMode
    @State private var cardFrames: [TypeOfContribution: CGRect] = [:]
    @State private var viewport: CGRect = .zero
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                Image("CityScape")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                    .padding(.top, -40)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .black, location: 0),
                                .init(color: .black, location: 0.3),
                                .init(color: .clear, location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer().frame(height: 130)
                Text("Why do your contributions matter?")
                    .font(.system(size: 32, weight: .bold))
                Text("Every contribution counts - even a one-time act of kindness can make a lasting difference in your community. Learn how and why each action makes an impact.")
                    .font(.system(size: 16).italic())
                    .foregroundStyle(Color(.secondaryLabel))
                
                GeometryReader { proxy in
                    let horizontalPadding = max((proxy.size.width - 200) / 2, 0)
                    
                    ZStack (alignment: .topLeading) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack (spacing: 20) {
                                
                                InfoCard(
                                    infoSelectedType: $infoSelectedType, backgroundMode: $backgroundMode,
                                    imageAddress: "CleanlinessCardBg",
                                    title: "Cleanliness",
                                    caption: "Clean our streets of litter and pollution.",
                                    cardSelected: .cleanliness,
                                    isSelected: cardSelected == .cleanliness
                                )
                                
                                InfoCard(
                                    infoSelectedType: $infoSelectedType,
                                    backgroundMode: $backgroundMode,
                                    imageAddress: "PlantcareCardBg",
                                    title: "Plant Care",
                                    caption: "Restore green spaces to help your city breathe.",
                                    cardSelected: .plantcare,
                                    isSelected: cardSelected == .plantcare
                                )
                                
                                InfoCard(
                                    infoSelectedType: $infoSelectedType, backgroundMode: $backgroundMode,
                                    imageAddress: "KindnessCardBg",
                                    title: "Kindness",
                                    caption: "Make people in your city feel loved and valued.",
                                    cardSelected: .kindness,
                                    isSelected: cardSelected == .kindness
                                )
                                
                                InfoCard(
                                    infoSelectedType: $infoSelectedType, backgroundMode: $backgroundMode,
                                    imageAddress: "DonationCardBg",
                                    title: "Donation",
                                    caption: "Donate to help those in need, or as a token of appreciation.",
                                    cardSelected: .donation,
                                    isSelected: cardSelected == .donation
                                )
                                
                                InfoCard(
                                    infoSelectedType: $infoSelectedType, backgroundMode: $backgroundMode,
                                    imageAddress: "AnimalcareCardBg",
                                    title: "Animal Care",
                                    caption: "Take care of animals in your city to help them thrive.",
                                    cardSelected: .animalcare,
                                    isSelected: cardSelected == .animalcare
                                )
                            }
                            .scrollTargetLayout()

                        }
                        .padding(.top, 26)
                        .scrollTargetBehavior(.viewAligned)
                        .safeAreaPadding(.horizontal, horizontalPadding)
                        .coordinateSpace(name: "cardScroll")
                        .overlay(
                            GeometryReader { scrollProxy in
                                Color.clear
                                    .onAppear {
                                        let rect = scrollProxy.frame(in: .named("cardScroll"))
                                        viewport = rect
                                    }
                                    .onChange(of: scrollProxy.size) { _, _ in
                                        let rect = scrollProxy.frame(in: .named("cardScroll"))
                                        viewport = rect
                                    }
                            }
                            .allowsHitTesting(false)
                        )
                    }
                    .onPreferenceChange(CardFramesKey.self) { frames in
                        cardFrames = frames
                        updateSelectedCardByCenter()
                    }
                }
            }
            .padding(16)
        }
        


        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .ignoresSafeArea()
        .onAppear {
            if cardSelected == nil {
                cardSelected = .cleanliness
            }
        }
    }
    
    
    private func updateSelectedCardByCenter() {
        guard !viewport.isEmpty else { return }

        let centerX = viewport.midX
        var best: (TypeOfContribution, CGFloat)? = nil

        for (id, frame) in cardFrames {
            let distance = abs(frame.midX - centerX)
            if let current = best {
                if distance < current.1 {
                    best = (id, distance)
                }
            } else {
                best = (id, distance)
            }
        }

        if let best = best {
            withAnimation(.easeInOut(duration: 0.15)) {
                cardSelected = best.0
            }
        }
    }
}


struct TypeConfig {
    let imageAddress: String
    let title: String
    let caption: String
    let cityEffects: [String]
    let mainInfo: String
    let contributionOptions: [String]
}



struct ThickDivider: View {
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .foregroundStyle(.secondary.opacity(0.4))
            .padding(.vertical, 4)
    }
}

#Preview {
    ValuesView(cardSelected: .constant(nil), infoSelectedType: .constant(nil), backgroundMode: .constant(.none))
}
