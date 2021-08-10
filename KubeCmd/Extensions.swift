//
//  Extensions.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 10/08/2021.
//

import Foundation
import SwiftkubeModel

public extension UUID {
    static func fromK8sMetadata(resource: KubernetesAPIResource) throws -> UUID {
        guard let metadata = resource.metadata else { throw SwiftkubeModelError.unknownAPIObject("metadata error") }
        guard let uid = metadata.uid else { throw SwiftkubeModelError.unknownAPIObject("metadata error") }
        guard let uuid = UUID(uuidString: uid) else { throw
            SwiftkubeModelError.unknownAPIObject("metadata error") }
        return uuid
    }
}
