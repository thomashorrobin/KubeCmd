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
    var body: some View {
        ScrollView {
            Button(action: {
                selectedResource = KubernetesResources.cronjobs
            }) {
                TopLevelK8sMenuItem(name: "CronJobs", imageName: "cronjob", itemCount: 0)
            }.buttonStyle(PlainButtonStyle())
            Button(action: {
                selectedResource = KubernetesResources.deployments
            }) {
                TopLevelK8sMenuItem(name: "Deployments", imageName: "deploy")
            }.buttonStyle(PlainButtonStyle())
            Button(action: {
                selectedResource = KubernetesResources.pods
            }) {
                TopLevelK8sMenuItem(name: "Pods", imageName: "pod")
            }.buttonStyle(PlainButtonStyle())
            Button(action: {
                selectedResource = KubernetesResources.jobs
            }) {
                TopLevelK8sMenuItem(name: "Jobs", imageName: "job")
            }.buttonStyle(PlainButtonStyle())
            Button(action: {
                selectedResource = KubernetesResources.configmaps
            }) {
                TopLevelK8sMenuItem(name: "Config Maps", imageName: "cm")
            }.buttonStyle(PlainButtonStyle())
            Button(action: {
                selectedResource = KubernetesResources.secrets
            }) {
                TopLevelK8sMenuItem(name: "Secrets", imageName: "secret")
            }.buttonStyle(PlainButtonStyle())
            Text(selectedResource.rawValue).bold()
            SecondLevelK8sItems(selectedResource: selectedResource)
        }
    }
}

struct DeploymentList: View {
    @EnvironmentObject var resources: ClusterResources
    var body: some View {
        VStack {
            ForEach(resources.deployments, id: \.metadata!.uid) { d in
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

struct ConfigMapList: View {
    @EnvironmentObject var resources: ClusterResources
    var body: some View {
        VStack {
            ForEach(resources.configmaps, id: \.metadata!.uid) { d in
                NavigationLink(d.name ?? "error", destination: ConfigMapDetail(configMap: d)).buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct CronJobList: View {
    @EnvironmentObject var resources: ClusterResources
    var body: some View {
        VStack {
            ForEach(resources.cronjobs, id: \.metadata!.uid) { d in
                NavigationLink(d.name ?? "error", destination: CronJobDetail(cronJob: d)).buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct CronJobDetail: View {
    var cronJob: batch.v1beta1.CronJob
    var body: some View {
        VStack {
            Text("API version: \(cronJob.apiVersion)")
            Text("Namespace: \(cronJob.metadata?.namespace ?? "error")")
        }.navigationTitle(cronJob.name!)
    }
}

struct JobList: View {
    @EnvironmentObject var resources: ClusterResources
    var body: some View {
        VStack {
            ForEach(resources.jobs, id: \.metadata!.uid) { d in
                NavigationLink(d.name ?? "error", destination: JobDetail(job: d)).buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct JobDetail: View {
    var job: batch.v1.Job
    var body: some View {
        VStack {
            Text("API version: \(job.apiVersion)")
            Text("Namespace: \(job.metadata?.namespace ?? "error")")
        }.navigationTitle(job.name!)
    }
}

struct SecretList: View {
    @EnvironmentObject var resources: ClusterResources
    var body: some View {
        VStack {
            ForEach(resources.secrets, id: \.metadata!.uid) { d in
                NavigationLink(d.name ?? "error", destination: SecretDetail(secret: d)).buttonStyle(PlainButtonStyle())
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

struct ConfigMapDetail: View {
    var configMap: core.v1.ConfigMap
    var body: some View {
        VStack {
            Text("API version: \(configMap.apiVersion)")
            Text("Namespace: \(configMap.metadata?.namespace ?? "error")")
        }.navigationTitle(configMap.name!)
    }
}

struct SecretDetail: View {
    var secret: core.v1.Secret
    var body: some View {
        VStack {
            Text("API version: \(secret.apiVersion)")
            Text("Namespace: \(secret.metadata?.namespace ?? "error")")
        }.navigationTitle(secret.name!)
    }
}

struct KubernetesMenuView_Previews: PreviewProvider {
    static var previews: some View {
        KubernetesMenuView().environmentObject(ClusterResources())
    }
}
