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
    func filterByNamespace(kubernetesAPIResource: any KubernetesAPIResource) -> Bool {
        guard let metadata = kubernetesAPIResource.metadata else { return false }
        guard let ns = metadata.namespace else { return false }
        let x = NamespaceSelector.namespace(ns)
        let namespaceMatch = x == resources.namespaceManager.namespace
        return namespaceMatch
    }
    var body: some View {
        List {
            TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource: .cronjobs)}, resourceType: .cronjobs, itemCount: resources.cronjobs.items.values.filter(self.filterByNamespace).count)
            TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:(.deployments))}, resourceType: .deployments, itemCount: resources.deployments.items.values.filter(self.filterByNamespace).count)
            TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource: .pods)}, resourceType: .pods, itemCount: resources.pods.items.values.filter(self.filterByNamespace).count)
            TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.jobs)}, resourceType: .jobs, itemCount: resources.jobs.items.values.filter(self.filterByNamespace).count)
            TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.configmaps)}, resourceType: .configmaps, itemCount: resources.configmaps.items.values.filter(self.filterByNamespace).count)
            TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.secrets)}, resourceType: .secrets, itemCount: resources.secrets.items.values.filter(self.filterByNamespace).count)
            TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.ingresses)}, resourceType: .ingresses, itemCount: resources.ingresses.items.values.filter(self.filterByNamespace).count)
            TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.services)}, resourceType: .services, itemCount: resources.services.items.values.filter(self.filterByNamespace).count)
        }.listStyle(SidebarListStyle())
    }
}
