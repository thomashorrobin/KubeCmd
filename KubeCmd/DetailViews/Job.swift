//
//  Job.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/07/2021.
//

import SwiftUI
import SwiftkubeModel

struct Job: View {
    var job:batch.v1.Job
    init(res:KubernetesAPIResource) {
        self.job = res as! batch.v1.Job
    }
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(5), content: {
            Text("Status").font(.title2)
            Text("UUID: \(job.metadata?.uid ?? "error")")
            Divider().padding(.vertical, 30)
            Text("Spec").font(.title2)
        })
    }
}

//struct Job_Previews: PreviewProvider {
//    static var previews: some View {
//        Job()
//    }
//}
