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
	func setClientNil() -> Void {
		client = nil
	}
	
	var body: some Scene {
		WindowGroup {
			if let client = client {
				ContentView(resources: try! ClusterResources(client: client), setClientNil: setClientNil)
					.environment(\.managedObjectContext, persistenceController.container.viewContext)
			} else {
				StartupScreen { client in
					self.client = client
				}
			}
		}
		.commands {
			SidebarCommands()
			CreateResourceCommands(client: client)
			CommandGroup(replacing: .undoRedo) {}
			CommandGroup(replacing: .help) {
				Text("Cloud connections")
				Link("AWS", destination: URL(string: "https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html")!)
				Link("Azure", destination: URL(string: "https://docs.microsoft.com/en-us/azure/aks/control-kubeconfig-access")!)
				Link("Google Cloud", destination: URL(string: "https://cloud.google.com/sdk/gcloud/reference/container/clusters/get-credentials")!)
				Link("Digital Ocean", destination: URL(string: "https://docs.digitalocean.com/reference/doctl/reference/kubernetes/cluster/kubeconfig/")!)
			}
		}
	}
}
