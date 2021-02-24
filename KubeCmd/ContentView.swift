//
//  ContentView.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/02/2021.
//

import SwiftUI
import CoreData
import SwiftkubeModel

class ClusterResources: ObservableObject {
    @Published var pods = [core.v1.Pod]()
    @Published var configmaps = [core.v1.ConfigMap]()
    @Published var secrets = [core.v1.Secret]()
}

struct ContentView: View {
    @StateObject var resources = ClusterResources()
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView{
            KubernetesMenuView()
            Text("hellos!!")
        }.environmentObject(resources).onAppear(perform: {
            do {
                self.resources.pods = try client?.pods.list(in: .default).wait().items ?? [core.v1.Pod]()
                self.resources.configmaps = try client?.configMaps.list(in: .default).wait().items ?? [core.v1.ConfigMap]()
                self.resources.secrets = try client?.secrets.list(in: .default).wait().items ?? [core.v1.Secret]()
            } catch {
                print("Unknown error: \(error)")
            }
        })
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
