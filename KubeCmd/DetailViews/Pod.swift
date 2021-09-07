//
//  Pod.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/07/2021.
//

import SwiftUI
import SwiftkubeModel

struct Pod: View {
    var pod:core.v1.Pod
    init(res:KubernetesAPIResource) {
        self.pod = res as! core.v1.Pod
    }
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(5), content: {
            if let metadata = pod.metadata {
                MetaDataSection(metadata: metadata)
                Divider().padding(.vertical, 30)
            }
			if let status = pod.status {
            Text("Status").font(.title2)
				if let reason = status.reason {
					Text("Reason: \(reason)")
				}
				if let message = status.message {
					Text("Message: \(message)")
				}
				if let startTime = status.startTime {
					Text("Start Time: \(startTime)")
				}
				if let phase = status.phase {
					Text("Phase: \(phase)")
				}
            Divider().padding(.vertical, 30)
				LogsHandler(podName: pod.name!)
			}
        })
    }
}

//struct Pod_Previews: PreviewProvider {
//    static var previews: some View {
//        Pod()
//    }
//}
