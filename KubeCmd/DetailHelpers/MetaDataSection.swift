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
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(5)){
            Text("Metadata").font(.title2)
            if let uuid = metadata.uid {
                Text("UUID: \(uuid)")
            }
            if let creationTimestamp = metadata.creationTimestamp {
                Text("Created: \(creationTimestamp)")
            }
            if let labels = metadata.labels {
                if labels.count > 0 {
                    Text("Labels")
                    ForEach((labels.sorted(by: >)), id: \.key) { label in
                        Text("\(label.key): \(label.value)").background(Color.gray)
                    }
                }
            }
        }
    }
}

struct MetaDataSection_Previews: PreviewProvider {
    static var previews: some View {
        MetaDataSection(metadata: meta.v1.ObjectMeta(annotations: ["kube-something": "this thing"], clusterName: "directlyapply", creationTimestamp: Date().addingTimeInterval(TimeInterval(86400 * 12 + 6000)), deletionGracePeriodSeconds: nil, deletionTimestamp: nil, finalizers: nil, generateName: nil, generation: nil, labels: ["node-requirement": "big-boy", "feed":"appcast"], managedFields: nil, name: "really-cool-kubernetes-resource", namespace: "default", ownerReferences: nil, resourceVersion: "meta/v1", selfLink: nil, uid: "DFF490E8-20E9-4564-8B0F-0BBAA2B333C2"))
    }
}
