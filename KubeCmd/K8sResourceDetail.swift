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
    var body: some View {
        if deleted {
            Text("resource deleted")
        } else {
            ScrollView(.vertical){
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
                    Spacer()
                    Divider()
                    HStack{
                        Spacer()
                        Button(action: deleteResource, label: {
                            Text("Delete")
                        }).padding(.all, 40).disabled(resourceDeleting)
                    }
                })
            }
        }
    }
    func deleteResource() -> Void {
        resourceDeleting = true
        let deleteOptions = meta.v1.DeleteOptions(
            gracePeriodSeconds: 10,
            propagationPolicy: "Foreground"
        )
        do {
            switch resource.kind {
            case "CronJob":
                _ = try client?.batchV1Beta1.cronJobs.delete(in: .namespace(resource.metadata?.namespace ?? "default"), name: resource.name ?? "error", options: deleteOptions).wait()
            case "Job":
                _ = try client?.batchV1.jobs.delete(in: .namespace(resource.metadata?.namespace ?? "default"), name: resource.name ?? "error", options: deleteOptions).wait()
            case "Deployment":
                _ = try client?.appsV1.deployments.delete(in: .namespace(resource.metadata?.namespace ?? "default"), name: resource.name ?? "error", options: deleteOptions).wait()
            case "Pod":
                _ = try client?.pods.delete(in: .namespace(resource.metadata?.namespace ?? "default"), name: resource.name ?? "error", options: deleteOptions).wait()
            case "ConfigMap":
                _ = try client?.configMaps.delete(in: .namespace(resource.metadata?.namespace ?? "default"), name: resource.name ?? "error", options: deleteOptions).wait()
            case "Secret":
                _ = try client?.secrets.delete(in: .namespace(resource.metadata?.namespace ?? "default"), name: resource.name ?? "error", options: deleteOptions).wait()
            default:
                print("resource.kind not handled by deleteResource()")
            }
            resourceDeleting = false
            print("sucessfully deleted \(resource.name ?? "nil") (\(resource.kind))")
            deleted = true
            resources.deleteResource(uuid: try UUID.fromK8sMetadata(resource: resource), kind: resource.kind)
        } catch {
            print("there was a major error from deleteResource() \(error)")
            resourceDeleting = false
        }
    }
}
//
//struct K8sResourceDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        K8sResourceDetail(resource: ClusterResources.dummyPod())
//    }
//}
