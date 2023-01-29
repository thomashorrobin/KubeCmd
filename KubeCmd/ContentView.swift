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
	@StateObject var resources:ClusterResources
	
	@Environment(\.managedObjectContext) private var viewContext
	
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
		animation: .default)
	private var items: FetchedResults<Item>
	
	@State var buttonText = "Load data again"
	
	var setClientNil: () -> Void
	
	@State var errors = [Error]()
	@State private var showingErrorsAlert = false
	private func getErrorsAsString() -> Text? {
		if errors.isEmpty {
			return nil
		}
		let descriptions = errors.map { e in
			return e.localizedDescription
		}
		return Text(descriptions.joined(separator: "\n"))
	}
	
	var body: some View {
		NavigationView
		{
			TopLevelK8sMenu().frame(minWidth: 290, idealWidth: 390)
			SecondLevelK8sItems().frame(minWidth: 290, idealWidth: 390)
			Button(action: {
				buttonText = "loading..."
				Task {
					try await resources.refreshData()
					try await resources.fetchNamespaces()
				}
				buttonText = "Load data again"
			}, label: {
				Text(buttonText)
			}).frame(width: 250, height: 500)
		}.environmentObject(resources).onAppear(perform: {
			let startUpErrors = [Error]()
			Task {
				try await resources.refreshData()
			}
			Task {
				try await resources.fetchNamespaces()
			}
			resources.connectWatches()
//			do {
//				try resources.connectWatches()
//			} catch {
//				startUpErrors.append(error)
//			}
			if !startUpErrors.isEmpty {
				errors = startUpErrors
				showingErrorsAlert = true
			}
		}).onDisappear(perform: {
			resources.disconnectWatches()
			setClientNil()
		}).toolbar(content: {
			ToolbarItem(placement: .navigation) {
				Button(action: toggleSidebar, label: {
					Image(systemName: "sidebar.left")
				})
			}
			ToolbarItem(placement: .primaryAction) {
				Menu{
					Picker("Namespace", selection: $resources.namespace) {
						ForEach(resources.namespaces.items, id: \.name) { ns in
							Text(ns.name!).tag(NamespaceSelector.namespace(ns.name!))
						}
					}
					.pickerStyle(InlinePickerStyle())
				} label: {
					Label("Namespace Filter", systemImage: "square.on.square.dashed")
				}
			}
		}).frame(minWidth: 1290).alert(isPresented: $showingErrorsAlert, content: {
			Alert(title: Text("errors:"), message: getErrorsAsString(), dismissButton: .default(Text("dismiss")) {
				errors = []
			})
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
