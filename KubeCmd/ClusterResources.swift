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

public extension batch.v1.CronJobList {
	mutating func replaceOrAdd(cj:batch.v1.CronJob) throws {
		let uid = try UUID.fromK8sMetadata(resource: cj as KubernetesAPIResource)
		for (i, item) in items.enumerated() {
			let xx_uid = try UUID.fromK8sMetadata(resource: item as KubernetesAPIResource)
			if xx_uid == uid {
				items[i] = cj
				return
			}
		}
		items.append(cj)
	}
}

public extension core.v1.SecretList {
	mutating func replaceOrAdd(s:core.v1.Secret) throws {
		let uid = try UUID.fromK8sMetadata(resource: s as KubernetesAPIResource)
		for (i, item) in items.enumerated() {
			let xx_uid = try UUID.fromK8sMetadata(resource: item as KubernetesAPIResource)
			if xx_uid == uid {
				items[i] = s
				return
			}
		}
		items.append(s)
	}
}

public extension core.v1.ConfigMapList {
	mutating func replaceOrAdd(cm:core.v1.ConfigMap) throws {
		let uid = try UUID.fromK8sMetadata(resource: cm as KubernetesAPIResource)
		for (i, item) in items.enumerated() {
			let xx_uid = try UUID.fromK8sMetadata(resource: item as KubernetesAPIResource)
			if xx_uid == uid {
				items[i] = cm
				return
			}
		}
		items.append(cm)
	}
}

public extension apps.v1.DeploymentList {
	mutating func replaceOrAdd(d:apps.v1.Deployment) throws {
		let uid = try UUID.fromK8sMetadata(resource: d as KubernetesAPIResource)
		for (i, item) in items.enumerated() {
			let xx_uid = try UUID.fromK8sMetadata(resource: item as KubernetesAPIResource)
			if xx_uid == uid {
				items[i] = d
				return
			}
		}
		items.append(d)
	}
}

public extension networking.v1.IngressList {
	mutating func replaceOrAdd(ing:networking.v1.Ingress) throws {
		let uid = try UUID.fromK8sMetadata(resource: ing as KubernetesAPIResource)
		for (i, item) in items.enumerated() {
			let xx_uid = try UUID.fromK8sMetadata(resource: item as KubernetesAPIResource)
			if xx_uid == uid {
				items[i] = ing
				return
			}
		}
		items.append(ing)
	}
}

public extension core.v1.ServiceList {
	mutating func replaceOrAdd(s:core.v1.Service) throws {
		let uid = try UUID.fromK8sMetadata(resource: s as KubernetesAPIResource)
		for (i, item) in items.enumerated() {
			let xx_uid = try UUID.fromK8sMetadata(resource: item as KubernetesAPIResource)
			if xx_uid == uid {
				items[i] = s
				return
			}
		}
		items.append(s)
	}
}

class ClusterResources: ObservableObject {
	@Published var selectedResource = KubernetesResources.pods
	@Published var pods = [UUID:core.v1.Pod]()
	@Published var configmaps:core.v1.ConfigMapList = core.v1.ConfigMapList(metadata: nil, items: [])
	@Published var secrets:core.v1.SecretList = core.v1.SecretList(metadata: nil, items: [])
	@Published var cronjobs:batch.v1.CronJobList = batch.v1.CronJobList(metadata: nil, items: [])
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
		self.cronjobs = try self.client.batchV1.cronJobs.list(in: ns).wait()
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
	
	func getLogs(name: String, all: Bool) throws -> String {
		return try client.pods.logs(name: name, tailLines: all ? nil : 5000).wait()
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
	
	func dropLabel(kind: String, cronJob: String, name: String) -> Void {
		guard let kind = KubernetesResources.init(rawValue: kind) else { return }
			switch kind {
			case .pods:
				do {
					let newResource = try client.pods.deleteLabel(in: self.namespace, name: cronJob, labelName: name).wait()
					let uid = try UUID.fromK8sMetadata(resource: newResource)
					self.pods[uid] = newResource
				} catch {
					print(error)
				}
			case .cronjobs:
				do {
					let newResource = try client.batchV1.cronJobs.deleteLabel(in: self.namespace, name: cronJob, labelName: name).wait()
					try self.cronjobs.replaceOrAdd(cj: newResource)
				} catch {
					print(error)
				}
			case .deployments:
				do {
					let newResource = try client.appsV1.deployments.deleteLabel(in: self.namespace, name: cronJob, labelName: name).wait()
					try self.deployments.replaceOrAdd(d: newResource)
				} catch {
					print(error)
				}
			case .jobs:
				do {
					let newResource = try client.batchV1.jobs.deleteLabel(in: self.namespace, name: cronJob, labelName: name).wait()
					let uid = try UUID.fromK8sMetadata(resource: newResource)
					self.jobs[uid] = newResource
				} catch {
					print(error)
				}
			case .configmaps:
				do {
					let newResource = try client.configMaps.deleteLabel(in: self.namespace, name: cronJob, labelName: name).wait()
					try self.configmaps.replaceOrAdd(cm: newResource)
				} catch {
					print(error)
				}
			case .secrets:
				do {
					let newResource = try client.secrets.deleteLabel(in: self.namespace, name: cronJob, labelName: name).wait()
					try self.secrets.replaceOrAdd(s: newResource)
				} catch {
					print(error)
				}
			case .ingresses:
				do {
					let newResource = try client.networkingV1.ingresses.deleteLabel(in: self.namespace, name: cronJob, labelName: name).wait()
					try self.ingresses.replaceOrAdd(ing: newResource)
				} catch {
					print(error)
				}
			case .services:
				do {
					let newResource = try client.services.deleteLabel(in: self.namespace, name: cronJob, labelName: name).wait()
					try self.services.replaceOrAdd(s: newResource)
				} catch {
					print(error)
				}
			}
	}
	
	func setLabels(kind: String, cronJob: String, value: [String:String]) -> Void {
		let name = ""
		guard let kind = KubernetesResources.init(rawValue: kind) else { return }
			switch kind {
			case .pods:
				do {
					let newResource = try client.pods.setLabels(in: self.namespace, name: cronJob, labelName: name, value: value).wait()
					let uid = try UUID.fromK8sMetadata(resource: newResource)
					self.pods[uid] = newResource
				} catch {
					print(error)
				}
			case .cronjobs:
				do {
					let newResource = try client.batchV1.cronJobs.setLabels(in: self.namespace, name: cronJob, labelName: name, value: value).wait()
					try self.cronjobs.replaceOrAdd(cj: newResource)
				} catch {
					print(error)
				}
			case .deployments:
				do {
					let newResource = try client.appsV1.deployments.setLabels(in: self.namespace, name: cronJob, labelName: name, value: value).wait()
					try self.deployments.replaceOrAdd(d: newResource)
				} catch {
					print(error)
				}
			case .jobs:
				do {
					let newResource = try client.batchV1.jobs.setLabels(in: self.namespace, name: cronJob, labelName: name, value: value).wait()
					let uid = try UUID.fromK8sMetadata(resource: newResource)
					self.jobs[uid] = newResource
				} catch {
					print(error)
				}
			case .configmaps:
				do {
					let newResource = try client.configMaps.setLabels(in: self.namespace, name: cronJob, labelName: name, value: value).wait()
					try self.configmaps.replaceOrAdd(cm: newResource)
				} catch {
					print(error)
				}
			case .secrets:
				do {
					let newResource = try client.secrets.setLabels(in: self.namespace, name: cronJob, labelName: name, value: value).wait()
					try self.secrets.replaceOrAdd(s: newResource)
				} catch {
					print(error)
				}
			case .ingresses:
				do {
					let newResource = try client.networkingV1.ingresses.setLabels(in: self.namespace, name: cronJob, labelName: name, value: value).wait()
					try self.ingresses.replaceOrAdd(ing: newResource)
				} catch {
					print(error)
				}
			case .services:
				do {
					let newResource = try client.services.setLabels(in: self.namespace, name: cronJob, labelName: name, value: value).wait()
					try self.services.replaceOrAdd(s: newResource)
				} catch {
					print(error)
				}
			}
	}
	
	func disconnectWatches() -> Void {
		for t in k8sTasks {
			t.cancel()
		}
	}
	
	func connectWatches() throws -> Void {
		
		let strategy = RetryStrategy(
			policy: .maxAttempts(20),
			backoff: .exponential(maximumDelay: 60, multiplier: 2.0)
		)
		let podWatcher = try client.pods.watch(in: .default, retryStrategy: strategy) { (event, pod) in
			let uuid = try! UUID.fromK8sMetadata(resource: pod)
			switch event.rawValue {
			case "ADDED":
				DispatchQueue.main.async {
					do {
						try self.setPod(pod: pod)
					} catch {
						print(error)
					}
				}
			case "MODIFIED":
				DispatchQueue.main.async {
					do {
						try self.setPod(pod: pod)
					} catch {
						print(error)
					}
				}
			case "DELETED":
				DispatchQueue.main.async {
					self.removePod(uid: uuid)
				}
			default:
				break
			}
		}
		let jobWatcher = try client.batchV1.jobs.watch(in: .default, retryStrategy: strategy) { (event, job) in
			let uuid = try! UUID.fromK8sMetadata(resource: job)
			switch event.rawValue {
			case "ADDED":
				DispatchQueue.main.async {
					do {
						try self.setJob(job: job)
					} catch {
						print(error)
					}
				}
			case "MODIFIED":
				DispatchQueue.main.async {
					do {
						try self.setJob(job: job)
					} catch {
						print(error)
					}
				}
			case "DELETED":
				DispatchQueue.main.async {
					self.removeJob(uid: uuid)
				}
			default:
				break
			}
		}
		k8sTasks.append(podWatcher)
		k8sTasks.append(jobWatcher)
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
		let deployment = try client.appsV1.deployments.restartDeployment(in: namespace, name: deployment.name!).wait()
		try self.deployments.replaceOrAdd(d: deployment)
	}
	
	func unsuspendCronJob(cronjob: batch.v1.CronJob) -> Void {
		print("starting unsuspend")
		do {
			let updatedCronjob = try client.batchV1.cronJobs.unsuspend(in: .default, name: cronjob.name ?? "").wait()
			try self.cronjobs.replaceOrAdd(cj: updatedCronjob)
		} catch {
			print(error)
			errors.append(error)
		}
	}
	func suspendCronJob(cronjob: batch.v1.CronJob) -> Void {
		print("starting suspend")
		do {
			let updatedCronjob = try client.batchV1.cronJobs.suspend(in: .default, name: cronjob.name ?? "").wait()
			try self.cronjobs.replaceOrAdd(cj: updatedCronjob)
		} catch {
			print(error)
			errors.append(error)
		}
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
			_ = client.batchV1.cronJobs.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
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
	func rerunJob(job: batch.v1.Job) -> Void {
		do {
			let newJob = try createJobFromJob(job: job)
			do {
				let createdNewJob = try client.batchV1.jobs.create(newJob).wait()
				addJob(job: createdNewJob)
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
		return batch.v1.CronJob(metadata: meta.v1.ObjectMeta(clusterName: "directly-apply-main-cluster", creationTimestamp: Date(), deletionGracePeriodSeconds: 100, labels: ["feed" : "ziprecruiter"], managedFields: [meta.v1.ManagedFieldsEntry](), name: "great cronjob", namespace: "default", ownerReferences: [meta.v1.OwnerReference](), resourceVersion: "appv1", uid: "F3493650-A9DF-410F-B1A4-E8F5386E5B53"), spec: batch.v1.CronJobSpec(failedJobsHistoryLimit: 5, jobTemplate: batch.v1.JobTemplateSpec(), schedule: "15 10 * * *", startingDeadlineSeconds: 100, successfulJobsHistoryLimit: 2, suspend: false), status: batch.v1.CronJobStatus(active: [core.v1.ObjectReference](), lastScheduleTime: Date()))
	}
	
	static func dummyPod() -> core.v1.Pod {
		return core.v1.Pod(metadata: meta.v1.ObjectMeta(clusterName: "directly-apply-main-cluster", creationTimestamp: Date(), deletionGracePeriodSeconds: 100, labels: ["feed" : "ziprecruiter"], managedFields: [meta.v1.ManagedFieldsEntry](), name: "great pod", namespace: "default", ownerReferences: [meta.v1.OwnerReference](), resourceVersion: "appv1", uid: "F3493650-A9DF-410F-B1A4-E8F5386E5B46"), spec: core.v1.PodSpec(activeDeadlineSeconds: 400, containers: [core.v1.Container](), enableServiceLinks: true, ephemeralContainers: [core.v1.EphemeralContainer](), hostAliases: [core.v1.HostAlias](), hostname: "bigboy.directlyapply.com", initContainers: [core.v1.Container](), nodeName: "big-boy", readinessGates: [core.v1.PodReadinessGate](), restartPolicy: "Always", topologySpreadConstraints: [core.v1.TopologySpreadConstraint](), volumes: [core.v1.Volume]()), status: core.v1.PodStatus(startTime: Date()))
	}
}
