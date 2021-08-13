//
//  Extensions.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 10/08/2021.
//

import Foundation
import SwiftkubeModel

enum UUIDErrors: Error {
    case noMetadata
    case noUid
    case parseError
}

public extension UUID {
    static func fromK8sMetadata(resource: KubernetesAPIResource) throws -> UUID {
        guard let metadata = resource.metadata else { throw UUIDErrors.noMetadata }
        guard let uid = metadata.uid else { throw UUIDErrors.noUid }
        guard let uuid = UUID(uuidString: uid) else { throw
            UUIDErrors.parseError}
        return uuid
    }
}
