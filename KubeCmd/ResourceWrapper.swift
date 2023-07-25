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
    private var namespaceManager: NamespaceManager
    var watcher:SwiftkubeClientTask<WatchEvent<Resource>>
    init(resourceFetcher: NamespacedGenericKubernetesClient<Resource>, namespaceManager: NamespaceManager) throws {
        self.items = [UUID:Resource]()
        self.resourceFetcher = resourceFetcher
        self.namespaceManager = namespaceManager
        self.watcher = try resourceFetcher.watch(in: namespaceManager.namespace)
        Task {
            let resources = try await resourceFetcher.list(in: namespaceManager.namespace)
            for resource in resources.items {
                try upsert(resource: resource as! Resource)
            }
        }
        try connect()
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
    public func refresh() async throws {
        items.removeAll()
        let resources = try await resourceFetcher.list(in: namespaceManager.namespace)
        for resource in resources.items {
            try upsert(resource: resource as! Resource)
        }
    }
    private func connect() throws -> Void {
        Task {
            let stream = watcher.start()
            for try await event in stream {
                let resource = event.resource
                switch event.type {
                case .added:
                    try DispatchQueue.main.sync {
                        try self.upsert(resource: resource)
                    }
                case .modified:
                    try DispatchQueue.main.sync {
                        try self.upsert(resource: resource)
                    }
                case .deleted:
                    try DispatchQueue.main.sync {
                        try self.delete(resource: resource)
                    }
                default:
                    break
                }
            }
        }
    }
    deinit {
        watcher.cancel()
    }
}
