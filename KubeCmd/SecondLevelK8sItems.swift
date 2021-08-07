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
            KubernetesAPIResourceList(resources: Array(resources.deployments.values))
        case KubernetesResources.pods:
            KubernetesAPIResourceList(resources: Array(resources.pods.values))
        case KubernetesResources.secrets:
            KubernetesAPIResourceList(resources: Array(resources.secrets.values))
        case KubernetesResources.configmaps:
            KubernetesAPIResourceList(resources: Array(resources.configmaps.values))
        case KubernetesResources.cronjobs:
            KubernetesAPIResourceList(resources: Array(resources.cronjobs.values))
        case KubernetesResources.jobs:
            KubernetesAPIResourceList(resources: Array(resources.jobs.values))
        }
    }
}

//struct SecondLevelK8sItems_Previews: PreviewProvider {
//    static var previews: some View {
//        SecondLevelK8sItems()
//    }
//}
