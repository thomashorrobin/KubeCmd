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
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content: {
			if pod.metadata != nil {
				MetaDataSection(resource: pod)
				Divider().padding(.vertical, 30)
			}
			if let status = pod.status {
				Text("Status").font(.title2)
				if let reason = status.reason {
					Text("Reason: \(reason)").textSelection(.enabled)
				}
				if let message = status.message {
					Text("Message: \(message)").textSelection(.enabled)
				}
				if let startTime = status.startTime {
					Text("Start Time: \(startTime)").textSelection(.enabled)
				}
				if let phase = status.phase {
					Text("Phase: \(phase)").textSelection(.enabled)
				}
			}
		})
	}
}

//struct Pod_Previews: PreviewProvider {
//    static var previews: some View {
//        Pod()
//    }
//}
