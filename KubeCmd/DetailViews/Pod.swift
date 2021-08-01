//
//  Pod.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/07/2021.
//

import SwiftUI
import SwiftkubeModel

struct Pod: View {
    var pod:core.v1.Pod
    init(res:KubernetesAPIResource) {
        self.pod = res as! core.v1.Pod
    }
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(5), content: {
            Text("Status").font(.title2)
            Text("UUID: \(pod.metadata?.uid ?? "error")")
            Text("Reason: \(pod.status?.reason ?? "xxxx")")
            Divider().padding(.vertical, 30)
            Text("Spec").font(.title2)
        })
    }
}

//struct Pod_Previews: PreviewProvider {
//    static var previews: some View {
//        Pod()
//    }
//}
