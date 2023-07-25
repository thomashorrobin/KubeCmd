//
//  KubernetesAPIResourceList.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 18/06/2021.
//

import SwiftUI
import SwiftkubeClient
import SwiftkubeModel

func nameSort(x:any KubernetesAPIResource, y:any KubernetesAPIResource) -> Bool {
	return x.name! < y.name!
}

func dateSort(x:any KubernetesAPIResource, y:any KubernetesAPIResource) -> Bool {
	return x.metadata!.creationTimestamp! > y.metadata!.creationTimestamp!
}

struct KubernetesAPIResourceList: View, NamespaceFilterable {
	@EnvironmentObject var clusterResources: ClusterResources
	var resources: [any KubernetesAPIResource]
	var sortingFucntion: (any KubernetesAPIResource, any KubernetesAPIResource) -> Bool
	var namespace: NamespaceSelector
	var resourceType: String
	@State private var searchText = ""
	func createSecret(secret: core.v1.Secret) {
			Task {
				let createdSecret = try await clusterResources.client.secrets.create(inNamespace: .default, secret)
                try clusterResources.secrets.upsert(resource: createdSecret)
			}
	}
	func createConfigMap(configMap: core.v1.ConfigMap) {
		Task {
			let createdConfigMap = try await clusterResources.client.configMaps.create(inNamespace: .default, configMap)
            try clusterResources.configmaps.upsert(resource: createdConfigMap)
		}
	}
	
	
	var body: some View {
		List{
			ForEach(searchResults.filter(filterByNamespace).sorted(by: sortingFucntion), id: \.metadata!.uid) { r in
				KubernetesAPIResourceRow(resource: r)
			}
			if resourceType == "secrets" {
				Button("New Secret", action: {
					CreateSecret(onSecretCreate: createSecret).openInWindow(title: "Secret", sender: self)
				}
				).buttonStyle(.borderedProminent)
			}
			if resourceType == "configmaps" {
				Button("New ConfigMap", action: {
					CreateConfigMap(onConfigMapCreate: createConfigMap).openInWindow(title: "Config Map", sender: self)}
				).buttonStyle(.borderedProminent)
			}
		}.searchable(text: $searchText, prompt: "Search \(resourceType)")
	}
	
	var searchResults: [any KubernetesAPIResource] {
		if searchText.isEmpty {
			return resources
		} else {
			return resources.filter { $0.name!.contains(searchText) }
		}
	}
}

struct KubernetesAPIResourceRow: View {
	var resource: any KubernetesAPIResource
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
