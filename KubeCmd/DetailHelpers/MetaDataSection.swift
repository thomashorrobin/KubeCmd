//
//  MetaDataSection.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 09/08/2021.
//

import SwiftUI
import SwiftkubeModel

struct MetaDataSection: View {
	let metadata:meta.v1.ObjectMeta
	@EnvironmentObject var resources: ClusterResources
	@State private var showingSheet = false
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5)){
			Text("Metadata").font(.title2)
			if let uuid = metadata.uid {
				Text("UUID: \(uuid)")
			}
			if let creationTimestamp = metadata.creationTimestamp {
				Text("Created: \(creationTimestamp)")
			}
			if let namespace = metadata.namespace {
				Text("Namespace: \(namespace)")
			}
			if let labels = metadata.labels {
				if labels.count > 0 {
					Text("Labels")
					ForEach((labels.sorted(by: >)), id: \.key) { label in
						HStack{
							Text("\(label.key): \(label.value)").padding(.all, 6)
							Button(action: {
								resources.deleteLabel(resource: try! parseUUID(), key: label.key)
							}) {
								Image(systemName: "x.circle")
							}.buttonStyle(PlainButtonStyle())
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
					resources.addLabel(resource: try! parseUUID(), key: key, value: value)
					showingSheet = false
				}
			}
		}
	}
	private func parseUUID() throws -> UUID {
		guard let uid = metadata.uid else { throw UUIDErrors.noUid }
		guard let uuid = UUID(uuidString: uid) else { throw
			UUIDErrors.parseError}
		return uuid
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
