//
//  CreateConfigMap.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 06/10/2021.
//

import SwiftUI
import SwiftkubeModel

struct CreateConfigMap: View {
	@State private var name: String = ""
	@State private var keyValuePairs: [keyValuePair] = []
	@State private var keyStr: String = ""
	@State private var valueStr: String = ""
	var body: some View {
		Form{
			Text("New ConfigMap").font(.title2)
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
		}.padding(40).frame(width: 500, height: 300, alignment: .center)
	}
}

struct CreateConfigMap_Previews: PreviewProvider {
	//	core.v1.ConfigMap
	static var previews: some View {
		CreateConfigMap()
	}
}
