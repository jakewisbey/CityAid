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
    // User and Contributions
    @StateObject private var user = UserData()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ContributionEntity.date, ascending: false)]
    ) private var contributions: FetchedResults<ContributionEntity>
    
    // Animation handling
    @Namespace private var buttons
    @State private var isExpanded: Bool = false
    @State private var backgroundMode: BackgroundMode = .none
    
    @State var cardSelected: TypeOfContribution? = nil
    @State var levelCardSelected: UUID = levelMilestones.first!.id
    @State var totalContributionCardSelected: UUID = totalContributionMilestones.first!.id
    
    @State private var showStreakAnimation: Bool = false

    // Selected Types
    @State private var selectedType: TypeOfContribution? = nil
    @State public var infoSelectedType: TypeOfContribution? = nil
    
    // Values tab
    @State private var selectedTab: Tab = .home
    @State private var valuesTabActive: Bool = false
    
    var body: some View {
        ZStack {
            TabView (selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(Tab.home)
                ChallengesView(selectedLevelCard: $levelCardSelected, selectedTotalContributionCard: $totalContributionCardSelected)
                    .tabItem { Label("Challenges", systemImage: "crown") }
                    .tag(Tab.challenges)
                ValuesView(cardSelected: $cardSelected, infoSelectedType: $infoSelectedType, backgroundMode: $backgroundMode)
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
                    
                    ContributionBubble(
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
                        
                    ContributionBubble(
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
                                        
                    ContributionBubble(
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
                    
                    ContributionBubble(
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
                    
                    ContributionBubble(
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
                    
                    ContributionBubble(
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
            
            .sheet(item: $infoSelectedType, onDismiss: { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { backgroundMode = .none } }) { type in
                InfoSheet(type: type)
                .navigationTransition(.zoom(sourceID: "transition-id", in: buttons))
            }
            .sheet(item: $selectedType, onDismiss: { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { backgroundMode = .none } } ) { type in
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
                        StreakAnimation()
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
