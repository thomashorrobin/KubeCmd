//
//  jobHelpers.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 22/03/2022.
//

import Foundation
import SwiftkubeModel

func createJobFromCronJob(cronJob:batch.v1beta1.CronJob) -> batch.v1.Job {
	let tmp = cronJob.spec?.jobTemplate.spec
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
	let dateStr = dateFormatter.string(from: Date())
	let x = "\(cronJob.name ?? "terrible-error")-manual-\(dateStr)"
	var existingMetadata = cronJob.metadata
	existingMetadata?.name = x
	var job = batch.v1.Job()
	existingMetadata?.resourceVersion = nil
	job.spec = tmp
	job.metadata = existingMetadata
	return job
}

