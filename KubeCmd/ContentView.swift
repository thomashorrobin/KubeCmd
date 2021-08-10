//
//  ContentView.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/02/2021.
//

import SwiftUI
import CoreData
import SwiftkubeClient
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
    
    func deleteResource(uuid:UUID, kind:String) -> Void {
        switch kind {
        case "Pod":
            pods.removeValue(forKey: uuid)
        case "CronJob":
            cronjobs.removeValue(forKey: uuid)
        case "Job":
            jobs.removeValue(forKey: uuid)
        case "Secret":
            secrets.removeValue(forKey: uuid)
        case "Deployment":
            deployments.removeValue(forKey: uuid)
        case "ConfigMap":
            configmaps.removeValue(forKey: uuid)
        default:
            print("error: resource not handled")
        }
    }
    
    func setResource(resource: KubernetesAPIResource) -> Void {
        let uuid = try! UUID.fromK8sMetadata(resource: resource)
        switch resource.kind {
        case "Pod":
            pods[uuid] = (resource as! core.v1.Pod)
        case "CronJob":
            cronjobs[uuid] = (resource as! batch.v1beta1.CronJob)
        case "Job":
            jobs[uuid] = (resource as! batch.v1.Job)
        case "Secret":
            secrets[uuid] = (resource as! core.v1.Secret)
        case "Deployment":
            deployments[uuid] = (resource as! apps.v1.Deployment)
        case "ConfigMap":
            configmaps[uuid] = (resource as! core.v1.ConfigMap)
        default:
            print("error: resource not handled")
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
        let uuid = try! UUID.fromK8sMetadata(resource: pod1)
        pods[uuid] = pod1
        return self
    }
}

public extension UUID {
    static func fromK8sMetadata(resource: KubernetesAPIResource) throws -> UUID {
        guard let metadata = resource.metadata else { throw SwiftkubeModelError.unknownAPIObject("metadata error") }
        guard let uid = metadata.uid else { throw SwiftkubeModelError.unknownAPIObject("metadata error") }
        guard let uuid = UUID(uuidString: uid) else { throw
            SwiftkubeModelError.unknownAPIObject("metadata error") }
        return uuid
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
        guard let client = client else {
            return
        }
        let strategy = RetryStrategy(
            policy: .maxAttemtps(20),
            backoff: .exponential(maximumDelay: 60, multiplier: 2.0)
        )
            do {
                let _ = try client.pods.watch(in: .default, retryStrategy: strategy) { (event, pod) in
                    print(event)
                }
                let pods = try client.pods.list(in: .default).wait().items
                for pod in pods {
                    let uuid = try! UUID.fromK8sMetadata(resource: pod)
                    self.resources.pods[uuid] = pod
                }
                let configmaps = try client.configMaps.list(in: .default).wait().items
                for configmap in configmaps {
                    let uuid = try! UUID.fromK8sMetadata(resource: configmap)
                    self.resources.configmaps[uuid] = configmap
                }
                let secrets = try client.secrets.list(in: .default).wait().items
                for secret in secrets {
                    let uuid = try! UUID.fromK8sMetadata(resource: secret)
                    self.resources.secrets[uuid] = secret
                }
                let cronjobs = try client.batchV1Beta1.cronJobs.list(in: .default).wait().items
                for cronjob in cronjobs {
                    let uuid = try! UUID.fromK8sMetadata(resource: cronjob)
                    self.resources.cronjobs[uuid] = cronjob
                }
                let jobs = try client.batchV1.jobs.list(in: .default).wait().items
                for job in jobs {
                    let uuid = try! UUID.fromK8sMetadata(resource: job)
                    self.resources.jobs[uuid] = job
                }
                let deployments = try client.appsV1.deployments.list(in: .default).wait().items
                for deployment in deployments {
                    let uuid = try! UUID.fromK8sMetadata(resource: deployment)
                    self.resources.deployments[uuid] = deployment
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
