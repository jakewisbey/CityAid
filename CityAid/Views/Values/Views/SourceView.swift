import SwiftUI

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
