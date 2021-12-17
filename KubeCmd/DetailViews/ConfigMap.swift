//
//  ConfigMap.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/07/2021.
//

import SwiftUI
import SwiftkubeModel

struct ConfigMap: View {
	let configmap:core.v1.ConfigMap
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content:{
			if let metadata = configmap.metadata {
				MetaDataSection(metadata: metadata)
				Divider().padding(.vertical, 30)
			}
			if let data = configmap.data {
				KeyValueDetailPanel(data: data)
			} else {
				Text("No data")
			}
		})
	}
}

//struct ConfigMap_Previews: PreviewProvider {
//    static var previews: some View {
//        ConfigMap()
//    }
//}
