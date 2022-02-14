//
//  Job.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/07/2021.
//

import SwiftUI
import SwiftkubeModel

struct Job: View {
	var job:batch.v1.Job
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content: {
			if job.metadata != nil {
				MetaDataSection(resource: job)
			}
			if let status = job.status {
				Divider().padding(.vertical, 30)
				Text("Status").font(.title2)
				if let startTime = status.startTime {
					Text("Start Time: \(startTime)").textSelection(.enabled)
				}
				if let completionTime = status.completionTime {
					Text("Completion Time: \(completionTime)").textSelection(.enabled)
				}
			}
			if let spec = job.spec {
				Divider().padding(.vertical, 30)
				Text("Spec").font(.title2)
				Text("Active Deadline Seconds: \(spec.activeDeadlineSeconds ?? 0)").textSelection(.enabled)
				Text("Backoff Limit: \(spec.backoffLimit ?? 0)").textSelection(.enabled)
				Text("Completions: \(spec.completions ?? 0)").textSelection(.enabled)
				Text("Parallelism: \(spec.parallelism ?? 0)").textSelection(.enabled)
				Text("TTL Seconds After Finished: \(spec.ttlSecondsAfterFinished ?? 0)").textSelection(.enabled)
			}
		})
	}
}

//struct Job_Previews: PreviewProvider {
//    static var previews: some View {
//        Job()
//    }
//}
