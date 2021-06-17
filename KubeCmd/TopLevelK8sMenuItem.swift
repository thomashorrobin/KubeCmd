//
//  TopLevelK8sMenuItem.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 17/06/2021.
//

import SwiftUI

struct TopLevelK8sMenuItem: View {
    var name: String
    var imageName: String
    var itemCount: Int = 0
    var body: some View {
        HStack{
            Image(imageName)
            Text(name).bold()
            Spacer()
            Text(String(itemCount)).padding(.trailing, 20)
        }.padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
}

struct TopLevelK8sMenuItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TopLevelK8sMenuItem(name: "CronJobs", imageName: "cronjob", itemCount: 41)
            TopLevelK8sMenuItem(name: "Pods", imageName: "pod", itemCount: 154)
            TopLevelK8sMenuItem(name: "Deployments", imageName: "deploy", itemCount: 5)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
