//
//  ClusterResources.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 10/08/2021.
//

import Foundation
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
	var client:KubernetesClient
	var k8sTasks = [SwiftkubeClientTask]()
	
	init(client:KubernetesClient) {
		self.client = client
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
		k8sTasks.append(try! client.batchV1Beta1.cronJobs.watch(in: .default, retryStrategy: strategy) { (event, resource) in
			let uuid = try! UUID.fromK8sMetadata(resource: resource)
			switch event.rawValue {
			case "ADDED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "MODIFIED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "DELETED":
				DispatchQueue.main.async {
					self.deleteResource(uuid: uuid, kind: resource.kind)
				}
			default:
				break
			}
		})
		k8sTasks.append(try! client.secrets.watch(in: .default, retryStrategy: strategy) { (event, resource) in
			let uuid = try! UUID.fromK8sMetadata(resource: resource)
			switch event.rawValue {
			case "ADDED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "MODIFIED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "DELETED":
				DispatchQueue.main.async {
					self.deleteResource(uuid: uuid, kind: resource.kind)
				}
			default:
				break
			}
		})
		k8sTasks.append(try! client.configMaps.watch(in: .default, retryStrategy: strategy) { (event, resource) in
			let uuid = try! UUID.fromK8sMetadata(resource: resource)
			switch event.rawValue {
			case "ADDED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "MODIFIED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "DELETED":
				DispatchQueue.main.async {
					self.deleteResource(uuid: uuid, kind: resource.kind)
				}
			default:
				break
			}
		})
		k8sTasks.append(try! client.appsV1.deployments.watch(in: .default, retryStrategy: strategy) { (event, resource) in
			let uuid = try! UUID.fromK8sMetadata(resource: resource)
			switch event.rawValue {
			case "ADDED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "MODIFIED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "DELETED":
				DispatchQueue.main.async {
					self.deleteResource(uuid: uuid, kind: resource.kind)
				}
			default:
				break
			}
		})
		k8sTasks.append(try! client.pods.watch(in: .default, retryStrategy: strategy) { (event, resource) in
			let uuid = try! UUID.fromK8sMetadata(resource: resource)
			switch event.rawValue {
			case "ADDED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "MODIFIED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "DELETED":
				DispatchQueue.main.async {
					self.deleteResource(uuid: uuid, kind: resource.kind)
				}
			default:
				break
			}
		})
		k8sTasks.append(try! client.batchV1.jobs.watch(in: .default, retryStrategy: strategy) { (event, resource) in
			let uuid = try! UUID.fromK8sMetadata(resource: resource)
			switch event.rawValue {
			case "ADDED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "MODIFIED":
				DispatchQueue.main.async {
					self.setResource(resource: resource)
				}
			case "DELETED":
				DispatchQueue.main.async {
					self.deleteResource(uuid: uuid, kind: resource.kind)
				}
			default:
				break
			}
		})
		
	}
	
	func loadData() -> Void {
		do {
			let pods = try client.pods.list(in: .default).wait().items
			for pod in pods {
				let uuid = try! UUID.fromK8sMetadata(resource: pod)
				self.pods[uuid] = pod
			}
			let configmaps = try client.configMaps.list(in: .default).wait().items
			for configmap in configmaps {
				let uuid = try! UUID.fromK8sMetadata(resource: configmap)
				self.configmaps[uuid] = configmap
			}
			let secrets = try client.secrets.list(in: .default).wait().items
			for secret in secrets {
				let uuid = try! UUID.fromK8sMetadata(resource: secret)
				self.secrets[uuid] = secret
			}
			let cronjobs = try client.batchV1Beta1.cronJobs.list(in: .default).wait().items
			for cronjob in cronjobs {
				let uuid = try! UUID.fromK8sMetadata(resource: cronjob)
				self.cronjobs[uuid] = cronjob
			}
			let jobs = try client.batchV1.jobs.list(in: .default).wait().items
			for job in jobs {
				let uuid = try! UUID.fromK8sMetadata(resource: job)
				self.jobs[uuid] = job
			}
			let deployments = try client.appsV1.deployments.list(in: .default).wait().items
			for deployment in deployments {
				let uuid = try! UUID.fromK8sMetadata(resource: deployment)
				self.deployments[uuid] = deployment
			}
		} catch {
			print("Unknown error: \(error)")
		}
	}
	
	func setSelectedResource(resource: KubernetesResources) -> Void {
		selectedResource = resource
	}
	
	func addJob(job: batch.v1.Job) -> Void {
		do {
			let _ = try client.batchV1.jobs.create(inNamespace: .default, job).wait()
		} catch {
			print(error)
		}
	}
	
	func restartDeployment(deployment: apps.v1.Deployment) throws -> Void {
		let formatter = ISO8601DateFormatter()
		var newDeployment = deployment
		newDeployment.spec?.template.metadata?.annotations?["kubectl.kubernetes.io/restartedAt"] = formatter.string(from: Date())
		newDeployment = try client.appsV1.deployments.update(newDeployment).wait()
		setResource(resource: newDeployment)
	}
	
	func unsuspendCronJob(cronjob: batch.v1beta1.CronJob) -> Void {
		var newThing = cronjob
		newThing.spec?.suspend = false
		do {
			let x = try client.batchV1Beta1.cronJobs.update(newThing).wait()
			setResource(resource: x)
		} catch {
			print(error)
		}
	}
	func suspendCronJob(cronjob: batch.v1beta1.CronJob) -> Void {
		var newThing = cronjob
		newThing.spec?.suspend = true
		do {
			let x = try client.batchV1Beta1.cronJobs.update(newThing).wait()
			setResource(resource: x)
		} catch {
			print(error)
		}
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
	func deleteResource(resource:KubernetesAPIResource) -> Void {
		let deleteOptions = meta.v1.DeleteOptions(
			gracePeriodSeconds: 10,
			propagationPolicy: "Foreground"
		)
		guard let metadata = resource.metadata else { return }
		guard let name = metadata.name else { return }
		guard let namespace = metadata.namespace else { return }
		switch resource.kind {
		case "CronJob":
			_ = client.batchV1Beta1.cronJobs.delete(in: .namespace(namespace), name: name, options: deleteOptions)
		case "Job":
			_ = client.batchV1.jobs.delete(in: .namespace(namespace), name: name, options: deleteOptions)
			
		case "Deployment":
			_ = client.appsV1.deployments.delete(in: .namespace(namespace), name: name, options: deleteOptions)
			
		case "Pod":
			_ = client.pods.delete(in: .namespace(namespace), name: name, options: deleteOptions)
			
		case "ConfigMap":
			_ = client.configMaps.delete(in: .namespace(namespace), name: name, options: deleteOptions)
			
		case "Secret":
			_ = client.secrets.delete(in: .namespace(namespace), name: name, options: deleteOptions)
		default:
			print("resource.kind not handled by deleteResource()")
		}
		print("sucessfully deleted \(resource.name ?? "nil") (\(resource.kind))")
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
