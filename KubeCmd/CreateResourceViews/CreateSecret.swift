//
//  CreateSecret.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 06/10/2021.
//

import SwiftUI

struct keyValuePair : Identifiable {
	var id: String
	var value: String
}

struct CreateSecret: View {
	@State private var name: String = ""
	@State private var keyValuePairs: [keyValuePair] = []
	@State private var keyStr: String = ""
	@State private var valueStr: String = ""
	var body: some View {
		ScrollView{
			Form{
				Text("New Secret").font(.title2)
				TextField("Name", text: $name)
				Section("KeyValue Pairs") {
					ForEach(keyValuePairs, content: { x in
						VStack{
							Text(x.id)
							Text(x.value)
						}.padding(10)
					})
					TextField("Key", text: $keyStr)
					TextField("Value", text: $valueStr)
					Button("Add"){
						keyValuePairs.append(keyValuePair(id: keyStr, value: valueStr))
						keyStr = ""
						valueStr = ""
					}.disabled(keyStr.isEmpty || valueStr.isEmpty)
				}
				Button("Create"){
					print("hi")
				}
			}
		}.padding(40).frame(width: 500, height: 300, alignment: .center)
	}
}

struct CreateSecret_Previews: PreviewProvider {
	static var previews: some View {
		CreateSecret()
	}
}
