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
	@State private var showingUpdateCronSheet = false
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content: {
			if cronJob.metadata != nil {
				MetaDataSection(resource: cronJob)
				Divider().padding(.vertical, 30)
			}
			if let spec = cronJob.spec {
				Text("Spec").font(.title2)
				if let parsedCronExpression = CronExpression(cronString: "\(spec.schedule) *") {
					HStack{
						Text("Schedule: \(parsedCronExpression.longDescription)").textSelection(.enabled)
						Button("Update") {
							showingUpdateCronSheet = true
						}
					}
					if let nextSchedualedDate = parsedCronExpression.getNextRunDateFromNow() {
						Text("Next Scheduled: \(nextSchedualedDate.description)")
					}
				}
				Text("Suspended: \(String(spec.suspend ?? true))")
			}
		}).sheet(isPresented: $showingUpdateCronSheet, onDismiss: {
			showingUpdateCronSheet = false
		}) {
			UpdateCronView(dismiss: {
				showingUpdateCronSheet = false
		 })
		}
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

struct UpdateCronView: View {
	@EnvironmentObject var resources: ClusterResources
	@State private var cron: String = ""
	@State private var cronError: Bool = false
	@State private var parsedCronExpression:CronExpression? = nil
	var dismiss:() -> Void
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("New cron").font(.title)
			TextField("*/10 * * *", text: $cron)
			CronBuilder()
			if cronError {
				Text("error: cron couldn't be parsed").font(.footnote).foregroundColor(.red)
			}
			if let parsedCronExpression = parsedCronExpression {
				Text("Schedule: \(parsedCronExpression.shortDescription)").textSelection(.enabled)
				if let nextSchedualedDate = parsedCronExpression.getNextRunDateFromNow() {
					Text("Next Scheduled: \(nextSchedualedDate.description)")
				}
				Button("Submit"){}
			} else {
				Button("Validate"){
					let pce = CronExpression(cronString: cron)
					if pce == nil {
						cronError = true
					} else {
						cronError = false
					}
					parsedCronExpression = pce
				}.buttonStyle(.borderedProminent)
			}
			Button("Dismiss", action: dismiss)
		}
		.padding(.all, 40)	}
}

struct CronJob_Previews: PreviewProvider {
	static var previews: some View {
		CronJob(res: ClusterResources.dummyCronJob() as KubernetesAPIResource)
	}
}
