//
//  NamespaceFilterable.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/09/2021.
//

import Foundation
import SwiftkubeClient
import SwiftkubeModel

class NamespaceManager: ObservableObject {
    private var client:KubernetesClient
    @Published var namespace = NamespaceSelector.namespace("default")
    @Published var namespaces:core.v1.NamespaceList = core.v1.NamespaceList(items: [])
    init(client:KubernetesClient) throws {
        self.client = client
        try refreashNamespaces()
    }
    func setNamespace(namespace namespaceSelector: NamespaceSelector) throws {
        self.namespace = namespaceSelector
        try refreashNamespaces()
    }
    private func refreashNamespaces() throws {
        Task {
            let ns = try await client.namespaces.list()
            DispatchQueue.main.sync {
                self.namespaces = ns
            }
        }
    }
}

protocol NamespaceFilterable {
	var namespace: NamespaceSelector { get }
}

extension NamespaceFilterable {
    func filterByNamespace(kubernetesAPIResource: any KubernetesAPIResource) -> Bool {
		guard let metadata = kubernetesAPIResource.metadata else { return false }
		guard let ns = metadata.namespace else { return false }
		let x = NamespaceSelector.namespace(ns)
		let namespaceMatch = x == namespace
		return namespaceMatch
	}
}
