//
//  NamespaceFilterable.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/09/2021.
//

import Foundation
import SwiftkubeClient
import SwiftkubeModel

protocol NamespaceFilterable {
	var namespace: NamespaceSelector { get }
}

extension NamespaceFilterable {
	func filterByNamespace(kubernetesAPIResource: KubernetesAPIResource) -> Bool {
		guard let metadata = kubernetesAPIResource.metadata else { return false }
		guard let ns = metadata.namespace else { return false }
		let x = NamespaceSelector.namespace(ns)
		let namespaceMatch = x == namespace
		return namespaceMatch
	}
}
