//
//  ContentView.swift
//  CityAid
//
//  Created by Jake Wisbey on 19/11/2025.
//

import SwiftUI
import PhotosUI
internal import CoreData
import Combine

struct ContentView: View {
    // User and Contributions
    @StateObject private var user = UserData()

    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ContributionEntity.date, ascending: false)]
    ) private var contributions: FetchedResults<ContributionEntity>
    
    // Animation handling
    @Namespace private var buttons
    @Namespace private var infoNamespace
    @State private var isExpanded: Bool = false
    @State private var selectedBubbleID: String = ""
    @State private var backgroundMode: BackgroundMode = .none
    
    @State private var quickLogIsExpanded: Bool = false
    
    @State var cardSelected: TypeOfContribution? = nil
    @State var levelCardSelected: UUID = levelMilestones.first!.id
    @State var totalContributionCardSelected: UUID = totalContributionMilestones.first!.id
    @State private var showAllContributions: Bool = false
    
    // Animation and Onboarding
    @State private var showStreakAnimation: Bool = false
    @State private var showOnboarding: Bool = false
    @State private var popped = false
    

    // Selected Types
    @State private var selectedType: TypeOfContribution? = nil
    @State public var infoSelectedType: TypeOfContribution? = nil
    
    // Values tab
    @State private var selectedTab: Tab = .home
    @State private var valuesTabActive: Bool = false
    
    
    // Time management
    var challengeManager: ChallengeManager {
        ChallengeManager(user: user)
    }
    
    var body: some View {
        ZStack {
            TabView (selection: $selectedTab) {
                HomeView(backgroundMode: $backgroundMode, showStreakAnimation: $showStreakAnimation)
                    .tabItem { Label("Home", systemImage: "house.fill") }
                
                    .tag(withAnimation {Tab.home} )
                ChallengesView(selectedLevelCard: $levelCardSelected, selectedTotalContributionCard: $totalContributionCardSelected)
                    .tabItem { Label("Challenges", systemImage: "crown") }
                    .tag(withAnimation{Tab.challenges})
                ValuesView(cardSelected: $cardSelected, infoSelectedType: $infoSelectedType, backgroundMode: $backgroundMode, infoNamespace: infoNamespace)
                    .tabItem { Label("Values", systemImage: "star") }
                    .tag(withAnimation{Tab.values})
                AccountView()
                    .tabItem { Label("Account", systemImage: "person.crop.circle.fill")}
                    .tag(withAnimation{Tab.account})
            }
            
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == .values {
                    withAnimation {
                        valuesTabActive = true
                    }
                }
                if oldValue == .values {
                    withAnimation {
                        valuesTabActive = false
                    }
                }
            }
            
            
            Color.black
                .opacity(backgroundMode == .expanded ? 0.5 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(backgroundMode == .expanded)
                .onTapGesture {
                    withAnimation(.spring()) { backgroundMode = .none; isExpanded = false; quickLogIsExpanded = false }
                }
                .animation(.easeOut(duration: 0.25), value: backgroundMode)
            
            LinearGradient(colors: [Color(red: 0/255, green: 0/255, blue: 30/255), .black.opacity(0.3)], startPoint: .top, endPoint: .center)
                .opacity(backgroundMode == .sheet ? 1 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(backgroundMode == .sheet)
                .onTapGesture {
                    withAnimation(.spring()) { backgroundMode = .none }
                }
                .animation(.easeOut(duration: 0.45), value: backgroundMode)
            
            GeometryReader { geo in
                RadialGradient(
                    gradient: Gradient(colors: [.black.opacity(0.8), .black.opacity(0.6), .black.opacity(0)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 800
                )
                .frame(width: 1600, height: 1600)
                .clipShape(Circle())
                .opacity(backgroundMode == .quickLog ? 1 : 0)
                .allowsHitTesting(backgroundMode == .quickLog)
                .onTapGesture {
                    withAnimation(.spring()) { backgroundMode = .none; quickLogIsExpanded = false }
                }
                .animation(.easeOut(duration: 0.45), value: backgroundMode)
                .position(x: geo.size.width, y: geo.size.height * 0.5)
            }

            
            GlassEffectContainer(spacing: 20) {
                GeometryReader { geo in
                    // Hold Add button and ContributionBubbles
                    ZStack {
                        // ContributionBubbles
                        if !quickLogIsExpanded && !valuesTabActive && selectedTab != .account {
                            ContributionBubble(
                                iconName: "bubbles.and.sparkles",
                                id: "Cleanliness",
                                originXCoord: geo.size.width * 0.5,
                                originYCoord: geo.size.height * 0.94,
                                xCoord: -120,
                                yCoord: -20,
                                delay: 0.05,
                                typeOfContribution: .cleanliness,
                                isExpanded: $isExpanded,
                                selectedType: $selectedType,
                                backgroundMode: $backgroundMode,
                                selectedBubbleID: $selectedBubbleID,
                                buttons: buttons
                            )
                            
                            ContributionBubble(
                                iconName: "leaf",
                                id: "Plant Care",
                                originXCoord: geo.size.width * 0.5,
                                originYCoord: geo.size.height * 0.94,
                                xCoord: -90,
                                yCoord: -80,
                                delay: 0.15,
                                typeOfContribution: .plantcare,
                                isExpanded: $isExpanded,
                                selectedType: $selectedType,
                                backgroundMode: $backgroundMode,
                                selectedBubbleID: $selectedBubbleID,
                                buttons: buttons
                            )
                            
                            ContributionBubble(
                                iconName: "heart",
                                id: "Kindness",
                                originXCoord: geo.size.width * 0.5,
                                originYCoord: geo.size.height * 0.94,
                                xCoord: -40,
                                yCoord: -130,
                                delay: 0.10,
                                typeOfContribution: .kindness,
                                isExpanded: $isExpanded,
                                selectedType: $selectedType,
                                backgroundMode: $backgroundMode,
                                selectedBubbleID: $selectedBubbleID,
                                buttons: buttons
                            )
                            
                            ContributionBubble(
                                iconName: "gift",
                                id: "Donation",
                                originXCoord: geo.size.width * 0.5,
                                originYCoord: geo.size.height * 0.94,
                                xCoord: 30,
                                yCoord: -130,
                                delay: 0.05,
                                typeOfContribution: .donation,
                                isExpanded: $isExpanded,
                                selectedType: $selectedType,
                                backgroundMode: $backgroundMode,
                                selectedBubbleID: $selectedBubbleID,
                                buttons: buttons
                            )
                            
                            ContributionBubble(
                                iconName: "dog",
                                id: "Animal Care",
                                originXCoord: geo.size.width * 0.5,
                                originYCoord: geo.size.height * 0.94,
                                xCoord: 90,
                                yCoord: -80,
                                delay: 0.20,
                                typeOfContribution: .animalcare,
                                isExpanded: $isExpanded,
                                selectedType: $selectedType,
                                backgroundMode: $backgroundMode,
                                selectedBubbleID: $selectedBubbleID,
                                buttons: buttons
                            )
                            
                            ContributionBubble(
                                iconName: "ellipsis.circle",
                                id: "Other",
                                originXCoord: geo.size.width * 0.5,
                                originYCoord: geo.size.height * 0.94,
                                xCoord: 120,
                                yCoord: -20,
                                delay: 0.12,
                                typeOfContribution: .other,
                                isExpanded: $isExpanded,
                                selectedType: $selectedType,
                                backgroundMode: $backgroundMode,
                                selectedBubbleID: $selectedBubbleID,
                                buttons: buttons
                            )
                        }
                        
                        if !isExpanded && !valuesTabActive && !popped {
                            QuickLogBubble(
                                           title: "Litter-Picking",
                                           type: .cleanliness,
                                           originXCoord: geo.size.width * 1.2,
                                           originYCoord: geo.size.height * 0.50,
                                           xCoord: geo.size.width * 0.7,
                                           yCoord: geo.size.height * 0.36,
                                           iconName: "trash",
                                           delay: 0.1,
                                           user: user,
                                           showStreakAnimation: $showStreakAnimation,
                                           quickLogIsExpanded:$quickLogIsExpanded,
                                           backgroundMode: $backgroundMode,
                                           buttons: buttons)
                            
                            QuickLogBubble(
                                           title: "Gave up my seat",
                                           type: .kindness,
                                           originXCoord: geo.size.width * 1.2,
                                           originYCoord: geo.size.height * 0.50,
                                           xCoord: geo.size.width * 0.67,
                                           yCoord: geo.size.height * 0.43,
                                           iconName: "figure.seated.side.right.child.lap",
                                           delay: 0.05,
                                           user: user,
                                           showStreakAnimation: $showStreakAnimation,
                                           quickLogIsExpanded: $quickLogIsExpanded,
                                           backgroundMode: $backgroundMode,
                                           buttons: buttons)
                            
                            QuickLogBubble(
                                           title: "Helped with directions",
                                           type: .kindness,
                                           originXCoord: geo.size.width * 1.2,
                                           originYCoord: geo.size.height * 0.50,
                                           xCoord: geo.size.width * 0.59,
                                           yCoord: geo.size.height * 0.5,
                                           iconName: "map",
                                           delay: 0.00,
                                           user: user,
                                           showStreakAnimation: $showStreakAnimation,
                                           quickLogIsExpanded: $quickLogIsExpanded,
                                           backgroundMode: $backgroundMode,
                                           buttons: buttons)
                            
                            QuickLogBubble(
                                           title: "Took someone's trash",
                                           type: .cleanliness,
                                           originXCoord: geo.size.width * 1.2,
                                           originYCoord: geo.size.height * 0.5,
                                           xCoord: geo.size.width * 0.60,
                                           yCoord: geo.size.height * 0.57,
                                           iconName: "bubbles.and.sparkles",
                                           delay: 0.05,
                                           user: user,
                                           showStreakAnimation: $showStreakAnimation,
                                           quickLogIsExpanded: $quickLogIsExpanded,
                                           backgroundMode: $backgroundMode,
                                           buttons: buttons)
                            
                            QuickLogBubble(
                                           title: "Helped an animal",
                                           type: .animalcare,
                                           originXCoord: geo.size.width * 1.2,
                                           originYCoord: geo.size.height * 0.5,
                                           xCoord: geo.size.width * 0.66,
                                           yCoord: geo.size.height * 0.64,
                                           iconName: "carrot",
                                           delay: 0.1,
                                           user: user,
                                           showStreakAnimation: $showStreakAnimation,
                                           quickLogIsExpanded: $quickLogIsExpanded,
                                           backgroundMode: $backgroundMode,
                                           buttons: buttons)
                        }
                        
                        if !quickLogIsExpanded && selectedTab != .account {
                            ZStack {
                                Group {
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            .blue.opacity(0.2), .clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 60
                                    )
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    
                                    Image(systemName: valuesTabActive ? "info.circle.text.page" : "plus")
                                        .contentTransition(.symbolEffect(.replace))
                                        .font(.system(size: 36))
                                        .frame(width: 70, height: 70)
                                        .contentShape(Rectangle())
                                        .glassEffect(.clear.interactive().tint(.blue))
                                    
                                        .clipShape(Circle())
                                        .opacity(!quickLogIsExpanded ? 1 : 0)
                                        .allowsHitTesting(!quickLogIsExpanded)
                                        .onTapGesture {
                                            popped = false
                                            if !valuesTabActive {
                                                withAnimation {
                                                    isExpanded.toggle()
                                                    backgroundMode = isExpanded ? .expanded : .none
                                                }
                                            } else {
                                                infoSelectedType = cardSelected
                                                backgroundMode = .expanded
                                            }
                                        }
                                }
                                .position(x: geo.size.width * 0.5, y: geo.size.height * 0.94)

                                
                                if !isExpanded {
                                    Image(systemName: "list.bullet.clipboard")
                                        .font(.system(size: 22))
                                        .padding(.bottom, 2) // didnt look aligned for some reason
                                        .frame(width: 50, height: 50)
                                        .matchedTransitionSource(id: "AllContributionsButton", in: buttons)
                                        .glassEffect(.clear.interactive())
                                        .contentShape(Rectangle())
                                        .clipShape(Circle())
                                        .position(x: geo.size.width * 0.73, y: geo.size.height * 0.94)
                                        .onTapGesture {
                                            showAllContributions = true
                                        }

                                }
                                
                            }
                        }
                    }
                    
                    if selectedTab == .home {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.ultraThinMaterial)
                                .blur(radius: quickLogIsExpanded ? 10 : 0)
                                .frame(width: 100, height: 100)
                                .offset(x: quickLogIsExpanded || isExpanded ? 10 : 0)
                                .contentShape(Rectangle().inset(by: -40))
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: popped)
                                .onTapGesture {
                                    withAnimation {
                                        popped = true
                                        backgroundMode = .expanded
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        withAnimation {
                                            popped = false
                                            
                                            if !isExpanded { backgroundMode = .none }
                                        }
                                    }
                                }
                                .allowsHitTesting(!popped && !quickLogIsExpanded)
                            
                            
                            Text("Swipe left!")
                                .font(.system(size: 25, weight: .bold))
                                .opacity(popped ? 1 : 0)
                                .offset(x: popped ? -130 : -100)
                                .blur(radius: popped ? 0 : 10)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: popped)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .position(x: !popped ? geo.size.width * 1.1 : geo.size.width * 1.08, y: geo.size.height/2)
                    }
                }
            }
            .padding(.bottom, 75)
            .ignoresSafeArea(.keyboard)
            
            
            // All Contributions Sheet
            .sheet(isPresented: $showAllContributions, onDismiss: { backgroundMode = .none}
            ){
                AllContributionsSheet(user: user, contributions: contributions, backgroundMode: $backgroundMode, showStreakAnimation: $showStreakAnimation)
                    .navigationTransition(.zoom(sourceID: "AllContributionsButton", in: buttons))
            }

            // Onboarding Sheet
            .sheet(isPresented: $showOnboarding, onDismiss: {
                user.hasOpenedBefore = true
            }) {
                OnboardingSheet()
            }

            // Info Sheet
            .sheet(item: $infoSelectedType, onDismiss: { backgroundMode = .none }) { type in
                InfoSheet(type: type)
                    .navigationTransition(.zoom(sourceID: type.rawValue, in: infoNamespace))
            }
            
            // New Contribution Sheet
            .sheet(item: $selectedType, onDismiss: { backgroundMode = .none } ) { type in
                NewContributionSheet(type: type, user: user, backgroundMode: $backgroundMode, showStreakAnimation: $showStreakAnimation)
                    .navigationTransition(.zoom(sourceID: selectedBubbleID, in: buttons))
            }
            .onChange(of: contributions.count) {
                if !user.playedStreakAnimation && user.isStreakCompletedToday {
                    showStreakAnimation = true
                    user.playedStreakAnimation = true
                }
            }
            .overlay(
                Group {
                    if showStreakAnimation {
                        StreakAnimation(
                            oldStreak: max(user.streak - 1, 0),
                            newStreak: user.streak
                        )
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                withAnimation { showStreakAnimation = false }
                            }
                        }
                    }
                }
            )
        }
        .preferredColorScheme(.dark)
        .environmentObject(user)
        .simultaneousGesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    // swipe from right to left
                    if value.startLocation.x > UIScreen.main.bounds.width * 0.9 &&
                        value.translation.width < -50 && !popped && !isExpanded && selectedTab == .home {
                        quickLogIsExpanded = true
                        backgroundMode = .quickLog
                    }
                    
                    if value.translation.width > 0 && quickLogIsExpanded {
                        quickLogIsExpanded = false
                        backgroundMode = .none
                    }

                }
        )
        .onAppear {
            showOnboarding = !user.hasOpenedBefore
            challengeManager.handleDailyReset()
            challengeManager.handleWeeklyReset()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .NSCalendarDayChanged
            )
        ) { _ in
            challengeManager.handleDailyReset()
            challengeManager.handleWeeklyReset()
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
    case quickLog
}



struct PreviewPersistenceController {
    static let shared: NSPersistentContainer = {
        // Use the same model name used elsewhere in previews
        let container = NSPersistentContainer(name: "CityAidModel")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // important for previews
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("preview store failed: \(error)")
            }
        }

        let context = container.viewContext

        // Seed example contributions
        let sampleTypes = ["Cleanliness", "Kindness", "Donation", "Animal Care", "Plant Care", "Other"]
        for i in 0..<8 {
            let contribution = ContributionEntity(context: context)
            contribution.id = UUID()
            contribution.date = Date().addingTimeInterval(Double(-i) * 86400)
            contribution.title = "Preview Contribution \(i + 1)"
            contribution.type = sampleTypes[i % sampleTypes.count]
            contribution.notes = "This is a preview note for contribution \(i + 1)."
        }

        do {
            try context.save()
        } catch {
            fatalError("preview save failed: \(error)")
        }

        return container
    }()
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
            PreviewPersistenceController.shared.viewContext
        )
}
