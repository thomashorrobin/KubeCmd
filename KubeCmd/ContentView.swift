//
//  ContentView.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/02/2021.
//

import SwiftUI
import CoreData
import SwiftkubeClient
import SwiftkubeModel

struct ContentView: View {
    @StateObject var resources = ClusterResources()
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    func loadData() -> Void {
        guard let client = client else {
            return
        }
        let strategy = RetryStrategy(
            policy: .maxAttemtps(20),
            backoff: .exponential(maximumDelay: 60, multiplier: 2.0)
        )
            do {
                let _ = try client.pods.watch(in: .default, retryStrategy: strategy) { (event, pod) in
                    print("\(event): \(pod.metadata!.uid!)")
                }
                let pods = try client.pods.list(in: .default).wait().items
                for pod in pods {
                    let uuid = try! UUID.fromK8sMetadata(resource: pod)
                    self.resources.pods[uuid] = pod
                }
                let configmaps = try client.configMaps.list(in: .default).wait().items
                for configmap in configmaps {
                    let uuid = try! UUID.fromK8sMetadata(resource: configmap)
                    self.resources.configmaps[uuid] = configmap
                }
                let secrets = try client.secrets.list(in: .default).wait().items
                for secret in secrets {
                    let uuid = try! UUID.fromK8sMetadata(resource: secret)
                    self.resources.secrets[uuid] = secret
                }
                let cronjobs = try client.batchV1Beta1.cronJobs.list(in: .default).wait().items
                for cronjob in cronjobs {
                    let uuid = try! UUID.fromK8sMetadata(resource: cronjob)
                    self.resources.cronjobs[uuid] = cronjob
                }
                let jobs = try client.batchV1.jobs.list(in: .default).wait().items
                for job in jobs {
                    let uuid = try! UUID.fromK8sMetadata(resource: job)
                    self.resources.jobs[uuid] = job
                }
                let deployments = try client.appsV1.deployments.list(in: .default).wait().items
                for deployment in deployments {
                    let uuid = try! UUID.fromK8sMetadata(resource: deployment)
                    self.resources.deployments[uuid] = deployment
                }
            } catch {
                print("Unknown error: \(error)")
            }
    }
    
    @State var buttonText = "Load data again"

    var body: some View {
        NavigationView
        {
            TopLevelK8sMenu()
            SecondLevelK8sItems()
            Button(action: {
                buttonText = "loading..."
                loadData()
                buttonText = "Load data again"
            }, label: {
                Text(buttonText)
            })
        }.environmentObject(resources).onAppear(perform: {
            loadData()
        }).toolbar(content: {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
            ToolbarItem(placement: .primaryAction) {
                Image(systemName: "plus")
            }
        })
    }
    
    func toggleSidebar() {
        NSApp.keyWindow?.contentViewController?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
