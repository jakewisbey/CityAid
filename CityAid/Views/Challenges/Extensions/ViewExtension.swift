import SwiftUI

struct LevelCardFramesKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct TotalContributionCardFramesKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

public extension View {
    func reportLevelCardFrame(_ id: UUID, in space: CoordinateSpace) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: LevelCardFramesKey.self,
                                value: [id: geo.frame(in: space)])
            }
        )
    }
    
    func reportTotalContributionCardFrame(_ id: UUID, in space: CoordinateSpace) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: TotalContributionCardFramesKey.self,
                                value: [id: geo.frame(in: space)])
            }
        )
    }
}
