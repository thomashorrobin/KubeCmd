//
//  CreateConfigMap.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 06/10/2021.
//

import SwiftUI
import SwiftkubeModel
import SwiftkubeClient

struct CreateConfigMap: View {
	@State private var name: String = ""
	@State private var keyValuePairs: [keyValuePair] = []
	@State private var keyStr: String = ""
	@State private var valueStr: String = ""
	@State private var namespace: String = "default"
	var onConfigMapCreate:(core.v1.ConfigMap) -> Void
	var body: some View {
		VStack{
			ScrollView(showsIndicators: true){
				Form{
					Text("New ConfigMap").font(.title2)
					TextField("Name", text: $name)
					TextField("Namespace", text: $namespace).disabled(true)
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
				}
			}
			Button("Create"){
				var keyValuePairsMapped:[String:String] = [String:String]()
				for kvp in keyValuePairs {
					keyValuePairsMapped[kvp.id] = kvp.value
				}
				let configMap = sk.configMap(name: self.name) {
					$0.data = keyValuePairsMapped
				}
				onConfigMapCreate(configMap)
			}
		}.padding(40).frame(width: 500, height: 300, alignment: .center)
	}
}

struct CreateConfigMap_Previews: PreviewProvider {
	static var previews: some View {
		CreateConfigMap(onConfigMapCreate: {_ in })
	}
}
