//
//  ContentView.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/02/2021.
//

import SwiftUI
import CoreData
import SwiftkubeModel

class ClusterResources: ObservableObject {
    @Published var selectedResource = KubernetesResources.pods
    @Published var pods = [UUID:core.v1.Pod]()
    @Published var configmaps = [UUID:core.v1.ConfigMap]()
    @Published var secrets = [UUID:core.v1.Secret]()
    @Published var cronjobs = [UUID:batch.v1beta1.CronJob]()
    @Published var jobs = [UUID:batch.v1.Job]()
    @Published var deployments = [UUID:apps.v1.Deployment]()
    
    func setSelectedResource(resource: KubernetesResources) -> Void {
        selectedResource = resource
    }
    
    func setCronJob(cronjob: batch.v1beta1.CronJob) -> Bool {
        let cronJobUUID = UUID(uuidString: (cronjob.metadata!.uid!))!
        if cronjobs.keys.contains(cronJobUUID) {
            cronjobs[cronJobUUID] = cronjob
            return true
        } else {
            return false
        }
    }
    
    static func dummyCronJob() -> batch.v1beta1.CronJob {
        return batch.v1beta1.CronJob(metadata: meta.v1.ObjectMeta(clusterName: "directly-apply-main-cluster", creationTimestamp: Date(), deletionGracePeriodSeconds: 100, labels: ["feed" : "ziprecruiter"], managedFields: [meta.v1.ManagedFieldsEntry](), name: "great cronjob", namespace: "default", ownerReferences: [meta.v1.OwnerReference](), resourceVersion: "appv1", uid: "F3493650-A9DF-410F-B1A4-E8F5386E5B53"), spec: batch.v1beta1.CronJobSpec(failedJobsHistoryLimit: 5, jobTemplate: batch.v1beta1.JobTemplateSpec(), schedule: "15 10 * * *", startingDeadlineSeconds: 100, successfulJobsHistoryLimit: 2, suspend: false), status: batch.v1beta1.CronJobStatus(active: [core.v1.ObjectReference](), lastScheduleTime: Date()))
    }
    
    static func dummyPod() -> core.v1.Pod {
        return core.v1.Pod(metadata: meta.v1.ObjectMeta(clusterName: "directly-apply-main-cluster", creationTimestamp: Date(), deletionGracePeriodSeconds: 100, labels: ["feed" : "ziprecruiter"], managedFields: [meta.v1.ManagedFieldsEntry](), name: "great pod", namespace: "default", ownerReferences: [meta.v1.OwnerReference](), resourceVersion: "appv1", uid: "F3493650-A9DF-410F-B1A4-E8F5386E5B46"), spec: core.v1.PodSpec(activeDeadlineSeconds: 400, containers: [core.v1.Container](), enableServiceLinks: true, ephemeralContainers: [core.v1.EphemeralContainer](), hostAliases: [core.v1.HostAlias](), hostname: "bigboy.directlyapply.com", initContainers: [core.v1.Container](), nodeName: "big-boy", readinessGates: [core.v1.PodReadinessGate](), restartPolicy: "Always", topologySpreadConstraints: [core.v1.TopologySpreadConstraint](), volumes: [core.v1.Volume]()), status: core.v1.PodStatus(startTime: Date()))
    }
    
    func populateTestData() -> ClusterResources {
        let pod1 = ClusterResources.dummyPod()
        pods[UUID(uuidString: (pod1.metadata?.uid)!)!] = pod1
        return self
    }
}

struct ContentView: View {
    @StateObject var resources = ClusterResources()
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    func loadData() -> Void {
            do {
                let pods = try client?.pods.list(in: .default).wait().items ?? [core.v1.Pod]()
                for pod in pods {
                    self.resources.pods[UUID(uuidString: (pod.metadata?.uid)!)!] = pod
                }
                let configmaps = try client?.configMaps.list(in: .default).wait().items ?? [core.v1.ConfigMap]()
                for configmap in configmaps {
                    self.resources.configmaps[UUID(uuidString: (configmap.metadata?.uid)!)!] = configmap
                }
                let secrets = try client?.secrets.list(in: .default).wait().items ?? [core.v1.Secret]()
                for secret in secrets {
                    self.resources.secrets[UUID(uuidString: (secret.metadata?.uid)!)!] = secret
                }
                let cronjobs = try client?.batchV1Beta1.cronJobs.list(in: .default).wait().items ?? [batch.v1beta1.CronJob]()
                for cronjob in cronjobs {
                    self.resources.cronjobs[UUID(uuidString: (cronjob.metadata?.uid)!)!] = cronjob
                }
                let jobs = try client?.batchV1.jobs.list(in: .default).wait().items ?? [batch.v1.Job]()
                for job in jobs {
                    self.resources.jobs[UUID(uuidString: (job.metadata?.uid)!)!] = job
                }
                let deployments = try client?.appsV1.deployments.list(in: .default).wait().items ?? [apps.v1.Deployment]()
                for deployment in deployments {
                    self.resources.deployments[UUID(uuidString: (deployment.metadata?.uid)!)!] = deployment
                }
            } catch {
                print("Unknown error: \(error)")
            }
    }
    
    @State var buttonText = "Load data again"

    var body: some View {
        NavigationView
        {
            TopLevelK8sMenu()
            SecondLevelK8sItems()
            Button(action: {
                buttonText = "loading..."
                loadData()
                buttonText = "Load data again"
            }, label: {
                Text(buttonText)
            })
        }.environmentObject(resources).onAppear(perform: {
            loadData()
        }).toolbar(content: {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
            ToolbarItem(placement: .primaryAction) {
                Image(systemName: "plus")
            }
        })
    }
    
    func toggleSidebar() {
        NSApp.keyWindow?.contentViewController?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
