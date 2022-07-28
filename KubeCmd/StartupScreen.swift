//
//  StartupScreen.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 01/12/2021.
//

import SwiftUI
import SwiftkubeClient
import UniformTypeIdentifiers

struct StartupScreen: View {
	var setConfig:(KubernetesClient) -> Void
	@State private var showingFailedLoadAlert = false
	var body: some View {
		VStack{
			Image("splash-icon").resizable().scaledToFit().frame(width: 180, height: 180, alignment: .center).padding(.all, 15)
			Text("KubeCmd").font(.largeTitle)
			Divider()
			Text("note").font(.headline)
			Text("To use KubeCmd you need to have a Kubernetes config file. This is the same file kubectl uses to connect to the cluster and can normally be found at ~/.kube/config\nIf you are using a cloud provider to host your cluster you can often download the config file from their management console").padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/).fixedSize(horizontal: false, vertical: true)
			Divider()
			Button("connect", action: openFile).buttonStyle(LinkButtonStyle()).padding(.vertical, 40).font(.title2)
		}.frame(width: 400, alignment: .center).alert(isPresented: $showingFailedLoadAlert, content: {
			Alert(title: Text("yaml file failed to load"))
		})
	}
	func openFile() -> Void {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.showsHiddenFiles = true
		panel.allowedContentTypes = [UTType(filenameExtension: "yaml")!, UTType(filenameExtension: "yml")!]
		if panel.runModal() == .OK {
			print(panel.url?.path ?? "<none>")
			if let u = panel.url {
				if let client = KubernetesClient(fromURL: URL(fileURLWithPath: u.path)) {
					setConfig(client)
				} else {
					showingFailedLoadAlert = true
				}
			}
		}
	}
}

struct StartupScreen_Previews: PreviewProvider {
	static var previews: some View {
		StartupScreen { KubernetesClient in
			
		}
	}
}
