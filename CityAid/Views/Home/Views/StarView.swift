import SwiftUI

struct StarView: View {
    let star: Star
    let namespaceID: Namespace.ID
    var onTap: (() -> Void)? = nil
            
    @State var isInitialised: Bool = false
    
    @State var isTapped: Bool = false
    @State var glowScale: CGFloat = 1
    @State var rotation: Double = 135
    @State var scale: CGFloat = 0.5
    @State var opacity: Float = 0
    @State var blurRadius: CGFloat = 10
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let offset = sin(time * 0.5 + Double(star.basePosition.x)) * star.floatAmplifier
            Group {
                ZStack {
                    RadialGradient(
                        gradient: Gradient(colors: [star.color.opacity(isTapped ? 0.4 : 0.3), .black.opacity(0)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: star.width
                    )
                    .scaleEffect(glowScale)
                    .onAppear {
                        let delay = Double.random(in: 0...5)
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            
                            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                                glowScale = 1.2
                            }
                        }
                    }
                    
                    Image("Star")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: star.width, height: star.height)
                        .foregroundStyle(star.color.opacity(Double(opacity)))
                        .blur(radius: blurRadius)
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(scale)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: max(star.width, star.height) / 2))
            .frame(width: star.width + 20, height: star.height + 20, alignment: .center)
            .position(
                x: star.basePosition.x,
                y: star.basePosition.y + offset
            )
            .onTapGesture {
                onTap?()
                
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5, blendDuration: 0)) {
                    isTapped = true
                    scale = 1.15
                    glowScale = 1.25
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0)) {
                        isTapped = false
                        scale = 1.0
                        glowScale = 1.2
                    }
                }
            }
            
            .onAppear {
                if !isInitialised {
                    isInitialised = true
                    
                    // spin in
                    DispatchQueue.main.asyncAfter(deadline: .now() + star.basePosition.y / 2000) {
                        withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
                            rotation = 0
                            scale = 1
                            opacity = star.opacity
                            blurRadius = 0
                        }
                    }
                }
            }
        }
    }
}

