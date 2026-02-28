import SwiftUI

struct QuickLogCountView: View {
    @Binding var quickLogs: [String: Int]

    var body: some View {
        List {
            Section(
                header: Text("QuickLog Counts")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.5)),
            footer: Text("Change the number of times you have completed a specific QuickLog. This will update the title of the QuickLog when you select it.")
            ) {
                ForEach(quickLogs.keys.sorted(), id: \.self) { key in
                    DisclosureGroup {
                        Stepper(
                            value: Binding(
                                get: { quickLogs[key] ?? 0 },
                                set: { newValue in
                                    quickLogs[key] = newValue
                                    UserDefaults.standard.set(quickLogs, forKey: "quickLogKey")
                                }
                            ),
                            in: 0...255,
                            step: 1
                        ) {
                            Text("Count: \(quickLogs[key] ?? 0)")
                        }
                    } label: {
                        HStack {
                            Text(key)
                            Spacer()
                            Text("\(quickLogs[key] ?? 0)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section(footer: Text("This will not remove your previous contributions.")) {
                Button("Reset all to 0") {
                    UserDefaults.standard.removeObject(forKey: "quickLogKey")
                    
                    let defaults: [String: Int] = [
                        "Litter-Picking": 0,
                        "Gave up my seat": 0,
                        "Cleared plant area": 0,
                        "Helped with directions": 0,
                        "Took someone's rubbish": 0,
                        "Helped an animal": 0,
                        "Held a door open": 0
                    ]
                    
                    UserDefaults.standard.set(defaults, forKey: "quickLogKey")
                    quickLogs = defaults
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("QuickLog Count")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            quickLogs = UserDefaults.standard.object(forKey: "quickLogKey") as? [String: Int] ?? [:]
        }
    }

}

#Preview {
    QuickLogCountView(quickLogs: .constant(UserDefaults.standard.object(forKey: "quickLogKey") as? [String: Int] ?? [:]))
}
