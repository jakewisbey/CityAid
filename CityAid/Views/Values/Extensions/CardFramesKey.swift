import SwiftUI

struct CardFramesKey: PreferenceKey {
    static var defaultValue: [TypeOfContribution: CGRect] = [:]
    static func reduce(value: inout [TypeOfContribution: CGRect], nextValue: () -> [TypeOfContribution: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// Returns the dimensions and position of each card using the scrollview's coordinate system
extension View {
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
