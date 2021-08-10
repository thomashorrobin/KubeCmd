//
//  KubeCmdApp.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/02/2021.
//

import SwiftUI
import SwiftkubeClient

@main
struct KubeCmdApp: App {
    let persistenceController = PersistenceController.shared
    
    let client = KubernetesClient()

    var body: some Scene {
        WindowGroup {
            if let client = client {
                ContentView(resources: ClusterResources(client: client))
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                Text("error loading content").frame(width: 500, height: 400, alignment: .center)
            }
        }
        .commands {
            SidebarCommands()
        }
    }
}
