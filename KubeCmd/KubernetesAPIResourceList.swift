//
//  KubernetesAPIResourceList.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 18/06/2021.
//

import SwiftUI
import SwiftkubeModel

func nameSort(x:KubernetesAPIResource, y:KubernetesAPIResource) -> Bool {
	return x.name! < y.name!
}

func dateSort(x:KubernetesAPIResource, y:KubernetesAPIResource) -> Bool {
	return x.metadata!.creationTimestamp! > y.metadata!.creationTimestamp!
}

struct KubernetesAPIResourceList: View {
	var resources: [KubernetesAPIResource]
	var sortingFucntion: (KubernetesAPIResource, KubernetesAPIResource) -> Bool
	var body: some View {
		List{
			ForEach(resources.sorted(by: sortingFucntion), id: \.metadata!.uid) { r in
				KubernetesAPIResourceRow(resource: r)
			}
		}
	}
}

struct KubernetesAPIResourceRow: View {
	var resource: KubernetesAPIResource
	var body: some View {
		HStack{
			NavigationLink(resource.name ?? "unknown", destination: K8sResourceDetail(resource: resource )).buttonStyle(PlainButtonStyle())
			Spacer()
			VStack(alignment: .trailing, content: {
				Text(resource.kind).bold()
				Text(resource.apiVersion).italic()
			})
		}.padding(.all, 20)
	}
}

//struct KubernetesAPIResourceList_Previews: PreviewProvider {
//
//    static var arr1:[KubernetesAPIResource] = Array(ClusterResources().populateTestData().pods.values)
//    
//    static var previews: some View {
//        KubernetesAPIResourceList(resources: arr1, sortingFucntion: nameSort)
//    }
//}
