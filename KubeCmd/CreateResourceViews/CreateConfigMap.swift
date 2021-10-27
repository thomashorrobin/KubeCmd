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
	var body: some View {
		Form{
			Text("New ConfigMap").font(.title2)
			TextField("Name", text: $name)
		}.padding(40).frame(width: 500, height: 300, alignment: .center)
	}
}

struct CreateConfigMap_Previews: PreviewProvider {
	//	core.v1.ConfigMap
	static var previews: some View {
		CreateConfigMap()
	}
}
