//
//  TopLevelK8sMenuItem.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 17/06/2021.
//

import SwiftUI

struct TopLevelK8sMenuItem: View {
	var a:() ->Void
	var name: String
	var imageName: String
	var itemCount: Int = 0
	var body: some View {
		Button(action: a) {
			HStack{
				Image(imageName)
				Text(name).bold()
				Spacer()
				Text(String(itemCount)).padding(.trailing, 20)
			}.padding(.all, 10)
				.contentShape(Rectangle())
		}.buttonStyle(PlainButtonStyle())
	}
}

func dummyFunc() -> Void {
	return
}

struct TopLevelK8sMenuItem_Previews: PreviewProvider {
	
	static var previews: some View {
		Group {
			TopLevelK8sMenuItem(a: dummyFunc, name: "CronJobs", imageName: "cronjob", itemCount: 41)
			TopLevelK8sMenuItem(a: dummyFunc, name: "Pods", imageName: "pod", itemCount: 154)
			TopLevelK8sMenuItem(a: dummyFunc, name: "Deployments", imageName: "deploy", itemCount: 5)
		}
		.previewLayout(.fixed(width: 300, height: 70))
	}
}
