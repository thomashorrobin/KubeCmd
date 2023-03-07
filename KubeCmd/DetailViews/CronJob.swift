//
//  CronJob.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/06/2021.
//

import SwiftUI
import SwiftkubeModel


struct SuspendButton: View {
	@EnvironmentObject var resources: ClusterResources
	let cronJob:batch.v1.CronJob
	let suspended:Bool
	init(cronJob:batch.v1.CronJob) {
		self.suspended = cronJob.spec?.suspend ?? false
		self.cronJob = cronJob
	}
	var body: some View {
		if suspended {
			Button(action: unsuspendCronJob, label: {
				Text("Unsuspend")
			})
		} else {
			Button(action: suspendCronJob, label: {
				Text("Suspend")
			})
		}
	}
	func unsuspendCronJob() -> Void {
		Task {
			await resources.unsuspendCronJob(cronjob: self.cronJob)
		}
	}
	func suspendCronJob() -> Void {
		Task {
			await resources.suspendCronJob(cronjob: self.cronJob)
		}
	}
}

struct CronJob: View {
    var resources: ClusterResources
	let cronJob:batch.v1.CronJob
    var jobs:[batch.v1.Job]
	init(res:KubernetesAPIResource, resources: ClusterResources) {
		self.cronJob = res as! batch.v1.CronJob
        self.resources = resources
        jobs = [batch.v1.Job]()
        do {
            try jobs.append(contentsOf: cronJob.getJobs(jobs: resources.jobs.items))
        } catch  {
            print(error)
        }
	}
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content: {
			if cronJob.spec?.suspend ?? false {
				ColouredByLine(byLineText: "Suspended", byLineColor: Color.red)
			}
			if cronJob.metadata != nil {
				MetaDataSection(resource: cronJob)
				Divider().padding(.vertical, 30)
			}
			if let spec = cronJob.spec {
				Text("Spec").font(.title2)
				Text("Schedule: \(spec.schedule)")
				Text("Suspended: \(String(spec.suspend ?? true))")
			}
            if jobs.count > 0 {
                Divider().padding(.vertical, 30)
                Text("Jobs").font(.title2)
                ForEach(jobs, id: \.name) { job in
                    Text(job.name ?? "unknown").textSelection(.enabled)
                }
            }
		})
	}
}

struct TriggerCronJobButton : View {
	let cronJob:batch.v1.CronJob
	@EnvironmentObject var resources: ClusterResources
	var body: some View {
		Button(action: triggerCronJob, label: {
			Text("Trigger")
		})
	}
	func triggerCronJob() -> Void {
		do {
			let job = try self.cronJob.generateJob()
			Task {
				await resources.addJob(job: job)
			}
		} catch {
			print(error)
		}
	}
}

//struct CronJob_Previews: PreviewProvider {
//	static var previews: some View {
//		CronJob(res: ClusterResources.dummyCronJob() as KubernetesAPIResource)
//	}
//}
