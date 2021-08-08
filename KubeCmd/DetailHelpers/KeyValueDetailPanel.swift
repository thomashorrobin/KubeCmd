//
//  KeyValueDetailPanel.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 07/08/2021.
//

import SwiftUI

struct KeyValueDetailPanel: View {
    var data:[String:String]
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(5), content: {
            Text("Data").font(.title2)
            ForEach((data.sorted(by: >)), id: \.key) { x in
                Text(x.key)
                Text(x.value).italic()
            }
        })
    }
}

struct KeyValueDetailPanel_Previews: PreviewProvider {
    static var previews: some View {
        KeyValueDetailPanel(data: ["JOB_GEOCODER_SERVICE":"localhost:3000",
                                   "JOB_DESCRIPTION_NLP_EXTR":"188.166.139.231",
                                   "ELASTIC_TOKEN":"ZWxhc3RpYzp6allqYjR6Nm1udDBVeGYxV05ETmdweXU="])
    }
}
