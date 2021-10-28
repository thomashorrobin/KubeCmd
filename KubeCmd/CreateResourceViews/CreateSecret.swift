//
//  CreateSecret.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 06/10/2021.
//

import SwiftUI

struct CreateSecret: View {
	@State private var name: String = ""
    var body: some View {
		Form{
			Text("New Secret").font(.title2)
			TextField("Name", text: $name)
		}.padding(40).frame(width: 500, height: 300, alignment: .center)
    }
}

struct CreateSecret_Previews: PreviewProvider {
    static var previews: some View {
        CreateSecret()
    }
}
