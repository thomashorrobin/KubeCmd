//
//  Secret.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/07/2021.
//

import SwiftUI
import SwiftkubeModel

struct Secret: View {
    let secret:core.v1.Secret
    init(res:KubernetesAPIResource) {
        self.secret = res as! core.v1.Secret
    }
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(5), content: {
            Text("Data").font(.title2)
            ForEach((secret.data?.sorted(by: >))!, id: \.key) { x in
                Text(x.key)
                Text(x.value).italic()
            }
        })
    }
}
