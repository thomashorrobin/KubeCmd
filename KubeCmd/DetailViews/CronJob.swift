//
//  CronJob.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/06/2021.
//

import SwiftUI
import SwiftkubeModel
import SwiftCron


struct SuspendButton: View {
	@EnvironmentObject var resources: ClusterResources
	let cronJob:batch.v1beta1.CronJob
	let suspended:Bool
	init(cronJob:batch.v1beta1.CronJob) {
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
		resources.unsuspendCronJob(cronjob: self.cronJob)
	}
	func suspendCronJob() -> Void {
		resources.suspendCronJob(cronjob: self.cronJob)
	}
}

struct CronJob: View {
	let cronJob:batch.v1beta1.CronJob
	init(res:KubernetesAPIResource) {
		self.cronJob = res as! batch.v1beta1.CronJob
	}
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content: {
			if let metadata = cronJob.metadata {
				MetaDataSection(metadata: metadata)
				Divider().padding(.vertical, 30)
			}
			if let spec = cronJob.spec {
				Text("Spec").font(.title2)
				if let parsedCronExpression = CronExpression(cronString: "\(spec.schedule) *") {
					Text("Schedule: \(parsedCronExpression.longDescription)")
					if let nextSchedualedDate = parsedCronExpression.getNextRunDateFromNow() {
						Text("Next Scheduled: \(nextSchedualedDate.description)")
					}
				}
				Text("Suspended: \(String(spec.suspend ?? true))")
			}
		})
	}
}

struct TriggerCronJobButton : View {
	let cronJob:batch.v1beta1.CronJob
	@EnvironmentObject var resources: ClusterResources
	var body: some View {
		Button(action: triggerCronJob, label: {
			Text("Trigger")
		})
	}
	func triggerCronJob() -> Void {
		let job = createJobFromCronJob(cronJob: self.cronJob)
		resources.addJob(job: job)
	}
}

func createJobFromCronJob(cronJob:batch.v1beta1.CronJob) -> batch.v1.Job {
	let tmp = cronJob.spec?.jobTemplate.spec
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
	let dateStr = dateFormatter.string(from: Date())
	let x = "\(cronJob.name ?? "terrible-error")-manual-\(dateStr)"
	var existingMetadata = cronJob.metadata
	existingMetadata?.name = x
	var job = batch.v1.Job()
	existingMetadata?.resourceVersion = nil
	job.spec = tmp
	job.metadata = existingMetadata
	return job
}

struct CronJob_Previews: PreviewProvider {
	static var previews: some View {
		CronJob(res: ClusterResources.dummyCronJob() as KubernetesAPIResource)
	}
}
