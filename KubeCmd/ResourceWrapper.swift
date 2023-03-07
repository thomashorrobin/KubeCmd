//
//  File.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 07/03/2023.
//

import Foundation
import SwiftkubeModel

internal class ResourceWrapper<Resource: KubernetesAPIResource>: ObservableObject {
    @Published private(set) var items:[UUID:Resource]
    init() {
        self.items = [UUID:Resource]()
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
}
