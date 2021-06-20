//
//  K8sResourceDetail.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/06/2021.
//

import SwiftUI
import SwiftkubeModel

struct K8sResourceDetail: View {
    var resource:KubernetesAPIResource
    var body: some View {
        switch resource.kind {
        case "Pod":
            Text("I'm a pod!!")
        case "CronJob":
            CronJob(res: resource)
        case "Job":
            Text("I'm a Job!!")
        case "Secret":
            Text("I'm a Secret!!")
        case "Deployment":
            Text("I'm a Deployment!!")
        default:
            Text("unknown")
        }
    }
}

struct K8sResourceDetail_Previews: PreviewProvider {
    static var previews: some View {
        K8sResourceDetail(resource: ClusterResources.dummyPod())
    }
}
