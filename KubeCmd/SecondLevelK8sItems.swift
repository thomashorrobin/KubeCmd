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
			KubernetesAPIResourceList(resources: Array(resources.deployments.items), sortingFucntion: nameSort, namespace: resources.namespace)
		case KubernetesResources.pods:
			KubernetesAPIResourceList(resources: Array(resources.pods.values), sortingFucntion: dateSort, namespace: resources.namespace)
		case KubernetesResources.secrets:
			KubernetesAPIResourceList(resources: Array(resources.secrets.items), sortingFucntion: nameSort, namespace: resources.namespace)
		case KubernetesResources.configmaps:
			KubernetesAPIResourceList(resources: Array(resources.configmaps.items), sortingFucntion: nameSort, namespace: resources.namespace)
		case KubernetesResources.cronjobs:
			KubernetesAPIResourceList(resources: Array(resources.cronjobs.items), sortingFucntion: nameSort, namespace: resources.namespace)
		case KubernetesResources.jobs:
			KubernetesAPIResourceList(resources: Array(resources.jobs.values), sortingFucntion: dateSort, namespace: resources.namespace)
		case .ingresses:
			KubernetesAPIResourceList(resources: Array(resources.ingresses.items), sortingFucntion: nameSort, namespace: resources.namespace)
		case .services:
			KubernetesAPIResourceList(resources: Array(resources.services.items), sortingFucntion: nameSort, namespace: resources.namespace)
		}
	}
}

struct SecondLevelK8sItems_Previews: PreviewProvider {
    static var previews: some View {
        SecondLevelK8sItems()
    }
}
