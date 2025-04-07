//
//  effectMobileTestTaskApp.swift
//  effectMobileTestTask
//
//  Created by Роман on 08.04.2025.
//

import SwiftUI

@main
struct effectMobileTestTaskApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
