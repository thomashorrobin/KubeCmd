//
//  File.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 07/03/2023.
//

import Foundation
import SwiftkubeClient
import SwiftkubeModel

internal class ResourceWrapper<Resource: KubernetesAPIResource & NamespacedResource & ListableResource>: ObservableObject {
    @Published private(set) var items:[UUID:Resource]
    private var resourceFetcher: NamespacedGenericKubernetesClient<Resource>
    init(resourceFetcher: NamespacedGenericKubernetesClient<Resource>) {
        self.items = [UUID:Resource]()
        self.resourceFetcher = resourceFetcher
    }
    public func upsert(resource: Resource) throws {
        let uuid = try UUID.fromK8sMetadata(resource: resource)
        items[uuid] = resource
    }
    public func delete(resource: Resource) throws {
        let uuid = try UUID.fromK8sMetadata(resource: resource)
        items.removeValue(forKey: uuid)
    }
    public func delete(uuid resourceKey: UUID) {
        items.removeValue(forKey: resourceKey)
    }
    public func refresh() async throws -> [Resource] {
        return try await resourceFetcher.list(in: .default) as! [Resource]
    }
}
