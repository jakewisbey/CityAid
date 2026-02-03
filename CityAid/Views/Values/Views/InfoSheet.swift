import SwiftUI

struct InfoSheet: View {
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

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            InfoSheet(type: .cleanliness)
        }
}
