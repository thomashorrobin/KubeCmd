//
//  CreateJob.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 06/10/2021.
//

import SwiftUI

struct CreateJob: View {
	@State private var name: String = ""
	@State private var dockerrepo: String = ""
    var body: some View {
		Form{
			Text("New Job").font(.title2)
			TextField("Name", text: $name)
			TextField("Repo", text: $dockerrepo)
		}.padding(40).frame(width: 500, height: 300, alignment: .center)
    }
}

struct CreateJob_Previews: PreviewProvider {
    static var previews: some View {
        CreateJob()
    }
}
