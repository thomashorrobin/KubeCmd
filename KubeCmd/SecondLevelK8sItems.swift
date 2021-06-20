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
            KubernetesAPIResourceList(resources: resources.deployments)
        case KubernetesResources.pods:
            KubernetesAPIResourceList(resources: resources.pods)
        case KubernetesResources.secrets:
            KubernetesAPIResourceList(resources: resources.secrets)
        case KubernetesResources.configmaps:
            KubernetesAPIResourceList(resources: resources.configmaps)
        case KubernetesResources.cronjobs:
            KubernetesAPIResourceList(resources: resources.cronjobs)
        case KubernetesResources.jobs:
            KubernetesAPIResourceList(resources: resources.jobs)
        }
    }
}

//struct SecondLevelK8sItems_Previews: PreviewProvider {
//    static var previews: some View {
//        SecondLevelK8sItems()
//    }
//}
