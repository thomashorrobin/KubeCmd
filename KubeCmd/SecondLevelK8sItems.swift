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
            KubernetesAPIResourceList(resources: Array(resources.deployments.values), sortingFucntion: nameSort)
        case KubernetesResources.pods:
            KubernetesAPIResourceList(resources: Array(resources.pods.values), sortingFucntion: dateSort)
        case KubernetesResources.secrets:
            KubernetesAPIResourceList(resources: Array(resources.secrets.values), sortingFucntion: nameSort)
        case KubernetesResources.configmaps:
            KubernetesAPIResourceList(resources: Array(resources.configmaps.values), sortingFucntion: nameSort)
        case KubernetesResources.cronjobs:
            KubernetesAPIResourceList(resources: Array(resources.cronjobs.values), sortingFucntion: nameSort)
        case KubernetesResources.jobs:
            KubernetesAPIResourceList(resources: Array(resources.jobs.values), sortingFucntion: dateSort)
        }
    }
}

//struct SecondLevelK8sItems_Previews: PreviewProvider {
//    static var previews: some View {
//        SecondLevelK8sItems()
//    }
//}
