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
            Button(action: {
                selectedResource = KubernetesResources.configmaps
            }) {
                HStack {
                    Image("cm")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text("Config Maps")
                }
            }.buttonStyle(PlainButtonStyle())
            Button(action: {
                selectedResource = KubernetesResources.secrets
            }) {
                HStack {
                    Image("secret")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text("Secrets")
                }
            }.buttonStyle(PlainButtonStyle())
            Text(selectedResource.rawValue).bold()
            switch selectedResource {
            case KubernetesResources.deployments:
                DeploymentList()
            case KubernetesResources.pods:
                PodList()
            case KubernetesResources.secrets:
                SecretList()
            case KubernetesResources.configmaps:
                ConfigMapList()
            case KubernetesResources.cronjobs:
                CronJobList()
            case KubernetesResources.jobs:
                JobList()
            }
        }.listStyle(SidebarListStyle())
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
