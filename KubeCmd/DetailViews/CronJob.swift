//
//  CronJob.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/06/2021.
//

import SwiftUI
import SwiftkubeModel

struct CronJob: View {
    let cronJob:batch.v1beta1.CronJob
    init(res:KubernetesAPIResource) {
        self.cronJob = res as! batch.v1beta1.CronJob
    }
    var body: some View {
        Text("great detail")
    }
}

struct CronJob_Previews: PreviewProvider {
    static var previews: some View {
        CronJob(res: ClusterResources.dummyCronJob() as KubernetesAPIResource)
    }
}
