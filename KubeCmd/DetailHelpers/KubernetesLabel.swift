//
//  KubernetesLabel.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 10/12/2021.
//

import SwiftUI

struct KubernetesLabel: View {
	var key:String
	var value:String
	var delete:() -> Void
	var body: some View {
		ZStack{
			HStack{
				Text("\(key): \(value)").padding(.all, 6).fixedSize()
				Button(action: delete) {
					Image(systemName: "x.circle")
				}.buttonStyle(PlainButtonStyle())
			}.padding(.all, 5).background(content: {
				RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.5))
			})
		}
	}
}

struct KubernetesLabel_Previews: PreviewProvider {
    static var previews: some View {
		KubernetesLabel(key: "k8s-res", value: "ConfigMap", delete: {})
    }
}
