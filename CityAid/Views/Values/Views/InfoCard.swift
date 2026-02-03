import SwiftUI

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
