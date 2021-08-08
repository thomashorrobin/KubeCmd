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
    init(res:KubernetesAPIResource) {
        self.configmap = res as! core.v1.ConfigMap
    }
    var body: some View {
        if let data = configmap.data {
            KeyValueDetailPanel(data: data)
        } else {
            Text("No data")
        }
    }
}

//struct ConfigMap_Previews: PreviewProvider {
//    static var previews: some View {
//        ConfigMap()
//    }
//}
