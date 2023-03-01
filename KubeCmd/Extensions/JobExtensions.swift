//
//  Job.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 01/03/2023.
//

import Foundation
import SwiftkubeModel

public extension batch.v1.Job {
    func getPods(pods:[UUID:core.v1.Pod]) throws -> [core.v1.Pod] {
        var podList = [core.v1.Pod]()
        for podKeyValue in pods {
            let pod = podKeyValue.value
            guard let metadata = pod.metadata else { continue }
            guard let ownerReferences = metadata.ownerReferences else { continue }
            guard let jobName = self.name else { continue }
            guard ownerReferences.count > 0 else {
                continue
            }
            let ownerReference = ownerReferences[0]
            if ownerReference.name == jobName {
                podList.append(pod)
            }
        }
        return podList
    }
}
