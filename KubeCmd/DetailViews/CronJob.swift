//
//  CronJob.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/06/2021.
//

import SwiftUI
import SwiftkubeModel


struct SuspendButton: View {
    var cronJob:batch.v1beta1.CronJob
    let suspended:Bool
    var body: some View {
        if suspended {
            Button(action: unsuspendCronJob, label: {
                Text("Unsuspend")
            }).padding(.all, 40)
        } else {
            Button(action: suspendCronJob, label: {
                Text("Suspend")
            }).padding(.all, 40)
        }
    }
    func unsuspendCronJob() -> Void {
        var newThing = self.cronJob
        newThing.spec?.suspend = false
        print("newthing suspended \(newThing.spec?.suspend ?? false)")
        do {
            let x = try client?.batchV1Beta1.cronJobs.update(newThing).wait()
            print("Suspended \(x?.spec?.suspend ?? false)")
        } catch {
            print(error)
        }
    }
    func suspendCronJob() -> Void {
        var newThing = self.cronJob
        newThing.spec?.suspend = true
        do {
            let x = try client?.batchV1Beta1.cronJobs.update(newThing).wait()
            print("Suspended \(x?.spec?.suspend ?? false)")
        } catch {
            print(error)
        }
    }
}

struct CronJob: View {
    let cronJob:batch.v1beta1.CronJob
    let suspended:Bool
    init(res:KubernetesAPIResource) {
        self.cronJob = res as! batch.v1beta1.CronJob
        self.suspended = self.cronJob.spec?.suspend ?? false
    }
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(5), content: {
            Text("Status").font(.title2)
            Text("Schedule: \(cronJob.spec?.schedule ?? "error")")
            Text("Suspended: \(String(cronJob.spec?.suspend ?? true))")
            Divider().padding(.vertical, 30)
            Text("Spec").font(.title2)
            Button(action: triggerCronJob, label: {
                Text("Trigger")
            }).padding(.all, 40)
            SuspendButton(cronJob: self.cronJob, suspended: self.suspended)
        })
    }
    func triggerCronJob() -> Void {
        let job = createJobFromCronJob(cronJob: self.cronJob)
        do {
            let _ = try client?.batchV1.jobs.create(inNamespace: .default, job).wait()
        } catch {
            print(error)
        }
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
