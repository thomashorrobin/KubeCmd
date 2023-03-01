//
//  Job.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/07/2021.
//

import SwiftUI
import SwiftkubeModel

struct Job: View {
    var resources: ClusterResources
	var job:batch.v1.Job
    var pods:[core.v1.Pod]
    init(job: batch.v1.Job, resources: ClusterResources) {
        self.job = job
        self.resources = resources
        self.pods = [core.v1.Pod]()
        do {
            try pods.append(contentsOf: job.getPods(pods: resources.pods))
        } catch  {
            print(error)
        }
    }
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content: {
			if let status = job.status {
				makeJobStatusBar(status: status)
			}
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
            if pods.count > 0 {
                Divider().padding(.vertical, 30)
                Text("Pods").font(.title2)
                ForEach(pods, id: \.name) { pod in
                    Text(pod.name ?? "unknown").textSelection(.enabled)
                }
            }
		})
    }
}

func makeJobStatusBar(status:batch.v1.JobStatus) -> ColouredByLine? {
	if status.active != nil && status.active! > 0 {
		return ColouredByLine(byLineText: "running", byLineColor: Color.yellow)
	}
	if status.succeeded != nil && status.succeeded! > 0 {
		return ColouredByLine(byLineText: "succeeded", byLineColor: Color.green)
	}
	return ColouredByLine(byLineText: "failed", byLineColor: Color.red)
}

//struct Job_Previews: PreviewProvider {
//    static var previews: some View {
//        Job()
//    }
//}
