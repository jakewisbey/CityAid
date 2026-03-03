import SwiftUI

struct StreakAnimation: View {
    let oldStreak: Int
    let newStreak: Int

    @State private var showBackground: Bool = false
    @State private var showGlow: Bool = false
    @State private var showIcon: Bool = false
    @State private var showStreakNumbers: Bool = false
    @State private var animateNumbers: Bool = false
    @State private var pulseSaturationStart: Double = 1

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ZStack {
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.red.opacity(1),
                            Color.orange.opacity(0.7),
                            Color.white.opacity(0),
                        ]),
                        center: .bottom,
                        startRadius: 0,
                        endRadius: 600
                    )
                    .frame(width: 700, height: 700)
                    .clipShape(Circle())
                    .opacity(showGlow ? 1 : 0)
                    .animation(.spring(duration: 1), value: showGlow)
                    
                    VStack {
                        Text("🔥")
                            .font(.system(size: 100, weight: .bold))
                            .opacity(showIcon ? 1 : 0)
                            .animation(.spring(duration: 1), value: showIcon)
                            .padding(.bottom, showIcon ? 150 : 100)
                            .saturation(animateNumbers ? 1 : pulseSaturationStart)
                            .animation(.spring(duration: 1), value: animateNumbers)
                    }
                    
                    VStack {
                        Text(String(oldStreak))
                            .font(.system(size: 80, weight: .bold))
                            .opacity(showStreakNumbers ? 1 : 0)
                            .animation(.spring(duration: 1), value: showStreakNumbers)
                            .padding(.bottom, showStreakNumbers ? -75 : 0)
                            .padding(.trailing, animateNumbers ? 150 : 0)
                            .opacity(animateNumbers ? 0 : 1)
                            .animation(.spring(duration: 1), value: animateNumbers)
                    }
                    
                    VStack {
                        Text(String(newStreak))
                            .font(.system(size: 80, weight: .bold))
                            .animation(.spring(duration: 1), value: showStreakNumbers)
                            .padding(.bottom, showStreakNumbers ? -75 : 0)
                            .padding(.leading, animateNumbers ? 0 : 120)
                            .opacity(animateNumbers ? 1 : 0)
                            .animation(.spring(duration: 1), value: animateNumbers)
                    }
                    
                    VStack {
                        Text("Streak increased!")
                            .font(.system(size: 20, weight: .bold))
                            .animation(.spring(duration: 1), value: showStreakNumbers)
                            .padding(.top, showIcon ? 200 : 0)
                            .opacity(showIcon ? 1 : 0)
                            .animation(.spring(duration: 1), value: showIcon)
                    }
                }
                .position(x: geo.size.width * 0.5, y: geo.size.height * 0.85)
            }
        }
        .opacity(showBackground ? 0.95 : 0)
        .animation(.spring(duration: 1), value: showBackground)
        .allowsHitTesting(false)
        .onAppear {
            pulseSaturationStart = (oldStreak == 0) ? 0 : 1

            showBackground = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { showGlow = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.40) { showIcon = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { showStreakNumbers = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { animateNumbers = true }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { showBackground = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { showGlow = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { showIcon = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { showStreakNumbers = false }
        }
    }
}

#Preview {
    StreakAnimation(oldStreak: 0, newStreak: 1)
}
