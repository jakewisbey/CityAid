import SwiftUI
internal import CoreData
import Charts

struct AllContributionsSheet: View {
    let user: UserData
    let contributions: FetchedResults<ContributionEntity>
    @Binding var backgroundMode: BackgroundMode
    @Binding var showStreakAnimation: Bool
    @State private var contributionToEdit: ContributionEntity? = nil
    
    @State private var selectedBarStyle: BarStyle = .bar
    @Namespace var editNamespace
    
    @Environment(\.managedObjectContext) private var context
    var contributionManager: ContributionManager {
        ContributionManager(user: user, context: context)
    }
    
    @State var contributionToDateDictionary: [Date: [ContributionEntity]] = [:]
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                NavigationStack {
                    List {
                        VStack {
                            HStack {
                                Picker("Style", selection: $selectedBarStyle) {
                                    Text("Bar").tag(BarStyle.bar)
                                    Text("Line").tag(BarStyle.line)
                                }
                                .pickerStyle(.segmented)
                                .frame(maxWidth: 200, alignment: .center)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 17)
                            
                            Chart {
                                ForEach(getContributionsThisWeek().keys.sorted(), id: \.self) { date in
                                    let count = getContributionsThisWeek()[date]?.count ?? 0
                                    
                                    if selectedBarStyle == .bar {
                                        BarMark(
                                            x: .value("Day", date),
                                            y: .value("Count", count)
                                        )
                                    } else if selectedBarStyle == .line {
                                        LineMark(
                                            x: .value("Day", date),
                                            y: .value("Count", count)
                                        )
                                        .interpolationMethod(.monotone)
                                        .lineStyle(StrokeStyle.init(lineWidth: 2))
                                    }
                                }
                            }
                            .chartYScale(domain: 0...max(3, (getContributionsThisWeek().values.map { $0.count }.max() ?? 0) + 1))
                            .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.2)
                            .padding(.leading, 10)
                            
                            .animation(.bouncy, value: contributions.count)
                            .animation(.bouncy, value: selectedBarStyle)
                        }
                        .listRowSeparator(.hidden)
                        
                        Section {
                            ForEach(contributions) { item in
                                ContributionRow(
                                    contributionManager: contributionManager,
                                    user: user,
                                    item: item,
                                    backgroundMode: $backgroundMode,
                                    showStreakAnimation: $showStreakAnimation
                                )
                                .transition(.opacity.combined(with: .scale))
                                .matchedTransitionSource(id: item.id, in: editNamespace)
                                .contentShape(Rectangle())
                                
                                .contextMenu {
                                    Button() {
                                        contributionToEdit = item
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    
                                    Menu {
                                        Button {
                                            contributionManager.duplicateContribution(contribution: item, duplicateDate: false, user: user)
                                        } label: {
                                            Label("Today's date", systemImage: "calendar")
                                        }
                                        
                                        Button {
                                            contributionManager.duplicateContribution(contribution: item, duplicateDate: true, user: user)
                                        } label: {
                                            Label("Keep original", systemImage: "calendar.badge.clock")
                                        }
                                    } label: {
                                        Label("Duplicate", systemImage: "document.on.document")
                                    }
                                    
                                    Button(role: .destructive) {
                                        contributionManager.deleteContribution(contribution: item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .listRowBackground(Color.black)
                    .navigationTitle("All Contributions")
                }
            }
            .sheet(item: $contributionToEdit, onDismiss: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    backgroundMode = .none
                }
            }) { contribution in
                EditContributionSheet(contribution: contribution, user: user, backgroundMode: $backgroundMode)
                    .navigationTransition(.zoom(sourceID: contribution.id, in: editNamespace))
            }
        }
    }
    
    func getContributionsThisWeek() -> [Date : [ContributionEntity]] {
        // get days this week
        let calendar = Calendar.current
        let now = Date()
        
        let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now))!
        
        var result: [Date: [ContributionEntity]] = [:]
    
        // add days to dictionary
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                let startOfDay = calendar.startOfDay(for: date)
                result[startOfDay] = []
            }
        }
        
        // find contributions that day and add
        for contribution in contributions {
            guard let date = contribution.date else {continue}
            let startOfDay = calendar.startOfDay(for: date)
            
            if result[startOfDay] != nil {
                result[startOfDay, default: []].append(contribution)
            }
        }
        
        // convert date to stuff like Mon Tues Wed etc (does this actually work?)
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        
        return result
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
            PreviewPersistenceController.shared.viewContext
        )
}

enum BarStyle {
    case bar
    case line
}
