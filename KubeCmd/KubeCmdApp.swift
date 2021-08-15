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
    
    @State var client:KubernetesClient? = nil

    var body: some Scene {
        WindowGroup {
            if let client = client {
                ContentView(resources: ClusterResources(client: client))
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                VStack{
                    OpenConfigFileButton()
                    Divider()
                    Button("load local file"){
                        client = KubernetesClient()
                    }
                }.frame(width: 800, height: 600)
            }
        }
        .commands {
            SidebarCommands()
        }
    }
}
