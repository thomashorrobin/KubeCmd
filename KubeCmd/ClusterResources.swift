//
//  ClusterResources.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 10/08/2021.
//

import Foundation
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
