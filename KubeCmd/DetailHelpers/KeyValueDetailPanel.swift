//
//  KeyValueDetailPanel.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 07/08/2021.
//

import SwiftUI

struct KeyValueDetailPanel: View {
    var data:[String:String]
    var pasteboard:NSPasteboard
    init(data:[String:String]) {
        self.data = data
        pasteboard = NSPasteboard.general
        self.pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(5), content: {
            Text("Data").font(.title2)
            ForEach((data.sorted(by: >)), id: \.key) { x in
                Text(x.key)
                HStack{
                    Text(x.value).italic().background(Color.white)
                    Button(action: {
                            self.pasteboard.setString(x.value, forType: NSPasteboard.PasteboardType.string)                            }) {
                        Image(systemName: "doc.on.doc")
                    }
                }
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
