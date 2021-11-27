//
//  CreateCronjob.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 06/10/2021.
//

import SwiftUI

struct CreateCronjob: View {
	@State private var name: String = ""
	@State private var dockerrepo: String = ""
	@State private var cronJobTime = Date()

    var body: some View {
		Form{
			Text("New Cronjob").font(.title2)
			TextField("Name", text: $name)
			TextField("Repo", text: $dockerrepo)
			DatePicker("Time to run", selection: $cronJobTime, displayedComponents: .hourAndMinute)
			Button("Create"){
				print("hi")
			}
		}.padding(40).frame(width: 500, height: 300, alignment: .center)
    }
}

struct CreateCronjob_Previews: PreviewProvider {
    static var previews: some View {
        CreateCronjob()
    }
}
