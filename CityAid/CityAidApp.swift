//
//  CityAidApp.swift
//  CityAid
//
//  Created by Jake Wisbey on 19/11/2025.
//

import SwiftUI
internal import CoreData

@main
struct CityAidApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext,
                              persistenceController.container.viewContext)
        }
    }
}
