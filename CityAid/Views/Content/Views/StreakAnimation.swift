import SwiftUI

struct StreakAnimation: View {
    @State private var showBackground: Bool = false
    @State private var showGlow: Bool = false
    @State private var showIcon: Bool = false
    @State private var showStreakNumbers: Bool = false
    @State private var animateNumbers: Bool = false
    @State private var pulseSaturationStart: Double = 1
    
    let user = UserData()
    @State private var oldStreak: Int = 0
    @State private var newStreak: Int = 0
    
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .position(x: 201, y: 178)

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
            .position(x: 201, y: 600)
            
            VStack {
                Text("🔥")
                    .font(Font.system(size: 100, weight: .bold, design: .default))
                    .opacity(showIcon ? 1 : 0)
                    .animation(.spring(duration: 1), value: showIcon)
                    .padding(.bottom, showIcon ? 150 : 100)
                    .saturation(animateNumbers ? 1 : pulseSaturationStart)
                    .animation(.spring(duration: 1), value: animateNumbers)
                }
            VStack {
                Text(String(oldStreak))
                    .font(Font.system(size: 80, weight: .bold, design: .default))
                    .opacity(showStreakNumbers ? 1 : 0)
                    .animation(.spring(duration: 1), value: showStreakNumbers)
                    .padding(.bottom, showStreakNumbers ? -75 : 0)
                    .padding(.trailing, animateNumbers ? 150 : 0)
                    .opacity(animateNumbers ? 0 : 1)
                    .animation(.spring(duration: 1), value: animateNumbers)
            }
            VStack {
                Text(String(newStreak))
                    .font(Font.system(size: 80, weight: .bold, design: .default))
                    .animation(.spring(duration: 1), value: showStreakNumbers)
                    .padding(.bottom, showStreakNumbers ? -75 : 0)
                    .padding(.leading, animateNumbers ? 0 : 120)
                    .opacity(animateNumbers ? 1 : 0)
                    .animation(.spring(duration: 1), value: animateNumbers)
            }
            
            VStack {
                Text("Streak increased!")
                    .font(Font.system(size: 20, weight: .bold, design: .default))
                    .animation(.spring(duration: 1), value: showStreakNumbers)
                    .padding(.top, showIcon ? 200 : 0)
                    .opacity(showIcon ? 1 : 0)
                    .animation(.spring(duration: 1), value: showIcon)
            }
        }
        .opacity(showBackground ? 0.95 : 0)
        .animation(.spring(duration: 1), value: showBackground)
        .position(x: 201, y: 600)
        .onAppear() {
            oldStreak = max(user.streak - 1, 0)
            newStreak = user.streak
            if (oldStreak == 0) {pulseSaturationStart = 0} else {pulseSaturationStart = 1}
            showBackground = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { showGlow = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.40) { showIcon = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { showStreakNumbers = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { animateNumbers = true }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { showBackground = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { showGlow = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { showIcon = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { showStreakNumbers = false }
        }
        .allowsHitTesting(false)
    }
}
