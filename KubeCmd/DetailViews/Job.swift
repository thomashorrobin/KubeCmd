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
			JobStatusBar(status: job.status)
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

struct JobStatusBar: View {
	var status:batch.v1.JobStatus?
	var body: some View {
		if let status = status {
			HStack{
				JobStatusBarStat(nameXXX: "succeeded", ccc: Color.green, ii: status.succeeded)
				JobStatusBarStat(nameXXX: "running", ccc: Color.yellow, ii: status.active)
				JobStatusBarStat(nameXXX: "failed", ccc: Color.red, ii: status.failed)
			}
		} else {
			EmptyView()
		}
	}
}

struct JobStatusBarStat: View {
	private let name:String
	private let c:Color
	private let i:Int32
	init(nameXXX:String, ccc:Color, ii:Int32?) {
		name = nameXXX
		c = ccc
		if let xixixi = ii {
			i = xixixi
		} else {
			i = 0
		}
	}
	var body: some View {
		HStack{
			Text(name).bold().foregroundColor(c)
			Text(i.description)
		}
	}
}

//struct Job_Previews: PreviewProvider {
//    static var previews: some View {
//        Job()
//    }
//}
