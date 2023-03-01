//
//  CronJobExtensions.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 01/03/2023.
//

import Foundation
import SwiftkubeModel

public extension batch.v1.CronJob {
    func getJobs(jobs:[UUID:batch.v1.Job]) throws -> [batch.v1.Job] {
        var jobList = [batch.v1.Job]()
        for jobKeyValue in jobs {
            let job = jobKeyValue.value
            guard let metadata = job.metadata else { continue }
            guard let ownerReferences = metadata.ownerReferences else { continue }
            guard let cronJobName = self.name else { continue }
            guard ownerReferences.count > 0 else {
                continue
            }
            let ownerReference = ownerReferences[0]
            if ownerReference.name == cronJobName {
                jobList.append(job)
            }
        }
        return jobList
    }
}
