//
//  KubeCmdApp.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/02/2021.
//

import SwiftUI
import SwiftkubeClient
import UniformTypeIdentifiers

struct BlueButton: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.background(Color.blue)
			.foregroundColor(.white)
			.clipShape(Capsule())
	}
}

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
				VStack{
					Image("splash-icon").resizable().scaledToFit().frame(width: 180, height: 180, alignment: .center).padding(.all, 15)
					Text("KubeCmd").font(.largeTitle)
					Button("Open", action: openFile).buttonStyle(LinkButtonStyle()).padding(.vertical, 40).font(.title2)
				}.frame(width: 400, alignment: .center)
			}
		}
		.commands {
			SidebarCommands()
		}
	}
	func openFile() -> Void {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.allowedContentTypes = [UTType(filenameExtension: "yaml")!, UTType(filenameExtension: "yml")!]
		if panel.runModal() == .OK {
			print(panel.url?.path ?? "<none>")
			if let u = panel.url {
				let url = URL(fileURLWithPath: u.path)
				self.client = KubernetesClient(fromURL: url)
			}
		}
	}
}
