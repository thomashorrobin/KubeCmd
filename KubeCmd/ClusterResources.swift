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
	@Published var pods = ResourceWrapper<core.v1.Pod>()
	@Published var configmaps:core.v1.ConfigMapList = core.v1.ConfigMapList(metadata: nil, items: [])
	@Published var secrets:core.v1.SecretList = core.v1.SecretList(metadata: nil, items: [])
	@Published var cronjobs:batch.v1.CronJobList = batch.v1.CronJobList(metadata: nil, items: [])
	@Published var jobs = ResourceWrapper<batch.v1.Job>()
	@Published var deployments:apps.v1.DeploymentList = apps.v1.DeploymentList(metadata: nil, items: [])
	@Published var ingresses:networking.v1.IngressList = networking.v1.IngressList(metadata: nil, items: [])
	@Published var services:core.v1.ServiceList = core.v1.ServiceList(metadata: nil, items: [])
    @Published var namespaceManager:NamespaceManager
	@Published var errors = [Error]()
	var client:KubernetesClient
    var podWatcher:SwiftkubeClientTask<WatchEvent<core.v1.Pod>>
    var jobWatcher:SwiftkubeClientTask<WatchEvent<batch.v1.Job>>
	
	init(client:KubernetesClient, pubsub: PubSubBoillerPlate) throws {
		self.client = client
        namespaceManager = try NamespaceManager(client: client)
        let strategy = RetryStrategy(
            policy: .maxAttempts(20),
            backoff: .exponential(maximumDelay: 60, multiplier: 2.0)
        )
        
        podWatcher = try client.pods.watch(in: .default, retryStrategy: strategy)
        jobWatcher = try client.batchV1.jobs.watch(in: .default, retryStrategy: strategy)
        pubsub.Subscribe(fn: dropAndRefreshData)
		Task {
			   try await refreshData()
		   }
	}
    
    func dropAndRefreshData() async throws -> Void {
        DispatchQueue.main.sync {
            configmaps = core.v1.ConfigMapList(metadata: nil, items: [])
            secrets = core.v1.SecretList(metadata: nil, items: [])
            cronjobs = batch.v1.CronJobList(metadata: nil, items: [])
            deployments = apps.v1.DeploymentList(metadata: nil, items: [])
            ingresses = networking.v1.IngressList(metadata: nil, items: [])
            services = core.v1.ServiceList(metadata: nil, items: [])
        }
        try await refreshData()
    }
	
	func refreshData() async throws -> Void {
        try await refreshConfigMaps(ns: namespaceManager.namespace)
		try await refreshSecrets(ns: namespaceManager.namespace)
		try await refreshCronJobs(ns: namespaceManager.namespace)
		try await refreshDeployments(ns: namespaceManager.namespace)
		try await refreshIngresses(ns: namespaceManager.namespace)
		try await refreshServices(ns: namespaceManager.namespace)
	}
	
	func refreshConfigMaps(ns: NamespaceSelector) async throws -> Void {
		let configmaps = try await self.client.configMaps.list(in: ns)
        DispatchQueue.main.async {
            self.configmaps = configmaps
        }
	}
	func refreshSecrets(ns: NamespaceSelector) async throws -> Void {
		let secrets = try await self.client.secrets.list(in: ns)
        DispatchQueue.main.async {
            self.secrets = secrets
        }
	}
	func refreshCronJobs(ns: NamespaceSelector) async throws -> Void {
		let cronjobs = try await self.client.batchV1.cronJobs.list(in: ns)
        DispatchQueue.main.async {
            self.cronjobs = cronjobs
        }
	}
	func refreshDeployments(ns: NamespaceSelector) async throws -> Void {
		let deployments = try await self.client.appsV1.deployments.list(in: ns)
        DispatchQueue.main.async {
            self.deployments = deployments
        }
	}
	func refreshIngresses(ns: NamespaceSelector) async throws -> Void {
		let ingresses = try await self.client.networkingV1.ingresses.list(in: ns)
        DispatchQueue.main.async {
            self.ingresses = ingresses
        }
	}
	func refreshServices(ns: NamespaceSelector) async throws -> Void {
		let services = try await self.client.services.list(in: ns)
        DispatchQueue.main.async {
            self.services = services
        }
	}
	
//	func followLogs(name: String, cb: @escaping LogWatcherCallback.LineHandler) throws -> SwiftkubeClientTask {
//		return try await client.pods.follow(name: name, lineHandler: cb)
//	}
	
	func getLogs(name: String, all: Bool) async throws -> String {
		return try await client.pods.logs(name: name, tailLines: all ? nil : 5000)
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
	
	func dropLabel(kind: String, cronJob: String, name: String) async -> Void {
		guard let kind = KubernetesResources.init(rawValue: kind) else { return }
			switch kind {
			case .pods:
				do {
					let newResource = try await client.pods.deleteLabel(in: self.namespaceManager.namespace, name: cronJob, labelName: name)
                    try self.pods.upsert(resource: newResource)
				} catch {
					print(error)
				}
			case .cronjobs:
				do {
					let newResource = try await client.batchV1.cronJobs.deleteLabel(in: self.namespaceManager.namespace, name: cronJob, labelName: name)
					try self.cronjobs.replaceOrAdd(cj: newResource)
				} catch {
					print(error)
				}
			case .deployments:
				do {
					let newResource = try await client.appsV1.deployments.deleteLabel(in: self.namespaceManager.namespace, name: cronJob, labelName: name)
					try self.deployments.replaceOrAdd(d: newResource)
				} catch {
					print(error)
				}
			case .jobs:
				do {
					let newResource = try await client.batchV1.jobs.deleteLabel(in: self.namespaceManager.namespace, name: cronJob, labelName: name)
                    try self.jobs.upsert(resource: newResource)
				} catch {
					print(error)
				}
			case .configmaps:
				do {
					let newResource = try await client.configMaps.deleteLabel(in: self.namespaceManager.namespace, name: cronJob, labelName: name)
					try self.configmaps.replaceOrAdd(cm: newResource)
				} catch {
					print(error)
				}
			case .secrets:
				do {
					let newResource = try await client.secrets.deleteLabel(in: self.namespaceManager.namespace, name: cronJob, labelName: name)
					try self.secrets.replaceOrAdd(s: newResource)
				} catch {
					print(error)
				}
			case .ingresses:
				do {
					let newResource = try await client.networkingV1.ingresses.deleteLabel(in: self.namespaceManager.namespace, name: cronJob, labelName: name)
					try self.ingresses.replaceOrAdd(ing: newResource)
				} catch {
					print(error)
				}
			case .services:
				do {
					let newResource = try await client.services.deleteLabel(in: self.namespaceManager.namespace, name: cronJob, labelName: name)
					try self.services.replaceOrAdd(s: newResource)
				} catch {
					print(error)
				}
			}
	}
	
	func setLabels(kind: String, cronJob: String, value: [String:String]) async -> Void {
		let name = ""
		guard let kind = KubernetesResources.init(rawValue: kind) else { return }
			switch kind {
			case .pods:
				do {
					let newResource = try await client.pods.setLabels(in: self.namespaceManager.namespace, name: cronJob, labelName: name, value: value)
                    try self.pods.upsert(resource: newResource)
				} catch {
					print(error)
				}
			case .cronjobs:
				do {
					let newResource = try await client.batchV1.cronJobs.setLabels(in: self.namespaceManager.namespace, name: cronJob, labelName: name, value: value)
					try self.cronjobs.replaceOrAdd(cj: newResource)
				} catch {
					print(error)
				}
			case .deployments:
				do {
					let newResource = try await client.appsV1.deployments.setLabels(in: self.namespaceManager.namespace, name: cronJob, labelName: name, value: value)
					try self.deployments.replaceOrAdd(d: newResource)
				} catch {
					print(error)
				}
			case .jobs:
				do {
					let newResource = try await client.batchV1.jobs.setLabels(in: self.namespaceManager.namespace, name: cronJob, labelName: name, value: value)
                    try self.jobs.upsert(resource: newResource)
				} catch {
					print(error)
				}
			case .configmaps:
				do {
					let newResource = try await client.configMaps.setLabels(in: self.namespaceManager.namespace, name: cronJob, labelName: name, value: value)
					try self.configmaps.replaceOrAdd(cm: newResource)
				} catch {
					print(error)
				}
			case .secrets:
				do {
					let newResource = try await client.secrets.setLabels(in: self.namespaceManager.namespace, name: cronJob, labelName: name, value: value)
					try self.secrets.replaceOrAdd(s: newResource)
				} catch {
					print(error)
				}
			case .ingresses:
				do {
					let newResource = try await client.networkingV1.ingresses.setLabels(in: self.namespaceManager.namespace, name: cronJob, labelName: name, value: value)
					try self.ingresses.replaceOrAdd(ing: newResource)
				} catch {
					print(error)
				}
			case .services:
				do {
					let newResource = try await client.services.setLabels(in: self.namespaceManager.namespace, name: cronJob, labelName: name, value: value)
					try self.services.replaceOrAdd(s: newResource)
				} catch {
					print(error)
				}
			}
	}
	
	func disconnectWatches() -> Void {
        podWatcher.cancel()
        jobWatcher.cancel()
	}
	
	func connectWatches() async throws -> Void {
        Task {
            let podStream = podWatcher.start()
            for try await event in podStream {
                let pod = event.resource
                let uuid = try! UUID.fromK8sMetadata(resource: pod)
                switch event.type {
                case .added:
                    DispatchQueue.main.async {
                        do {
                            try self.setPod(pod: pod)
                        } catch {
                            print(error)
                        }
                    }
                case .modified:
                    DispatchQueue.main.async {
                        do {
                            try self.setPod(pod: pod)
                        } catch {
                            print(error)
                        }
                    }
                case .deleted:
                    DispatchQueue.main.async {
                        self.removePod(uid: uuid)
                    }
                default:
                    break
                }
            }
        }
        
        Task {
            let jobStream = jobWatcher.start()
            for try await event in jobStream {
                let job = event.resource
                let uuid = try! UUID.fromK8sMetadata(resource: job)
                switch event.type {
                case .added:
                    DispatchQueue.main.async {
                        do {
                            try self.setJob(job: job)
                        } catch {
                            print(error)
                        }
                    }
                case .modified:
                    DispatchQueue.main.async {
                        do {
                            try self.setJob(job: job)
                        } catch {
                            print(error)
                        }
                    }
                case .deleted:
                    DispatchQueue.main.async {
                        self.removeJob(uid: uuid)
                    }
                default:
                    break
                }
            }
        }
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
	
	func restartDeployment(deployment: apps.v1.Deployment) async throws -> Void {
		let deployment = try await client.appsV1.deployments.restartDeployment(in: namespaceManager.namespace, name: deployment.name!)
		try self.deployments.replaceOrAdd(d: deployment)
	}
	
	func unsuspendCronJob(cronjob: batch.v1.CronJob) async -> Void {
		print("starting unsuspend")
		do {
			let updatedCronjob = try await client.batchV1.cronJobs.unsuspend(in: .default, name: cronjob.name ?? "")
			try self.cronjobs.replaceOrAdd(cj: updatedCronjob)
		} catch {
			print(error)
			DispatchQueue.main.async {
				self.errors.append(error)
			}
		}
	}
	func suspendCronJob(cronjob: batch.v1.CronJob) async -> Void {
		print("starting suspend")
		do {
			let updatedCronjob = try await client.batchV1.cronJobs.suspend(in: .default, name: cronjob.name ?? "")
			try self.cronjobs.replaceOrAdd(cj: updatedCronjob)
		} catch {
			print(error)
			DispatchQueue.main.async {
				self.errors.append(error)
			}
		}
	}
	func deleteResource(resource:KubernetesAPIResource) async throws -> Void {
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
			try await refreshCronJobs(ns: self.namespaceManager.namespace)
		case "Job":
			_ = try await  client.batchV1.jobs.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			
		case "Deployment":
			_ = try await  client.appsV1.deployments.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			try await refreshDeployments(ns: self.namespaceManager.namespace)
			
		case "Pod":
			_ = try await  client.pods.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			
		case "ConfigMap":
			_ = try await  client.configMaps.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			try await refreshConfigMaps(ns: self.namespaceManager.namespace)
		case "Secret":
			_ = try await  client.secrets.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			try await refreshSecrets(ns: self.namespaceManager.namespace)
		case "Ingress":
			_ = try await  client.networkingV1.ingresses.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			try await  refreshIngresses(ns: self.namespaceManager.namespace)
		case "Service":
			_ = try await client.services.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			try await refreshSecrets(ns: self.namespaceManager.namespace)
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
		return batch.v1.CronJob(metadata: meta.v1.ObjectMeta(clusterName: "directly-apply-main-cluster", creationTimestamp: Date(), deletionGracePeriodSeconds: 100, labels: ["feed" : "ziprecruiter"], managedFields: [meta.v1.ManagedFieldsEntry](), name: "great cronjob", namespace: "default", ownerReferences: [meta.v1.OwnerReference](), resourceVersion: "appv1", uid: "F3493650-A9DF-410F-B1A4-E8F5386E5B53"), spec: batch.v1.CronJobSpec(failedJobsHistoryLimit: 5, jobTemplate: batch.v1.JobTemplateSpec(), schedule: "15 10 * * *", startingDeadlineSeconds: 100, successfulJobsHistoryLimit: 2, suspend: false), status: batch.v1.CronJobStatus(active: [core.v1.ObjectReference](), lastScheduleTime: Date()))
	}
	
	static func dummyPod() -> core.v1.Pod {
		return core.v1.Pod(metadata: meta.v1.ObjectMeta(clusterName: "directly-apply-main-cluster", creationTimestamp: Date(), deletionGracePeriodSeconds: 100, labels: ["feed" : "ziprecruiter"], managedFields: [meta.v1.ManagedFieldsEntry](), name: "great pod", namespace: "default", ownerReferences: [meta.v1.OwnerReference](), resourceVersion: "appv1", uid: "F3493650-A9DF-410F-B1A4-E8F5386E5B46"), spec: core.v1.PodSpec(activeDeadlineSeconds: 400, containers: [core.v1.Container](), enableServiceLinks: true, ephemeralContainers: [core.v1.EphemeralContainer](), hostAliases: [core.v1.HostAlias](), hostname: "bigboy.directlyapply.com", initContainers: [core.v1.Container](), nodeName: "big-boy", readinessGates: [core.v1.PodReadinessGate](), restartPolicy: "Always", topologySpreadConstraints: [core.v1.TopologySpreadConstraint](), volumes: [core.v1.Volume]()), status: core.v1.PodStatus(startTime: Date()))
	}
}
