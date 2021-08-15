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
                    VStack{
                        Text("Load from config file").font(.title2)
                        OpenConfigFileButton()
                    }.padding(.all, 20).frame(alignment: .leading)
                    Divider()
                    VStack{
                        Text("Load from kubectl").font(.title2)
                        Button("load local file"){
                            client = KubernetesClient()
                        }
                    }.padding(.all, 20)
                }.frame(width: 400, alignment: .leading)
            }
        }
        .commands {
            SidebarCommands()
        }
    }
}
