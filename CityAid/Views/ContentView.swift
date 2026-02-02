//
//  ContentView.swift
//  CityAid
//
//  Created by Jake Wisbey on 19/11/2025.
//

import SwiftUI
import CoreLocation
import PhotosUI
internal import CoreData

extension Color {
    static func background(for colorScheme: ColorScheme) -> [Color] {
        colorScheme == .dark ? [Color("BgColor"), Color.black] : [Color("BgColor"), Color.white]
    }
}

// MARK: - ContentView
struct ContentView: View {
    @Namespace private var buttons
    @State private var isExpanded: Bool = false
    @State private var selectedType: TypeOfContribution? = nil
    @State private var infoSelectedType: TypeOfContribution? = nil
    @State private var selectedTab: Tab = .home
    @State private var valuesTabActive: Bool = false
    @State private var backgroundMode: BackgroundMode = .none

    @State var cardSelected: TypeOfContribution? = nil
    @State var levelCardSelected: UUID = levelMilestones.first!.id
    @State var totalContributionCardSelected: UUID = totalContributionMilestones.first!.id
    
    @State private var showStreakAnimation: Bool = false
    
    @StateObject private var user = UserData()
    
    var body: some View {
        ZStack {
            TabView (selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(Tab.home)
                ChallengesView(selectedLevelCard: $levelCardSelected, selectedTotalContributionCard: $totalContributionCardSelected)
                    .tabItem { Label("Challenges", systemImage: "crown") }
                    .tag(Tab.challenges)
                ValuesView(cardSelected: $cardSelected)
                    .tabItem { Label("Values", systemImage: "star") }
                    .tag(Tab.values)
                AccountView()
                    .tabItem { Label("Account", systemImage: "person.crop.circle.fill")}
                    .tag(Tab.account)
            }
            .environmentObject(user)
            
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == .values {
                    valuesTabActive = true
                }
                if oldValue == .values {
                    valuesTabActive = false
                }
            }
            
            
            Color.black
                .opacity(backgroundMode == .expanded ? 0.5 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) { backgroundMode = .none; isExpanded = false }
                }
                .animation(.easeOut(duration: 0.25), value: backgroundMode)
            
            LinearGradient(colors: [Color(red: 0/255, green: 0/255, blue: 30/255), .black.opacity(0.3)], startPoint: .top, endPoint: .center)
                .opacity(backgroundMode == .sheet ? 1 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) { isExpanded = false }
                }
                .animation(.easeOut(duration: 0.45), value: backgroundMode)

            
            GlassEffectContainer (spacing: 20) {
                ZStack {
                    Image(systemName: valuesTabActive ? "info.circle.text.page" : "plus")
                        .contentTransition(.symbolEffect(.replace))
                        .font(.system(size: 36))
                        .frame(width: 70, height: 70)
                        .contentShape(Rectangle())
                    
                        .glassEffect(.clear.interactive().tint(.blue))
                        .glassEffectID("button", in: buttons)
                    
                        .onTapGesture {
                            if !valuesTabActive {
                                withAnimation {
                                    isExpanded.toggle()
                                    if isExpanded { backgroundMode = .expanded }
                                    else { backgroundMode = .none }
                                }
                            }
                            else {
                                infoSelectedType = cardSelected
                                backgroundMode = .expanded
                            }
                        }
                    
                    contributionBubble(
                        iconName: "bubbles.and.sparkles",
                        id: "Cleanliness",
                        xCoord: -120,
                        yCoord: -20,
                        delay: 0.05,
                        typeOfContribution: .cleanliness,
                        isExpanded: $isExpanded,
                        selectedType: $selectedType,
                        backgroundMode: $backgroundMode,
                        buttons: buttons
                    )
                        
                    contributionBubble(
                        iconName: "leaf",
                        id: "Plant Care",
                        xCoord: -90,
                        yCoord: -80,
                        delay: 0.15,
                        typeOfContribution: .plantcare,
                        isExpanded: $isExpanded,
                        selectedType: $selectedType,
                        backgroundMode: $backgroundMode,
                        buttons: buttons
                    )
                                        
                    contributionBubble(
                        iconName: "heart",
                        id: "Kindness",
                        xCoord: -40,
                        yCoord: -130,
                        delay: 0.10,
                        typeOfContribution: .kindness,
                        isExpanded: $isExpanded,
                        selectedType: $selectedType,
                        backgroundMode: $backgroundMode,
                        buttons: buttons
                    )
                    
                    contributionBubble(
                        iconName: "gift",
                        id: "Donation",
                        xCoord: 30,
                        yCoord: -130,
                        delay: 0.05,
                        typeOfContribution: .donation,
                        isExpanded: $isExpanded,
                        selectedType: $selectedType,
                        backgroundMode: $backgroundMode,
                        buttons: buttons
                    )
                    
                    contributionBubble(
                        iconName: "dog",
                        id: "Animal Care",
                        xCoord: 90,
                        yCoord: -80,
                        delay: 0.20,
                        typeOfContribution: .animalcare,
                        isExpanded: $isExpanded,
                        selectedType: $selectedType,
                        backgroundMode: $backgroundMode,
                        buttons: buttons
                    )
                    
                    contributionBubble(
                        iconName: "ellipsis.circle",
                        id: "Other",
                        xCoord: 120,
                        yCoord: -20,
                        delay: 0.12,
                        typeOfContribution: .other,
                        isExpanded: $isExpanded,
                        selectedType: $selectedType,
                        backgroundMode: $backgroundMode,
                        buttons: buttons
                    )
                    
                }
                 
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity,
                alignment: .bottom)
            .padding(.bottom, 75)
            .ignoresSafeArea(.keyboard)
            
            .sheet(item: $infoSelectedType, onDismiss: { backgroundMode = .none }) { type in
                infoSheet(type: type)
                .navigationTransition(.zoom(sourceID: "transition-id", in: buttons))
            }
            .sheet(item: $selectedType, onDismiss: { backgroundMode = .none }) { type in
                NewContributionSheet(type: type, user: user)
                .navigationTransition(.zoom(sourceID: "transition-id", in: buttons))
                .onDisappear {
                    if !user.playedStreakAnimation && user.isStreakCompletedToday {
                        showStreakAnimation = true
                        user.playedStreakAnimation = true
                    }
                    
                    user.CalculateUserLevel()
                }
            }
            .overlay(
                Group {
                    if showStreakAnimation {
                        streakAnimation()
                            .transition(.opacity)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    withAnimation { showStreakAnimation = false }
                                }
                            }
                    }
                }
            )
        }
    }
}

// MARK: - Helpers
struct contributionBubble: View {
    let iconName: String
    let id: String
    let xCoord: CGFloat
    let yCoord: CGFloat
    let delay: Float
    let typeOfContribution: TypeOfContribution
    @Binding var isExpanded: Bool
    @Binding var selectedType: TypeOfContribution?
    @Binding var backgroundMode: BackgroundMode
    let buttons: Namespace.ID
    
    var body: some View {
        Image(systemName: iconName)
            .font(.headline)
            .opacity(isExpanded ? 1 : 0)

            .frame(width: 50, height: 50)
            .contentShape(Rectangle())
            .allowsHitTesting(isExpanded)

            .glassEffect(.clear.interactive())
            .glassEffectID(id, in: buttons)

            .onTapGesture {
                isExpanded = false
                selectedType = typeOfContribution
            }
            .offset(x: isExpanded ? xCoord : 0,
                    y: isExpanded ? yCoord : 0)
            
            .animation(.interpolatingSpring(stiffness: 190, damping: 22) .delay(TimeInterval(delay)), value: isExpanded
            )
            .onTapGesture {
                isExpanded = false
                backgroundMode = .sheet
                selectedType = typeOfContribution
            }
    }
}

struct streakAnimation: View {
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


enum Tab {
    case home
    case challenges
    case values
    case account
}

enum BackgroundMode {
    case none
    case expanded
    case sheet
}

#Preview {
    ContentView()
}

