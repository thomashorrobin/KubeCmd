//
//  CreateSecret.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 06/10/2021.
//

import SwiftUI

struct CreateSecret: View {
    var body: some View {
        Text("New Secret").font(.title2).frame(width: 500, height: 300, alignment: .bottomLeading)
    }
}

struct CreateSecret_Previews: PreviewProvider {
    static var previews: some View {
        CreateSecret()
    }
}
