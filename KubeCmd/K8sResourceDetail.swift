//
//  K8sResourceDetail.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/06/2021.
//

import SwiftUI
import SwiftkubeModel

struct K8sResourceDetail: View {
	@EnvironmentObject var resources: ClusterResources
	var resource:KubernetesAPIResource
	@State var resourceDeleting = false
	@State var deleted = false
	func deleteResource() -> Void {
		do {
			try resources.deleteResource(resource: resource)
		} catch {
			print(error)
		}
	}
	var body: some View {
		if deleted {
			Text("resource deleted")
		} else {
			VStack(alignment: .leading, content: {
				HStack {
					Text(resource.name ?? "no name").font(.title).textSelection(.enabled)
					Spacer()
					VStack (alignment: .trailing, content: {
						Text(resource.kind).font(.largeTitle).bold()
						Text(resource.apiVersion).italic()
					})
				}.padding(.all, 40)
				Divider()
				ScrollView(.vertical){
					switch resource.kind {
					case "Pod":
						Pod(pod: resource as! core.v1.Pod).padding(.all, 40)
					case "CronJob":
						CronJob(res: resource).padding(.all, 40)
					case "Job":
						Job(job: resource as! batch.v1.Job).padding(.all, 40)
					case "Secret":
						Secret(secret: resource as! core.v1.Secret).padding(.all, 40)
					case "Deployment":
						Deployment(deployment: resource as! apps.v1.Deployment).padding(.all, 40)
					case "ConfigMap":
						ConfigMap(configmap: resource as! core.v1.ConfigMap).padding(.all, 40)
					case "Ingress":
						Ingress(i: resource as! networking.v1.Ingress).padding(.all, 40)
					case "Service":
						Service(service: resource as! core.v1.Service).padding(.all, 40)
					default:
						Text("unknown")
					}
				}
				Divider()
				HStack{
					Button(action: deleteResource, label: {
						Text("Delete")
					}).padding(.all, 40).disabled(resourceDeleting)
					Spacer()
					CustomButtons(resource: resource)
				}
			})
		}
	}
}

struct K8sResourceDetail_Previews: PreviewProvider {
    static var previews: some View {
        K8sResourceDetail(resource: ClusterResources.dummyPod())
    }
}

struct ViewLogs: View {
	var pod:core.v1.Pod
	@EnvironmentObject var resources: ClusterResources
	var body: some View {
		Button("Logs", action: {
			do {
				try LogsHandler(podName: pod.name!, resources: resources).environmentObject(resources).openInWindow(title: pod.name!, sender: self)
			} catch {
				print("bad")
			}
		})
	}
}

struct ReRunJob: View {
	var job:batch.v1.Job
	@EnvironmentObject var resources: ClusterResources
	var body: some View {
		Button("Rerun", action: {
			resources.rerunJob(job: job)
		})
	}
}

struct CustomButtons: View {
	var resource:KubernetesAPIResource
	var body: some View {
		switch resource.kind {
		case "CronJob":
			let cronJob = resource as! batch.v1beta1.CronJob
			HStack(spacing: 15){
				SuspendButton(cronJob: cronJob)
				TriggerCronJobButton(cronJob: cronJob)
			}.padding(.all, 40)
		case "Deployment":
			let deployment = resource as! apps.v1.Deployment
			HStack(spacing: 15){
				RestartDeployment(deployment: deployment)
			}.padding(.all, 40)
		case "Pod":
			let pod = resource as! core.v1.Pod
			HStack(spacing: 15){
				ViewLogs(pod: pod)
			}.padding(.all, 40)
		case "Job":
			let job = resource as! batch.v1.Job
			HStack(spacing: 15){
				ReRunJob(job: job)
			}.padding(.all, 40)
		default:
			EmptyView()
		}
	}
}
