//
//  KubeCmdApp.swift
//  Shared
//
//  Created by Thomas Horrobin on 29/12/2020.
//

import SwiftUI

@main
struct KubeCmdApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
