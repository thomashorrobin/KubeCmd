//
//  K8sResourceDetail.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 20/06/2021.
//

import SwiftUI
import SwiftkubeModel

struct K8sResourceDetail: View {
    @EnvironmentObject var resources: ClusterResources
    var resource:KubernetesAPIResource
    @State var resourceDeleting = false
    @State var deleted = false
    func deleteResource() -> Void {
        resources.deleteResource(resource: resource)
    }
    var body: some View {
        if deleted {
            Text("resource deleted")
        } else {
            VStack(alignment: .leading, content: {
                HStack {
                    Text(resource.name ?? "no name").font(.title)
                    Spacer()
                    VStack (alignment: .trailing, content: {
                        Text(resource.kind).font(.largeTitle).bold()
                        Text(resource.apiVersion).italic()
                    })
                }.padding(.all, 40)
                Divider()
                ScrollView(.vertical){
                    switch resource.kind {
                    case "Pod":
                        Pod(res: resource).padding(.all, 40)
                    case "CronJob":
                        CronJob(res: resource).padding(.all, 40)
                    case "Job":
                        Job(res: resource).padding(.all, 40)
                    case "Secret":
                        Secret(res: resource).padding(.all, 40)
                    case "Deployment":
                        Deployment(res: resource).padding(.all, 40)
                    case "ConfigMap":
                        ConfigMap(res: resource).padding(.all, 40)
                    default:
                        Text("unknown")
                    }
                }
                Divider()
                HStack{
                    CustomButtons(resource: resource)
                    Spacer()
                    Button(action: deleteResource, label: {
                        Text("Delete")
                    }).padding(.all, 40).disabled(resourceDeleting)
                }
            })
        }
    }
}
//
//struct K8sResourceDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        K8sResourceDetail(resource: ClusterResources.dummyPod())
//    }
//}

struct CustomButtons: View {
    var resource:KubernetesAPIResource
    var body: some View {
        switch resource.kind {
        case "CronJob":
            SuspendButton(cronJob: resource as! batch.v1beta1.CronJob)
        default:
            EmptyView()
        }
    }
}
