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
	@Published var ingresses = [UUID:networking.v1.Ingress]()
	@Published var services = [UUID:core.v1.Service]()
	@Published var namespace = NamespaceSelector.namespace("default")
	@Published var namespaces = core.v1.NamespaceList(metadata: nil, items: [core.v1.Namespace]())
	var client:KubernetesClient
	var k8sTasks = [SwiftkubeClientTask]()
	
	init(client:KubernetesClient) {
		self.client = client
	}
	
	func refreshData() -> Void {
		self.pods.removeAll()
		self.configmaps.removeAll()
		self.secrets.removeAll()
		self.cronjobs.removeAll()
		self.jobs.removeAll()
		self.deployments.removeAll()
		self.loadData(namespace: .allNamespaces)
	}
	
	func fetchNamespaces() throws -> Void {
		self.namespaces = try client.namespaces.list(options: nil).wait()
	}
	
	func followLogs(name: String, cb: @escaping LogWatcherCallback.LineHandler) throws -> SwiftkubeClientTask {
		return try client.pods.follow(name: name, lineHandler: cb)
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
		k8sTasks.append(try! client.networkingV1.ingresses.watch(in: .default, retryStrategy: strategy) { (event, resource) in
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
		k8sTasks.append(try! client.services.watch(in: .default, retryStrategy: strategy) { (event, resource) in
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
	
	func loadData(namespace: NamespaceSelector) -> Void {
		do {
			let pods = try client.pods.list(in: namespace).wait().items
			for pod in pods {
				let uuid = try! UUID.fromK8sMetadata(resource: pod)
				self.pods[uuid] = pod
			}
			let configmaps = try client.configMaps.list(in: namespace).wait().items
			for configmap in configmaps {
				let uuid = try! UUID.fromK8sMetadata(resource: configmap)
				self.configmaps[uuid] = configmap
			}
			let secrets = try client.secrets.list(in: namespace).wait().items
			for secret in secrets {
				let uuid = try! UUID.fromK8sMetadata(resource: secret)
				self.secrets[uuid] = secret
			}
			let cronjobs = try client.batchV1Beta1.cronJobs.list(in: namespace).wait().items
			for cronjob in cronjobs {
				let uuid = try! UUID.fromK8sMetadata(resource: cronjob)
				self.cronjobs[uuid] = cronjob
			}
			let jobs = try client.batchV1.jobs.list(in: namespace).wait().items
			for job in jobs {
				let uuid = try! UUID.fromK8sMetadata(resource: job)
				self.jobs[uuid] = job
			}
			let deployments = try client.appsV1.deployments.list(in: namespace).wait().items
			for deployment in deployments {
				let uuid = try! UUID.fromK8sMetadata(resource: deployment)
				self.deployments[uuid] = deployment
			}
			let ingresses = try client.networkingV1.ingresses.list(in: namespace).wait().items
			for ingress in ingresses {
				let uuid = try! UUID.fromK8sMetadata(resource: ingress)
				self.ingresses[uuid] = ingress
			}
			let services = try client.services.list(in: namespace).wait().items
			for service in services {
				let uuid = try! UUID.fromK8sMetadata(resource: service)
				self.services[uuid] = service
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
			let job = try client.batchV1.jobs.create(inNamespace: .default, job).wait()
			setResource(resource: job)
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
		case "Ingress":
			ingresses.removeValue(forKey: uuid)
		case "Service":
			services.removeValue(forKey: uuid)
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
			_ = client.batchV1Beta1.cronJobs.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
		case "Job":
			_ = client.batchV1.jobs.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			
		case "Deployment":
			_ = client.appsV1.deployments.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			
		case "Pod":
			_ = client.pods.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			
		case "ConfigMap":
			_ = client.configMaps.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
			
		case "Secret":
			_ = client.secrets.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
		case "Ingress":
			_ = client.networkingV1.ingresses.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
		case "Service":
			_ = client.services.delete(inNamespace: .namespace(namespace), name: name, options: deleteOptions)
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
		case "Ingress":
			ingresses[uuid] = (resource as! networking.v1.Ingress)
		case "Service":
			services[uuid] = (resource as! core.v1.Service)
		default:
			print("error: resource not handled")
		}
	}
	private func removeLabelFromMetadata(metadata:meta.v1.ObjectMeta?, key:String) -> meta.v1.ObjectMeta? {
		guard var labels = metadata?.labels else { return metadata }
		labels.removeValue(forKey: key)
		var newMetadata = metadata!
		newMetadata.labels = labels
		return newMetadata
	}
	func deleteLabel(resource:UUID, key:String) -> Void {
		if var r:core.v1.Pod = pods[resource] {
			r.metadata = removeLabelFromMetadata(metadata: r.metadata, key: key)
			let updatedPod = try! client.pods.update(inNamespace: namespace, r).wait()
			setResource(resource: updatedPod)
		}
		if var r:core.v1.Secret = secrets[resource] {
			r.metadata = removeLabelFromMetadata(metadata: r.metadata, key: key)
			let secret = try! client.secrets.update(inNamespace: namespace, r).wait()
			setResource(resource: secret)
		}
		if var r:core.v1.ConfigMap = configmaps[resource] {
			r.metadata = removeLabelFromMetadata(metadata: r.metadata, key: key)
			let configMap = try! client.configMaps.update(inNamespace: namespace, r).wait()
			setResource(resource: configMap)
		}
		if var r:batch.v1.Job = jobs[resource] {
			r.metadata = removeLabelFromMetadata(metadata: r.metadata, key: key)
			let job = try! client.batchV1.jobs.update(inNamespace: namespace, r).wait()
			setResource(resource: job)
		}
		if var r:batch.v1beta1.CronJob = cronjobs[resource] {
			r.metadata = removeLabelFromMetadata(metadata: r.metadata, key: key)
			let cronJob = try! client.batchV1Beta1.cronJobs.update(inNamespace: namespace, r).wait()
			setResource(resource: cronJob)
		}
		if var r:apps.v1.Deployment = deployments[resource] {
			r.metadata = removeLabelFromMetadata(metadata: r.metadata, key: key)
			let deployment = try! client.appsV1.deployments.update(inNamespace: namespace, r).wait()
			setResource(resource: deployment)
		}
		if var r:networking.v1.Ingress = ingresses[resource] {
			r.metadata = removeLabelFromMetadata(metadata: r.metadata, key: key)
			let ingress = try! client.networkingV1.ingresses.update(inNamespace: namespace, r).wait()
			setResource(resource: ingress)
		}
		if var r:core.v1.Service = services[resource] {
			r.metadata = removeLabelFromMetadata(metadata: r.metadata, key: key)
			let service = try! client.services.update(inNamespace: namespace, r).wait()
			setResource(resource: service)
		}
	}
	func addLabel(resource:UUID, key:String, value:String) -> Void {
		if let r:core.v1.Pod = pods[resource] {
			guard var labels = r.metadata?.labels else { return }
			labels[key] = value
			var newResource = r
			newResource.metadata?.labels = labels
			let _ = try! client.pods.update(inNamespace: namespace, newResource).wait()
		}
		if let r:core.v1.Secret = secrets[resource] {
			guard var labels = r.metadata?.labels else { return }
			labels[key] = value
			var newResource = r
			newResource.metadata?.labels = labels
			let _ = try! client.secrets.update(inNamespace: namespace, newResource).wait()
		}
		if let r:core.v1.ConfigMap = configmaps[resource] {
			guard var labels = r.metadata?.labels else { return }
			labels[key] = value
			var newResource = r
			newResource.metadata?.labels = labels
			let _ = try! client.configMaps.update(inNamespace: namespace, newResource).wait()
		}
		if let r:batch.v1.Job = jobs[resource] {
			guard var labels = r.metadata?.labels else { return }
			labels[key] = value
			var newResource = r
			newResource.metadata?.labels = labels
			let _ = try! client.batchV1.jobs.update(inNamespace: namespace, newResource).wait()
		}
		if let r:batch.v1beta1.CronJob = cronjobs[resource] {
			guard var labels = r.metadata?.labels else { return }
			labels[key] = value
			var newResource = r
			newResource.metadata?.labels = labels
			let _ = try! client.batchV1Beta1.cronJobs.update(inNamespace: namespace, newResource).wait()
		}
		if let r:apps.v1.Deployment = deployments[resource] {
			guard var labels = r.metadata?.labels else { return }
			labels[key] = value
			var newResource = r
			newResource.metadata?.labels = labels
			let _ = try! client.appsV1.deployments.update(inNamespace: namespace, newResource).wait()
		}
		if let r:networking.v1.Ingress = ingresses[resource] {
			guard var labels = r.metadata?.labels else { return }
			labels[key] = value
			var newResource = r
			newResource.metadata?.labels = labels
			let _ = try! client.networkingV1.ingresses.update(inNamespace: namespace, newResource).wait()
		}
		if let r:core.v1.Service = services[resource] {
			guard var labels = r.metadata?.labels else { return }
			labels[key] = value
			var newResource = r
			newResource.metadata?.labels = labels
			let _ = try! client.services.update(inNamespace: namespace, newResource).wait()
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
