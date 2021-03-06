//
//  KubernetesMenuView.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 29/12/2020.
//

import SwiftUI
import SwiftkubeClient
import SwiftkubeModel

struct TopLevelK8sMenu: View {
	@EnvironmentObject var resources: ClusterResources
	func filterByNamespace(kubernetesAPIResource: KubernetesAPIResource) -> Bool {
		guard let metadata = kubernetesAPIResource.metadata else { return false }
		guard let ns = metadata.namespace else { return false }
		let x = NamespaceSelector.namespace(ns)
		let namespaceMatch = x == resources.namespace
		return namespaceMatch
	}
	var body: some View {
		List {
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource: .cronjobs)}, name: "CronJobs", imageName: "cronjob", itemCount: resources.cronjobs.filter(self.filterByNamespace).count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:(.deployments))}, name: "Deployments", imageName: "deploy", itemCount: resources.deployments.filter(self.filterByNamespace).count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource: .pods)}, name: "Pods", imageName: "pod", itemCount: resources.pods.values.filter(self.filterByNamespace).count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.jobs)}, name: "Jobs", imageName: "job", itemCount: resources.jobs.values.filter(self.filterByNamespace).count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.configmaps)}, name: "Config Maps", imageName: "cm", itemCount: resources.configmaps.filter(self.filterByNamespace).count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.secrets)}, name: "Secrets", imageName: "secret", itemCount: resources.secrets.filter(self.filterByNamespace).count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.ingresses)}, name: "Ingresses", imageName: "ingress", itemCount: resources.ingresses.filter(self.filterByNamespace).count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.services)}, name: "Services", imageName: "service", itemCount: resources.services.filter(self.filterByNamespace).count)
		}.listStyle(SidebarListStyle())
	}
}
