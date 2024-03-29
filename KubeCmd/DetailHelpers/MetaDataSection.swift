//
//  MetaDataSection.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 09/08/2021.
//

import SwiftUI
import SwiftkubeModel

struct MetaDataSection: View {
    let resource:any KubernetesAPIResource
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
							KubernetesLabel(key: label.key, value: label.value)
						}
					}
				}
			}
		}
	}
}


struct SheetView: View {
	var dismiss:() -> Void
	@State var labels: [String:String]
	var submit:(_ values: [String:String]) -> Void
	@State private var key: String = ""
	@State private var value: String = ""
	var body: some View {
		VStack(alignment: .leading) {
			Text("Labels").font(.title)
			ForEach(labels.sorted(by: >), id: \.key, content: { x in
				HStack{
					Text("\(x.key): \(x.value)")
					Button(action: {
						labels.removeValue(forKey: x.key)
					}) {
						Image(systemName: "x.circle")
					}.buttonStyle(PlainButtonStyle())
				}
			})
			TextField("key", text: $key)
			TextField("value", text: $value)
			HStack(spacing: 30) {
				HStack{
					Button("Cancel") {
						dismiss()
					}
					Button("Add") {
						labels[key] = value
						key = ""
						value = ""
					}.disabled(key == "" || value == "")
				}
				Button("Save") {
					self.submit(labels)
				}.buttonStyle(.borderedProminent)
			}
		}
		.padding(.all, 100)	}
}
