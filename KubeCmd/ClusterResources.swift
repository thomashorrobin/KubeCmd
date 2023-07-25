//
//  ClusterResources.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 10/08/2021.
//

import Foundation
import SwiftkubeClient
import SwiftkubeModel
import SwiftUI

class ClusterResources: ObservableObject {
    @Published var selectedResource = KubernetesResources.pods
    @Published var pods: ResourceWrapper<core.v1.Pod>
    @Published var configmaps: ResourceWrapper<core.v1.ConfigMap>
    @Published var secrets: ResourceWrapper<core.v1.Secret>
    @Published var cronjobs: ResourceWrapper<batch.v1.CronJob>
    @Published var jobs: ResourceWrapper<batch.v1.Job>
    @Published var deployments:  ResourceWrapper<apps.v1.Deployment>
    @Published var ingresses:  ResourceWrapper<networking.v1.Ingress>
    @Published var services: ResourceWrapper<core.v1.Service>
    @Published var namespaceManager:NamespaceManager
    @Published var errors = [Error]()
    var client:KubernetesClient
    
    init(client:KubernetesClient, pubsub: PubSubBoillerPlate) throws {
        self.client = client
        let namespaceManager = try NamespaceManager(client: client)
        self.namespaceManager = namespaceManager
        self.pods = try ResourceWrapper<core.v1.Pod>(resourceFetcher: client.pods, namespaceManager: namespaceManager)
        self.jobs = try ResourceWrapper<batch.v1.Job>(resourceFetcher: client.batchV1.jobs, namespaceManager: namespaceManager)
        self.configmaps = try ResourceWrapper<core.v1.ConfigMap>(resourceFetcher: client.configMaps, namespaceManager: namespaceManager)
        self.secrets = try ResourceWrapper<core.v1.Secret>(resourceFetcher: client.secrets, namespaceManager: namespaceManager)
        self.cronjobs = try ResourceWrapper<batch.v1.CronJob>(resourceFetcher: client.batchV1.cronJobs, namespaceManager: namespaceManager)
        self.deployments = try ResourceWrapper<apps.v1.Deployment>(resourceFetcher: client.appsV1.deployments, namespaceManager: namespaceManager)
        self.ingresses = try ResourceWrapper<networking.v1.Ingress>(resourceFetcher: client.networkingV1.ingresses, namespaceManager: namespaceManager)
        self.services = try ResourceWrapper<core.v1.Service>(resourceFetcher: client.services, namespaceManager: namespaceManager)
        pubsub.Subscribe(fn: dropAndRefreshData)
    }
    
    func dropAndRefreshData() async throws -> Void {
        async let podsRefreshJob:Void = self.pods.refresh()
        async let jobsRefreshJob:Void = self.jobs.refresh()
        async let configmapsRefreshJob:Void = self.configmaps.refresh()
        async let secretsRefreshJob:Void = self.secrets.refresh()
        async let cronjobsRefreshJob:Void = self.cronjobs.refresh()
        async let deploymentsRefreshJob:Void = self.deployments.refresh()
        async let ingressesRefreshJob:Void = self.ingresses.refresh()
        async let servicesRefreshJob:Void = self.services.refresh()
        let _ = try await [podsRefreshJob, jobsRefreshJob, configmapsRefreshJob, secretsRefreshJob, cronjobsRefreshJob, deploymentsRefreshJob, ingressesRefreshJob, servicesRefreshJob]
    }
    
    func countItems() -> Int {
        return self.pods.items.count + self.jobs.items.count
    }
    
    //	func followLogs(name: String, cb: @escaping LogWatcherCallback.LineHandler) throws -> SwiftkubeClientTask {
    //		return try await client.pods.follow(name: name, lineHandler: cb)
    //	}
    
    func getLogs(name: String, all: Bool) async throws -> String {
        return try await client.pods.logs(name: name)
    }
    
    func removePod(uid:UUID) -> Void {
        self.pods.delete(uuid: uid)
    }
    
    func removeJob(uid:UUID) -> Void {
        self.jobs.delete(uuid: uid)
    }
    
    func setPod(pod:core.v1.Pod) throws -> Void {
        try self.pods.upsert(resource: pod)
    }
    
    func setJob(job:batch.v1.Job) throws -> Void {
        try self.jobs.upsert(resource: job)
    }
    
    func setSelectedResource(resource: KubernetesResources) -> Void {
        selectedResource = resource
    }
    
    func addJob(job: batch.v1.Job) async -> Void {
        do {
            let job = try await client.batchV1.jobs.create(inNamespace: .default, job)
            DispatchQueue.main.sync {
                do {
                    try setJob(job: job)
                } catch  {
                    self.errors.append(error)
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errors.append(error)
            }
        }
    }
    
    func deleteResource(resource:any KubernetesAPIResource) async throws -> Void {
        let deleteOptions = meta.v1.DeleteOptions(
            gracePeriodSeconds: 10,
            propagationPolicy: "Foreground"
        )
        guard let metadata = resource.metadata else { return }
        guard let name = metadata.name else { return }
        guard let namespace = metadata.namespace else { return }
        switch resource.kind {
        case "CronJob":
            _ = try await client.batchV1.cronJobs.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
        case "Job":
            _ = try await  client.batchV1.jobs.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
            
        case "Deployment":
            _ = try await  client.appsV1.deployments.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
            
        case "Pod":
            _ = try await  client.pods.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
            
        case "ConfigMap":
            _ = try await  client.configMaps.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
        case "Secret":
            _ = try await  client.secrets.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
        case "Ingress":
            _ = try await  client.networkingV1.ingresses.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
        case "Service":
            _ = try await client.services.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
        default:
            print("resource.kind not handled by deleteResource()")
        }
        print("sucessfully deleted \(resource.name ?? "nil") (\(resource.kind))")
    }
    func rerunJob(job: batch.v1.Job) async -> Void {
        do {
            let newJob = try createJobFromJob(job: job)
            do {
                let createdNewJob = try await client.batchV1.jobs.create(newJob)
                await addJob(job: createdNewJob)
            } catch {
                print(error)
            }
        } catch createJobFromJobErrors.jobMetadataDoesntExist {
            print("metadata doesnt exist")
        } catch createJobFromJobErrors.jobSpecDoesntExist {
            print("job spec doesnt exist")
        } catch {}
    }
    
    static func dummyCronJob() -> batch.v1.CronJob {
        return batch.v1.CronJob(metadata: meta.v1.ObjectMeta(creationTimestamp: Date(), deletionGracePeriodSeconds: 100, labels: ["feed" : "ziprecruiter"], managedFields: [meta.v1.ManagedFieldsEntry](), name: "great cronjob", namespace: "default", ownerReferences: [meta.v1.OwnerReference](), resourceVersion: "appv1", uid: "F3493650-A9DF-410F-B1A4-E8F5386E5B53"), spec: batch.v1.CronJobSpec(failedJobsHistoryLimit: 5, jobTemplate: batch.v1.JobTemplateSpec(), schedule: "15 10 * * *", startingDeadlineSeconds: 100, successfulJobsHistoryLimit: 2, suspend: false), status: batch.v1.CronJobStatus(active: [core.v1.ObjectReference](), lastScheduleTime: Date()))
    }
    
    static func dummyPod() -> core.v1.Pod {
        return core.v1.Pod(metadata: meta.v1.ObjectMeta(creationTimestamp: Date(), deletionGracePeriodSeconds: 100, labels: ["feed" : "ziprecruiter"], managedFields: [meta.v1.ManagedFieldsEntry](), name: "great pod", namespace: "default", ownerReferences: [meta.v1.OwnerReference](), resourceVersion: "appv1", uid: "F3493650-A9DF-410F-B1A4-E8F5386E5B46"), spec: core.v1.PodSpec(activeDeadlineSeconds: 400, containers: [core.v1.Container](), enableServiceLinks: true, ephemeralContainers: [core.v1.EphemeralContainer](), hostAliases: [core.v1.HostAlias](), hostname: "bigboy.directlyapply.com", initContainers: [core.v1.Container](), nodeName: "big-boy", readinessGates: [core.v1.PodReadinessGate](), restartPolicy: "Always", topologySpreadConstraints: [core.v1.TopologySpreadConstraint](), volumes: [core.v1.Volume]()), status: core.v1.PodStatus(startTime: Date()))
    }
}
