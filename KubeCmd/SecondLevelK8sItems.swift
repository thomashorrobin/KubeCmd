//
//  SecondLevelK8sItems.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 17/06/2021.
//

import SwiftUI

struct SecondLevelK8sItems: View {
	@EnvironmentObject var resources: ClusterResources
	var body: some View {
		switch resources.selectedResource {
		case KubernetesResources.deployments:
            KubernetesAPIResourceList(resources: Array(resources.deployments.items.values), sortingFucntion: nameSort, namespace: resources.namespaceManager.namespace, resourceType: "deployments")
		case KubernetesResources.pods:
            KubernetesAPIResourceList(resources: Array(resources.pods.items.values), sortingFucntion: dateSort, namespace: resources.namespaceManager.namespace, resourceType: "pods")
		case KubernetesResources.secrets:
            KubernetesAPIResourceList(resources: Array(resources.secrets.items.values), sortingFucntion: nameSort, namespace: resources.namespaceManager.namespace, resourceType: "secrets")
		case KubernetesResources.configmaps:
            KubernetesAPIResourceList(resources: Array(resources.configmaps.items.values), sortingFucntion: nameSort, namespace: resources.namespaceManager.namespace, resourceType: "configmaps")
		case KubernetesResources.cronjobs:
            KubernetesAPIResourceList(resources: Array(resources.cronjobs.items.values), sortingFucntion: nameSort, namespace: resources.namespaceManager.namespace, resourceType: "cronjobs")
		case KubernetesResources.jobs:
            KubernetesAPIResourceList(resources: Array(resources.jobs.items.values), sortingFucntion: dateSort, namespace: resources.namespaceManager.namespace, resourceType: "jobs")
		case .ingresses:
            KubernetesAPIResourceList(resources: Array(resources.ingresses.items.values), sortingFucntion: nameSort, namespace: resources.namespaceManager.namespace, resourceType: "ingresses")
		case .services:
            KubernetesAPIResourceList(resources: Array(resources.services.items.values), sortingFucntion: nameSort, namespace: resources.namespaceManager.namespace, resourceType: "services")
		}
	}
}

struct SecondLevelK8sItems_Previews: PreviewProvider {
    static var previews: some View {
        SecondLevelK8sItems()
    }
}
