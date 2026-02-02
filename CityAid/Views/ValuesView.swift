import SwiftUI

// MARK: - ValuesView
struct ValuesView: View {
    @Binding public var cardSelected: TypeOfContribution?
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
                
                GeometryReader { proxy in
                    let horizontalPadding = max((proxy.size.width - 200) / 2, 0)
                    
                    ZStack (alignment: .topLeading) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack (spacing: 20) {
                                
                                InfoCard(
                                    imageAddress: "CleanlinessCardBg",
                                    title: "Cleanliness",
                                    caption: "Clean our streets of litter and pollution.",
                                    cardSelected: .cleanliness,
                                    isSelected: cardSelected == .cleanliness
                                )
                                
                                InfoCard(
                                    imageAddress: "PlantcareCardBg",
                                    title: "Plant Care",
                                    caption: "Restore green spaces to help your city breathe.",
                                    cardSelected: .plantcare,
                                    isSelected: cardSelected == .plantcare
                                )
                                
                                InfoCard(
                                    imageAddress: "KindnessCardBg",
                                    title: "Kindness",
                                    caption: "Make people in your city feel loved and valued.",
                                    cardSelected: .kindness,
                                    isSelected: cardSelected == .kindness
                                )
                                
                                InfoCard(
                                    imageAddress: "DonationCardBg",
                                    title: "Donation",
                                    caption: "Donate to help those in need, or as a token of appreciation.",
                                    cardSelected: .donation,
                                    isSelected: cardSelected == .donation
                                )
                                
                                InfoCard(
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

private struct CardFramesKey: PreferenceKey {
    static var defaultValue: [TypeOfContribution: CGRect] = [:]
    static func reduce(value: inout [TypeOfContribution: CGRect], nextValue: () -> [TypeOfContribution: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// Returns the dimensions and position of each card using the scrollview's coordinate system
private extension View {
    func reportCardFrame(_ id: TypeOfContribution, in space: CoordinateSpace) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: CardFramesKey.self,
                                value: [id: geo.frame(in: space)])
            }
        )
    }
}

// MARK: - SourceView
struct SourceView: View {
    let type: TypeOfContribution
    @State private var sources: [AttributedString] = []
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Sources")
                .font(.system(size: 30, weight: .bold))
                .padding(.top, 12)
            Spacer()
            ForEach(sources, id: \.self) { source in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .padding(.top, 6)
                    Text(source)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }.padding(.vertical, 14).frame(maxWidth: 300)
        .onAppear() {
            switch (type) {
            case .cleanliness:
                sources = [
                    AttributedString("The State of the Environment: The Urban Environment", attributes: .init([.link: URL(string: "https://www.gov.uk/government/publications/state-of-the-environment/the-state-of-the-environment-the-urban-environment")!])), AttributedString("Littering Statistics and Facts", attributes: .init([.link: URL(string: "https://www.businesswaste.co.uk/waste-facts/littering-statistics-and-facts/")!])),
                    AttributedString("Litter: Its Impact on Local Communities", attributes: .init([.link: URL(string: "https://www.brailsfordandednastonparishcouncil.gov.uk/news/2021/01/litter-its-impact-on-local-communities")!]))]
            case .plantcare:
                sources = [
                    AttributedString("How Plants Can Change Your State of Mind", attributes: .init([.link: URL(string: "https://www.edgehill.ac.uk/news/2023/04/how-plants-can-change-your-state-of-mind/")!]))]
            case .kindness:
                sources = [
                    AttributedString("Caring and Sharing: Global Analysis of Happiness and Kindness", attributes: .init([.link: URL(string: "https://www.worldhappiness.report/ed/2025/caring-and-sharing-global-analysis-of-happiness-and-kindness/")!])), AttributedString("These Are the world's 20 Friendliest cities", attributes: .init([.link: URL(string: "https://www.timeout.com/news/these-are-the-worlds-20-friendliest-cities-according-to-locals-102725")!]))]
            case .donation:
                sources = [
                    AttributedString("Millions Give Less to Charity as Bills Rise and Interest Wanes", attributes: .init([.link: URL(string: "https://www.bbc.co.uk/news/articles/c36wgr4d03ko")!])), AttributedString("Research Shows Donations to the Homeless Reach a New Low", attributes: .init([.link: URL(string: "https://www.socialenterprise.org.uk/member-updates/research-shows-donations-to-the-homeless-reach-a-new-low/")!]))]

            case .animalcare:
                sources = [
                    AttributedString("UK Has Almost 250,000 Stray cats, First Study Estimates", attributes: .init([.link: URL(string: "https://www.theguardian.com/lifeandstyle/2021/oct/28/uk-has-almost-250000-urban-stray-cats-claims-first-detailed-study")!])), AttributedString("11 Facts about Animal Homelessness", attributes: .init([.link: URL(string: "https://dosomething.org/article/11-facts-about-animal-homelessness")!]))]
            default: sources = []
            }
        }
    }
}

// MARK: - Information
struct InfoCard: View {
    let imageAddress: String
    let title: String
    let caption: String
    let cardSelected: TypeOfContribution
    let isSelected: Bool
    
    @State private var isShowingSourcesPopover: Bool = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image(imageAddress)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .black, location: 0),
                                .init(color: .black, location: 0.3),
                                .init(color: .clear, location: 0.9)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .cornerRadius(20)
            
            ZStack() {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .frame(width: 25, height: 25)
                    .glassEffect(.clear.interactive())
                    .onTapGesture {
                        self.isShowingSourcesPopover = true
                    }
                    .popover(
                        isPresented: $isShowingSourcesPopover, arrowEdge: .bottom
                    ) {
                        SourceView(type: cardSelected)
                            .padding(15)
                            .presentationCompactAdaptation(horizontal: .popover, vertical: .sheet)
                    }
            }
            .offset(x: 80, y: -130)

            
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                    .minimumScaleFactor(0.8)
                
                Text(caption)
                    .font(.system(size: 12))
                    .italic()
                    .foregroundStyle(Color(.secondaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
            }
            .padding(.top, 225)
        }
        .frame(width: 200, height: 300)
        .scaleEffect(isSelected ? 1.0 : 0.8, anchor: .bottom)
        .saturation(isSelected ? 1.0 : 0.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.2), value: isSelected)
        .reportCardFrame(cardSelected, in: .named("cardScroll"))

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


struct infoSheet: View {
    @Environment(\.dismiss) private var dismiss
    let type: TypeOfContribution
    
    var config: TypeConfig {
        switch type.rawValue {
        case "Cleanliness":
            return .init(imageAddress: "CleanlinessBg",
                         title: "Cleanliness",
                         caption: "Clean our streets of litter and polution.",
                         cityEffects: ["62% of people in England drop litter", "Nine billion tonnes of litter ends up in the oceans across the planet each year", "Cleaning up litter from UK streets costs British taxpayers £500 million every year"],
                         mainInfo: "By helping clean up local streets and parks, you make your community safer, more welcoming, and healthier. Every piece of litter removed or area tidied encourages others to care for their surroundings to produce a lasting effect of change and sustainability.",
                         contributionOptions: ["Pick up litter", "Report damaged/vandalised areas to your local council", "Support local recycling programs"]
            )
        case "Plant Care":
            return .init(imageAddress: "PlantcareBg",
                         title: "Plant Care",
                         caption: "Restore green spaces to help your city breathe.",
                         cityEffects: ["Plant life in cities has overall been declining", "The NHS could save over £2 billion in treatment costs if everyone in England had equal access to good quality green space", "Plant life can have a positive effect on your mental health"],
                         mainInfo: "Not only do plants improve our quality of life, but they help reduce the risk of flooding, improve air quality, and provide habitats for wildlife. By taking care of local greenery, you contribute to a healthier environment for everyone.",
                         contributionOptions: ["Take care of local greenery", "Volunteer at parks or community gardens", "Report invasive species to your local council"],
            )
        case "Kindness":
            return .init(imageAddress: "KindnessBg",
                         title: "Kindness",
                         caption: "Make people in your city feel loved and valued.",
                         cityEffects: ["Porto, Portugal has been voted kindest city in the world, with 85% of locals saying their neighbours are kind", "The average adult does 2 acts of kindness a day"],
                         mainInfo: "Being kind to people not only can improve someone else's day, but it can have a positive impact on your own well-being. Simple acts of kindness can create a ripple effect of positivity that benefits everyone around you.",
                         contributionOptions: ["Spread positivity and kindness", "Offer your seat on the bus", "Help a neighbor with a task"],
            )
        case "Donation":
            return .init(imageAddress: "DonationBg",
                         title: "Donation",
                         caption: "Donate to help those in need, or as a token of appreciation.",
                         cityEffects: ["£15.4 billion was raised for charity in the UK in 2024", "Nearly 3 million emergency food parcels were donated to the food bank in 2024/25", "Only 4% of Brits gave money to the homeless in 2023"],
                         mainInfo: "Donating to charity or supporting local businesses can make a significant difference in someone's life. Whether it's a one-time gift or a regular contribution, every little bit helps.",
                         contributionOptions: ["Buy items for a person in need or donate money directly", "Support a local charity", "Donate to the food bank after your shopping"],
            )
        case "Animal Care":
            return .init(imageAddress: "AnimalcareBg",
                         title: "Animal Care",
                         caption: "Take care of animals in your city to help them thrive.",
                         cityEffects: ["An estimated 70 million cats are stray in the United States", "Only 1 out of every 10 dogs born will find a permanent home", "Approximately 2.7 million dogs and cats are killed every year because shelters are too full"],
                         mainInfo: "The biggest change you can make to help animals in need is fostering or adopting one from a shelter. Even small things, like safely sharing food or helping meet basic needs, can make a real difference in their wellbeing.",
                         contributionOptions: ["Help an animal in need", "Adopt animals from shelters", "Feed stray animals"],
            )
        default:
            return .init(imageAddress: "Error", title: "Error", caption: "Error", cityEffects: ["Error"], mainInfo: "Error", contributionOptions: ["Error"])
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                Image(config.imageAddress)
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
                Spacer().frame(height: 100)
                
                Text("\(config.title)")
                    .font(.system(size: 42, weight: .bold))
                
                Text("\(config.caption)")
                    .font(.system(size: 18, weight: .regular).italic())
                    .foregroundStyle(Color(.secondaryLabel))
                
                Text("\n🌆 City Effects ")
                    .font(.system(size: 20))

                ThickDivider()
                
                ForEach(config.cityEffects, id: \.self) { effect in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .padding(.top, 6)
                        Text(effect)
                    }
                }
                Text("\(config.mainInfo)").padding(.top, 10)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                
                Text("\n✅ What \(Text("you").italic()) can do to help:")
                    .font(Font.system(size: 20))
                
                ThickDivider()
                
                ForEach(config.contributionOptions, id: \.self) { option in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .padding(.top, 6)
                        Text(option)
                            .fixedSize(horizontal: false, vertical: true)
                        
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(.black))
    }
}

struct ThickDivider: View {
    var body: some View {
            Rectangle()
                .frame(height: 2)
                .foregroundStyle(.secondary.opacity(0.4))
                .padding(.vertical, 4)
        }}

#Preview {
    ValuesView(cardSelected: .constant(nil))
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            infoSheet(type: .cleanliness)
        }
}
