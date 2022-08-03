//
//  MetaDataSection.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 09/08/2021.
//

import SwiftUI
import SwiftkubeModel

struct MetaDataSection: View {
	let resource:MetadataHavingResource
	@EnvironmentObject var resources: ClusterResources
	@State private var showingSheet = false
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5)){
			Text("Metadata").font(.title2)
			if let metadata = resource.metadata {
				if let uuid = metadata.uid {
					Text("UUID: \(uuid)").textSelection(.enabled)
				}
				if let creationTimestamp = metadata.creationTimestamp {
					Text("Created: \(creationTimestamp)").textSelection(.enabled)
				}
				if let namespace = metadata.namespace {
					Text("Namespace: \(namespace)").textSelection(.enabled)
				}
				if let labels = metadata.labels {
					if labels.count > 0 {
						Text("Labels")
						ForEach((labels.sorted(by: >)), id: \.key) { label in
							KubernetesLabel(key: label.key, value: label.value, delete: {
//								let x = resources.removeLabel(metadata: metadata, key: label.key)
								resources.dropLabelCronjob(cronJob: metadata.name!, name: label.key)
							})
						}
					}
				}
			}
		}
		Button("Add label") {
			showingSheet.toggle()
		}
		.sheet(isPresented: $showingSheet) {
			SheetView(dismiss: {
				showingSheet = false
			}) { key, value in
				if let metadata = resource.metadata {
					resources.addLabelCronjob(cronJob: metadata.name!, name: key, value: value)
				}
				showingSheet = false
			}
		}
	}
}


struct SheetView: View {
	var dismiss:() -> Void
	var submit:(_ key: String, _ value: String) -> Void
	@State private var key: String = ""
	@State private var value: String = ""
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("Add Lable").font(.title2)
			TextField("key", text: $key)
			TextField("value", text: $value)
			HStack{
				Button("Cancel") {
					dismiss()
				}
				Button("Add") {
					self.submit(key, value)
					
				}.disabled(key == "" || value == "")
			}
		}
		.padding(.all, 100)	}
}
