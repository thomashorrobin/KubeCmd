//
//  CreateConfigMap.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 06/10/2021.
//

import SwiftUI

struct CreateConfigMap: View {
    var body: some View {
        Text("New ConfigMap").font(.title2).frame(width: 500, height: 300, alignment: .bottomLeading)
    }
}

struct CreateConfigMap_Previews: PreviewProvider {
    static var previews: some View {
        CreateConfigMap()
    }
}
