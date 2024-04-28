//
//  GroupMoveApp.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-27.
//

import SwiftUI

@main
struct GroupMoveApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
