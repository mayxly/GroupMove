//
//  GroupMoveApp.swift
//  GroupMove
//
//  Created by May Ly on 2024-04-27.
//

import SwiftUI

@main
struct GroupMoveApp: App {
    let persistenceController = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
