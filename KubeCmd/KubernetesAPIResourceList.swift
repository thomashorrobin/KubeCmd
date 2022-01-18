//
//  KubernetesAPIResourceList.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 18/06/2021.
//

import SwiftUI
import SwiftkubeClient
import SwiftkubeModel

func nameSort(x:KubernetesAPIResource, y:KubernetesAPIResource) -> Bool {
	return x.name! < y.name!
}

func dateSort(x:KubernetesAPIResource, y:KubernetesAPIResource) -> Bool {
	return x.metadata!.creationTimestamp! > y.metadata!.creationTimestamp!
}

struct KubernetesAPIResourceList: View, NamespaceFilterable {
	var resources: [KubernetesAPIResource]
	var sortingFucntion: (KubernetesAPIResource, KubernetesAPIResource) -> Bool
	var namespace: NamespaceSelector
	@State private var searchText = ""
	var body: some View {
		List{
			ForEach(searchResults.filter(filterByNamespace).sorted(by: sortingFucntion), id: \.metadata!.uid) { r in
				KubernetesAPIResourceRow(resource: r)
			}
		}.searchable(text: $searchText)
	}
	
	var searchResults: [KubernetesAPIResource] {
	 if searchText.isEmpty {
		 return resources
	 } else {
		 return resources.filter { $0.name!.contains(searchText) }
	 }
 }
}

struct KubernetesAPIResourceRow: View {
	var resource: KubernetesAPIResource
	var body: some View {
		HStack{
			NavigationLink(resource.name ?? "unknown", destination: K8sResourceDetail(resource: resource )).buttonStyle(PlainButtonStyle()).navigationTitle("\(resource.kind)s")
			Spacer()
			VStack(alignment: .trailing, content: {
				Text(resource.kind).bold()
				Text(resource.apiVersion).italic()
			})
		}.padding(.all, 20)
	}
}
