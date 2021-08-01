//
//  Deployment.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/07/2021.
//

import SwiftUI
import SwiftkubeModel

struct Deployment: View {
    let deployment:apps.v1.Deployment
    init(res:KubernetesAPIResource) {
        self.deployment = res as! apps.v1.Deployment
    }
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(5), content: {
            Text("Status").font(.title2)
            Text("UUID: \(deployment.metadata?.uid ?? "error")")
            Text("Suspended: \(String(deployment.spec?.paused ?? true))")
            Divider().padding(.vertical, 30)
            Text("Spec").font(.title2)
        })
    }
}

//struct Deployment_Previews: PreviewProvider {
//    static var previews: some View {
//        Deployment()
//    }
//}
