//
//  PersistenceController.swift
//  CityAid
//
//  Created by Jake Wisbey on 21/12/2025.
//


internal import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "CityAidModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("core data failed \(error)")
            }
        }
    }
}
