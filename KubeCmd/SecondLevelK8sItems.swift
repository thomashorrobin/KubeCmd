//
//  SecondLevelK8sItems.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 17/06/2021.
//

import SwiftUI

struct SecondLevelK8sItems: View {
    var selectedResource:KubernetesResources = KubernetesResources.pods
    var body: some View {
        switch selectedResource {
        case KubernetesResources.deployments:
            DeploymentList()
        case KubernetesResources.pods:
            PodList()
        case KubernetesResources.secrets:
            SecretList()
        case KubernetesResources.configmaps:
            ConfigMapList()
        case KubernetesResources.cronjobs:
            CronJobList()
        case KubernetesResources.jobs:
            JobList()
        }
    }
}

//struct SecondLevelK8sItems_Previews: PreviewProvider {
//    static var previews: some View {
//        SecondLevelK8sItems()
//    }
//}
