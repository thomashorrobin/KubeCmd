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
	@Published var pods = [UUID:core.v1.Pod]()
	@Published var configmaps:core.v1.ConfigMapList = core.v1.ConfigMapList(metadata: nil, items: [])
	@Published var secrets:core.v1.SecretList = core.v1.SecretList(metadata: nil, items: [])
	@Published var cronjobs:batch.v1beta1.CronJobList = batch.v1beta1.CronJobList(metadata: nil, items: [])
	@Published var jobs = [UUID:batch.v1.Job]()
	@Published var deployments:apps.v1.DeploymentList = apps.v1.DeploymentList(metadata: nil, items: [])
	@Published var ingresses:networking.v1.IngressList = networking.v1.IngressList(metadata: nil, items: [])
	@Published var services:core.v1.ServiceList = core.v1.ServiceList(metadata: nil, items: [])
	@Published var namespace = NamespaceSelector.namespace("default")
	@Published var namespaces = core.v1.NamespaceList(metadata: nil, items: [core.v1.Namespace]())
	@Published var errors = [Error]()
	var client:KubernetesClient
	var k8sTasks = [SwiftkubeClientTask]()
	
	init(client:KubernetesClient) {
		self.client = client
		do {
			try refreshData()
		} catch {
			errors.append(error)
		}
	}
	
	func refreshData() throws -> Void {
		try refreshConfigMaps(ns: namespace)
		try refreshSecrets(ns: namespace)
		try refreshCronJobs(ns: namespace)
		try refreshDeployments(ns: namespace)
		try refreshIngresses(ns: namespace)
		try refreshServices(ns: namespace)
	}
	
	func refreshConfigMaps(ns: NamespaceSelector) throws -> Void {
		self.configmaps = try self.client.configMaps.list(in: ns).wait()
	}
	func refreshSecrets(ns: NamespaceSelector) throws -> Void {
		self.secrets = try self.client.secrets.list(in: ns).wait()
	}
	func refreshCronJobs(ns: NamespaceSelector) throws -> Void {
		self.cronjobs = try self.client.batchV1Beta1.cronJobs.list(in: ns).wait()
	}
	func refreshDeployments(ns: NamespaceSelector) throws -> Void {
		self.deployments = try self.client.appsV1.deployments.list(in: ns).wait()
	}
	func refreshIngresses(ns: NamespaceSelector) throws -> Void {
		self.ingresses = try self.client.networkingV1.ingresses.list(in: ns).wait()
	}
	func refreshServices(ns: NamespaceSelector) throws -> Void {
		self.services = try self.client.services.list(in: ns).wait()
	}
	
	func fetchNamespaces() throws -> Void {
		self.namespaces = try client.namespaces.list(options: nil).wait()
	}
	
	func followLogs(name: String, cb: @escaping LogWatcherCallback.LineHandler) throws -> SwiftkubeClientTask {
		return try client.pods.follow(name: name, lineHandler: cb)
	}
	
	func removePod(uid:UUID) -> Void {
		self.pods.removeValue(forKey: uid)
	}
	
	func removeJob(uid:UUID) -> Void {
		self.jobs.removeValue(forKey: uid)
	}
	
	func setPod(pod:core.v1.Pod) throws -> Void {
		let uid = try UUID.fromK8sMetadata(resource: pod)
		pods[uid] = pod
	}
	
	func setJob(job:batch.v1.Job) throws -> Void {
		let uid = try UUID.fromK8sMetadata(resource: job)
		jobs[uid] = job
	}
	
	
	func disconnectWatches() -> Void {
		for t in k8sTasks {
			t.cancel()
		}
	}
	
	func connectWatches() throws -> Void {
		
		let strategy = RetryStrategy(
			policy: .maxAttemtps(20),
			backoff: .exponential(maximumDelay: 60, multiplier: 2.0)
		)
		k8sTasks.append(try! client.pods.watch(in: .default, retryStrategy: strategy) { (event, pod) in
			let uuid = try! UUID.fromK8sMetadata(resource: pod)
			switch event.rawValue {
			case "ADDED":
				DispatchQueue.main.async {
					try! self.setPod(pod: pod)
				}
			case "MODIFIED":
				DispatchQueue.main.async {
					try! self.setPod(pod: pod)
				}
			case "DELETED":
				DispatchQueue.main.async {
					self.removePod(uid: uuid)
				}
			default:
				break
			}
		})
		k8sTasks.append(try! client.batchV1.jobs.watch(in: .default, retryStrategy: strategy) { (event, job) in
			let uuid = try! UUID.fromK8sMetadata(resource: job)
			switch event.rawValue {
			case "ADDED":
				DispatchQueue.main.async {
					try! self.setJob(job: job)
				}
			case "MODIFIED":
				DispatchQueue.main.async {
					try! self.setJob(job: job)
				}
			case "DELETED":
				DispatchQueue.main.async {
					self.removeJob(uid: uuid)
				}
			default:
				break
			}
		})
		
	}
	
	func setSelectedResource(resource: KubernetesResources) -> Void {
		selectedResource = resource
	}
	
	func addJob(job: batch.v1.Job) -> Void {
		do {
			let job = try client.batchV1.jobs.create(inNamespace: .default, job).wait()
			try setJob(job: job)
		} catch {
			errors.append(error)
		}
	}
	
	func restartDeployment(deployment: apps.v1.Deployment) throws -> Void {
		let formatter = ISO8601DateFormatter()
		var newDeployment = deployment
		newDeployment.spec?.template.metadata?.annotations?["kubectl.kubernetes.io/restartedAt"] = formatter.string(from: Date())
		let _ = try client.appsV1.deployments.update(newDeployment).wait()
		self.deployments = try client.appsV1.deployments.list(in: .default).wait()
	}
	
	func unsuspendCronJob(cronjob: batch.v1beta1.CronJob) -> Void {
		var newThing = cronjob
		newThing.spec?.suspend = false
		do {
			let _ = try client.batchV1Beta1.cronJobs.update(newThing).wait()
			self.cronjobs = try client.batchV1Beta1.cronJobs.list(in: self.namespace).wait()
		} catch {
			errors.append(error)
		}
	}
	func suspendCronJob(cronjob: batch.v1beta1.CronJob) -> Void {
		var newThing = cronjob
		newThing.spec?.suspend = true
		do {
			let _ = try client.batchV1Beta1.cronJobs.update(newThing).wait()
			self.cronjobs = try client.batchV1Beta1.cronJobs.list(in: self.namespace).wait()
		} catch {
			errors.append(error)
		}
	}
	func addLabel(metadata:meta.v1.ObjectMeta, key:String, value:String) -> meta.v1.ObjectMeta? {
		guard var labels = metadata.labels else { return metadata }
		labels[key] = value
		var newMetadata = metadata
		newMetadata.labels = labels
		return newMetadata
	}
	func removeLabel(metadata:meta.v1.ObjectMeta, key:String) -> meta.v1.ObjectMeta? {
		guard var labels = metadata.labels else { return metadata }
		labels.removeValue(forKey: key)
		var newMetadata = metadata
		newMetadata.labels = labels
		return newMetadata
	}
	func deleteResource(resource:KubernetesAPIResource) throws -> Void {
		let deleteOptions = meta.v1.DeleteOptions(
			gracePeriodSeconds: 10,
			propagationPolicy: "Foreground"
		)
		guard let metadata = resource.metadata else { return }
		guard let name = metadata.name else { return }
		guard let namespace = metadata.namespace else { return }
		switch resource.kind {
		case "CronJob":
			_ = client.batchV1Beta1.cronJobs.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			try refreshCronJobs(ns: self.namespace)
		case "Job":
			_ = client.batchV1.jobs.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			
		case "Deployment":
			_ = client.appsV1.deployments.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			try refreshDeployments(ns: self.namespace)
			
		case "Pod":
			_ = client.pods.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			
		case "ConfigMap":
			_ = client.configMaps.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			try refreshConfigMaps(ns: self.namespace)
		case "Secret":
			_ = client.secrets.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			try refreshSecrets(ns: self.namespace)
		case "Ingress":
			_ = client.networkingV1.ingresses.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			try refreshIngresses(ns: self.namespace)
		case "Service":
			_ = client.services.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			try refreshSecrets(ns: self.namespace)
		default:
			print("resource.kind not handled by deleteResource()")
		}
		print("sucessfully deleted \(resource.name ?? "nil") (\(resource.kind))")
	}
	
	static func dummyCronJob() -> batch.v1beta1.CronJob {
		return batch.v1beta1.CronJob(metadata: meta.v1.ObjectMeta(clusterName: "directly-apply-main-cluster", creationTimestamp: Date(), deletionGracePeriodSeconds: 100, labels: ["feed" : "ziprecruiter"], managedFields: [meta.v1.ManagedFieldsEntry](), name: "great cronjob", namespace: "default", ownerReferences: [meta.v1.OwnerReference](), resourceVersion: "appv1", uid: "F3493650-A9DF-410F-B1A4-E8F5386E5B53"), spec: batch.v1beta1.CronJobSpec(failedJobsHistoryLimit: 5, jobTemplate: batch.v1beta1.JobTemplateSpec(), schedule: "15 10 * * *", startingDeadlineSeconds: 100, successfulJobsHistoryLimit: 2, suspend: false), status: batch.v1beta1.CronJobStatus(active: [core.v1.ObjectReference](), lastScheduleTime: Date()))
	}
	
	static func dummyPod() -> core.v1.Pod {
		return core.v1.Pod(metadata: meta.v1.ObjectMeta(clusterName: "directly-apply-main-cluster", creationTimestamp: Date(), deletionGracePeriodSeconds: 100, labels: ["feed" : "ziprecruiter"], managedFields: [meta.v1.ManagedFieldsEntry](), name: "great pod", namespace: "default", ownerReferences: [meta.v1.OwnerReference](), resourceVersion: "appv1", uid: "F3493650-A9DF-410F-B1A4-E8F5386E5B46"), spec: core.v1.PodSpec(activeDeadlineSeconds: 400, containers: [core.v1.Container](), enableServiceLinks: true, ephemeralContainers: [core.v1.EphemeralContainer](), hostAliases: [core.v1.HostAlias](), hostname: "bigboy.directlyapply.com", initContainers: [core.v1.Container](), nodeName: "big-boy", readinessGates: [core.v1.PodReadinessGate](), restartPolicy: "Always", topologySpreadConstraints: [core.v1.TopologySpreadConstraint](), volumes: [core.v1.Volume]()), status: core.v1.PodStatus(startTime: Date()))
	}
}
