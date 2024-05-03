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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
