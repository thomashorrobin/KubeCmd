//
//  KubernetesMenuView.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 29/12/2020.
//

import SwiftUI
import SwiftkubeClient
import SwiftkubeModel

let client = KubernetesClient()

struct KubernetesMenuView: View {
    @State private var selectedResource = KubernetesResources.pods
    @State private var pods = [core.v1.Pod]()
    @State private var cronjobs = [batch.v1beta1.CronJob]()
    @State private var deployments = [apps.v1.Deployment]()
    @State private var jobs = [batch.v1.Job]()
    var body: some View {
        List {
            Button(action: {
                selectedResource = KubernetesResources.cronjobs
            }) {
                HStack {
                    Image("cronjob")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text("CronJobs")
                }
            }.buttonStyle(PlainButtonStyle())
            Button(action: {
                selectedResource = KubernetesResources.deployments
            }) {
                HStack {
                    Image("deploy")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text("Deployments")
                }
            }.buttonStyle(PlainButtonStyle())
            Button(action: {
                selectedResource = KubernetesResources.pods
            }) {
                HStack {
                    Image("pod")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text("Pods")
                }
            }.buttonStyle(PlainButtonStyle())
            Button(action: {
                selectedResource = KubernetesResources.jobs
            }) {
                HStack {
                    Image("job")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text("Jobs")
                }
            }.buttonStyle(PlainButtonStyle())
            Text(selectedResource.rawValue).bold()
            if (selectedResource == KubernetesResources.deployments) {
                DeploymentList()
            }
            if (selectedResource == KubernetesResources.pods) {
                PodList()
            }
        }.listStyle(SidebarListStyle())
    }
}

struct DeploymentList: View {
    var deployments = [apps.v1.Deployment]()
    init() {
        guard let ds = try! client?.appsV1.deployments.list(in: .default).wait() else {
            return
        }
        deployments = ds.items
    }
    var body: some View {
        VStack {
            ForEach(deployments, id: \.metadata!.uid) { d in
                NavigationLink(d.name ?? "error", destination: DeploymentDetail(deployment: d)).buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct PodList: View {
    @EnvironmentObject var resources: ClusterResources
    var body: some View {
        VStack {
            ForEach(resources.pods, id: \.metadata!.uid) { d in
                NavigationLink(d.name ?? "error", destination: PodDetail(pod: d)).buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct DeploymentDetail: View {
    var deployment: apps.v1.Deployment
    var body: some View {
        VStack {
            Text("API version: \(deployment.apiVersion)")
        }.navigationTitle(deployment.name!)
    }
}

struct PodDetail: View {
    var pod: core.v1.Pod
    var body: some View {
        VStack {
            Text("API version: \(pod.apiVersion)")
            Text("Status: \(pod.status?.startTime ?? Date())")
        }.navigationTitle(pod.name!)
    }
}

struct KubernetesMenuView_Previews: PreviewProvider {
    static var previews: some View {
        KubernetesMenuView().environmentObject(ClusterResources())
    }
}
