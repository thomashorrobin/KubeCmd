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
    
    let pubsub = PubSubBoillerPlate()
    
    var body: some Scene {
        WindowGroup {
            MainAppContainer(pubsub: pubsub)
        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .undoRedo) {
                Button("Reload Data") {
                    Task {
                        await pubsub.Publish()
                    }
                }.keyboardShortcut("r")
            }
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

struct MainAppContainer: View {
    let persistenceController = PersistenceController.shared
    let pubsub: PubSubBoillerPlate
    
    @State var client:KubernetesClient? = nil
    func setClientNil() -> Void {
        client = nil
    }
    
    var body: some View {
        if let client = client, let resources = try? ClusterResources(client: client, pubsub: pubsub) {
            ContentView(resources: resources, setClientNil: setClientNil)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        } else {
            StartupScreen { client in
                self.client = client
            }
        }
    }
}

class PubSubBoillerPlate {
    private var functionsToCall: [() async throws -> Void]
    init() {
        functionsToCall = [() -> Void]()
    }
    public func Publish() async {
        for call in functionsToCall {
            do {
                try await call()
            } catch {
                print(error)
            }
        }
    }
    public func Subscribe(fn: @escaping () async throws -> Void) {
        functionsToCall.append(fn)
    }
}
