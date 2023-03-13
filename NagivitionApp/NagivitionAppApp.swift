//
//  NagivitionAppApp.swift
//  NagivitionApp
//
//  Created by Arianne Xaing on 09/03/2023.
//

import SwiftUI

@main
struct NagivitionAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
