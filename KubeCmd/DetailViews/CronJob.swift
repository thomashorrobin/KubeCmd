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
		resources.unsuspendCronJob(cronjob: self.cronJob)
	}
	func suspendCronJob() -> Void {
		resources.suspendCronJob(cronjob: self.cronJob)
	}
}

struct CronJob: View {
	let cronJob:batch.v1.CronJob
	init(res:KubernetesAPIResource) {
		self.cronJob = res as! batch.v1.CronJob
	}
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content: {
			if cronJob.spec?.suspend ?? false {
				JobStatusBarStat(nameXXX: "Suspended", ccc: Color.red, ii: 1)
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
			resources.addJob(job: job)
		} catch {
			print(error)
		}
	}
}

struct CronJob_Previews: PreviewProvider {
	static var previews: some View {
		CronJob(res: ClusterResources.dummyCronJob() as KubernetesAPIResource)
	}
}
