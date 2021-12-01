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
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	let persistenceController = PersistenceController.shared
	
	@State var client:KubernetesClient? = nil
	
	func loadKubernetesClientFromConfig(client: KubernetesClient) -> Void {
		self.client = client
	}
	
	var body: some Scene {
		WindowGroup {
			if let client = client {
				ContentView(resources: ClusterResources(client: client))
					.environment(\.managedObjectContext, persistenceController.container.viewContext)
			} else {
				StartupScreen { client in
					self.client = client
				}
			}
		}
		.commands {
			SidebarCommands()
			CreateResourceCommands(activeClient: self.client != nil)
			CommandGroup(replacing: .newItem) {}
			CommandGroup(replacing: .undoRedo) {}
		}
	}
}
