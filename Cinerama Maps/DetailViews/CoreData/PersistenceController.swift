//
//  PersistenceController.swift
//  Cinerama Maps
//
//  Created by Farooq Haroon on 10/1/25.
//


import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "MapDetails")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print("📂 Core Data DB Path: \(storeDescription.url?.path ?? "Not found")")
        }

//        container.loadPersistentStores { desc, error in
//            print("📂 Core Data DB Path: \(storeDescription.url?.path ?? "Not found")")
//
//            if let error = error {
//                fatalError("Core Data failed to load: \(error)")
//            }
//
//        }
    }
}
